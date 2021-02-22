#include <errno.h>
#include <poll.h>
#include <unistd.h>
#include <pty.h>
#include <fcntl.h>
#include <grp.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <sys/utsname.h>
#include <sys/xattr.h>
#include <stdexcept>
#include <iostream>
#include <string>
#include <map>
#include <set>
#include <vector>
#include <systemd/sd-bus.h>
#include <argparse/argparse.hpp>

#include "walbrixd.h"

struct Config {
    bool verbose;
    std::string bridge;
};

struct Vm {
    std::string name;
    pid_t pid;
    int fd;

    int listening_socket;
    int peer_socket = -1;

    std::vector<unsigned char> inbuf;
    std::vector<unsigned char> inbuf_tail;
    int inbuf_tail_size = 2048;
    std::vector<unsigned char> inbuf_iac;
    std::vector<char> outbuf;
};

std::map<std::string,Vm> vms;

int make_nonblocking(int fd)
{
    auto flags = fcntl(fd, F_GETFL, 0);
    return fcntl(fd, F_SETFL, flags | O_NONBLOCK);
}

std::pair<pid_t, int> createSubprocessWithPty(int rows, int cols, const char* prog, const std::vector<std::string>& args = {}, const char* TERM = "xterm-256color")
{
    int fd;
    struct winsize win = { (unsigned short)rows, (unsigned short)cols, 0, 0 };
    auto pid = forkpty(&fd, NULL, NULL, &win);
    if (pid < 0) throw std::runtime_error("forkpty failed");
    //else

    if (!pid) {
        // remove all signal handlers
        struct sigaction sig_action;
        sig_action.sa_handler = SIG_DFL;
        sig_action.sa_flags = 0;
        sigemptyset(&sig_action.sa_mask);
        
        for (int i = 0 ; i < NSIG ; i++) {
            sigaction(i, &sig_action, NULL);
        }

        // unblock SIGTERM
        sigset_t set;
        sigemptyset(&set);
        sigaddset(&set, SIGTERM);
        sigprocmask(SIG_UNBLOCK, &set, NULL);

        setenv("TERM", TERM, 1);
        char ** argv = new char *[args.size() + 2];
        argv[0] = strdup(prog);
        for (int i = 1; i <= args.size(); i++) {
            argv[i] = strdup(args[i - 1].c_str());
        }
        argv[args.size() + 1] = NULL;
        if (execvp(prog, argv) < 0) exit(-1);
    }
    //else 
    return { pid, fd };
}

class AlreadyRunning : public std::runtime_error {
public:
    AlreadyRunning(const std::string& what) : std::runtime_error(what) {;}
};
class NotExists : public std::runtime_error {
public:
    NotExists(const std::string& what) : std::runtime_error(what) {;}
};

static pid_t start(const Config& config, const std::string& name)
{
    if (vms.count(name) && kill(vms.at(name).pid, 0) == 0) {
        throw AlreadyRunning("VM is already running.");
    }
    //else

    auto vmpath = WALBRIX_VM_ROOT / name;
    auto systempath = vmpath / "system";
    auto fspath = vmpath / "fs";
    auto disk0path = vmpath / "disk0";

    if (!std::filesystem::exists(vmpath) || (!std::filesystem::exists(systempath) && !std::filesystem::exists(fspath) && ! std::filesystem::exists(disk0path))) {
        throw NotExists("VM not exists.");
    }
    //else

    std::string program = "systemd-nspawn";
    std::vector<std::string> args;

    if (std::filesystem::exists(disk0path)) { // Treat as full virtual
        auto cdrompath = vmpath / "cdrom.iso";
        struct utsname name;
        if (uname(&name) < 0) throw std::runtime_error("uname() failed");
        program = std::string("qemu-system-") + name.machine;
        args = { "-netdev", "bridge,br=" + config.bridge + ",id=net0", "-device", "virtio-net-pci,netdev=net0", "-monitor", "stdio",
            "-drive", "file=" + disk0path.string() + ",media=disk", "-rtc", "base=utc,clock=rt", "-m", "1024" };
        if (std::filesystem::exists(cdrompath)) {
            args.push_back("-cdrom");
            args.push_back(cdrompath);
        }
        if (std::filesystem::exists("/dev/kvm")) {
            args.push_back("-enable-kvm");
        }
    } else { // otherwise a container
        args = {"-b", std::string("--network-bridge=") + config.bridge, std::string("--machine=") + name, "--register=no",
            "--capability=CAP_SYS_MODULE", "--bind-ro=/lib/modules", "--bind-ro=/sys/module" };
        if (std::filesystem::exists(systempath)) {
            std::filesystem::create_directories(fspath);
            args.push_back("-i");
            args.push_back(systempath);
            args.push_back(std::string("--overlay=+/:") + fspath.string() + ":/");
        } else {
            args.push_back("-D");
            args.push_back(fspath);
        }
    }

    auto vm = createSubprocessWithPty(24, 80, program.c_str(), args);

    make_nonblocking(vm.second);

    int sock = socket(AF_UNIX, SOCK_STREAM, 0);
    if (sock < 0) throw std::runtime_error("Unable to create socket for listening");
    //else
    struct sockaddr_un sockaddr;
    memset(&sockaddr, 0, sizeof(sockaddr));
    sockaddr.sun_family = AF_UNIX;
    std::filesystem::create_directories(WALBRIXD_CONSOLE_SOCKET_BASE_DIR);
    std::filesystem::path path = WALBRIXD_CONSOLE_SOCKET_BASE_DIR / name;
    if (std::filesystem::exists(path)) std::filesystem::remove(path);
    strcpy(sockaddr.sun_path, path.c_str());
    if (bind(sock, (const struct sockaddr*)&sockaddr, sizeof(sockaddr)) < 0) {
        close(sock);
        throw std::runtime_error("Unable to bind socket");
    }

    // make socket accessible from wheel
    chmod(path.c_str(), S_IRUSR|S_IWUSR|S_IRGRP|S_IWGRP);
    struct group* g = getgrnam("wheel");
    if (g) {
        chown(path.c_str(), geteuid(), g->gr_gid);
    }

    if (listen(sock, 10) < 0) { 
        close(sock);
        throw std::runtime_error("Unable to listen socket");
    }

    make_nonblocking(sock);

    vms[name] = Vm { name, vm.first, vm.second, sock };

    std::cout << name << " started. PID=" << vm.first << "," << " fd=" << vm.second << " sock=" << sock << std::endl;

    return vm.first;
}

static int method_start(sd_bus_message *m, void *userdata, sd_bus_error *ret_error) {
    const char* name;
    const Config* config = (const Config*)userdata;

    /* Read the parameters */
    auto r = sd_bus_message_read(m, "s", &name);
    if (r < 0) {
        fprintf(stderr, "Failed to parse parameters: %s\n", strerror(-r));
        return r;
    }

    try {
        auto pid = start(*config, name);
        /* Reply with the response */
        return sd_bus_reply_method_return(m, "u", pid);
    }
    catch (const AlreadyRunning& e) {
        sd_bus_error_set_const(ret_error, "com.walbrix.AlreadyRunning", "VM is already running.");
        return -EINVAL;
    }
    catch (const NotExists& e) {
        sd_bus_error_set_const(ret_error, "com.walbrix.NotExists", "VM not exists.");
        return -EINVAL;
    }
}

static int method_stop(sd_bus_message *m, void *userdata, sd_bus_error *ret_error) {
    const char* name;

    /* Read the parameters */
    auto r = sd_bus_message_read(m, "s", &name);
    if (r < 0) {
        fprintf(stderr, "Failed to parse parameters: %s\n", strerror(-r));
        return r;
    }

    if (!vms.count(name)) {
        sd_bus_error_set_const(ret_error, "con.walbrix.NotRunning", "VM is not running.");
        return -EINVAL;
    }

    if (kill(vms.at(name).pid, 0) < 0 && errno == ESRCH) {
        vms.erase(name);        
        sd_bus_error_set_const(ret_error, "com.walbrix.Vanished", "VM is vanished.");
    }

    std::cout << "Stopping " << name << std::endl;

    kill(vms.at(name).pid, SIGTERM);

    /* Reply with the response */
    return sd_bus_reply_method_return(m, "u", vms.at(name).pid);
}

static int method_list(sd_bus_message *m, void *userdata, sd_bus_error *ret_error) {
    const Config* config = (const Config*)userdata;

    sd_bus_message *reply;

    auto r = sd_bus_message_new_method_return(m, &reply);
    if (r < 0) {
        std::cerr << "Failed to create reply message." << std::endl;
        return r;        
    }
    r = sd_bus_message_open_container(reply, SD_BUS_TYPE_ARRAY, "(suu)");
    if (r < 0) {
        std::cerr << "Failed to open reply message container." << std::endl;
        goto end;        
    }

    for (auto i = vms.cbegin(); i != vms.cend(); i++) {
        if (r = sd_bus_message_open_container(reply, SD_BUS_TYPE_STRUCT, "suu") < 0) goto end;
        if (r = sd_bus_message_append(reply, "suu", i->first.c_str(),i->second.pid, 0) < 0) goto end;
        if (r = sd_bus_message_close_container(reply)) goto end;
    }

    if (r = sd_bus_message_close_container(reply) < 0) goto end;

    r = sd_bus_send(NULL, reply, NULL);
end:;
    sd_bus_message_unref(reply);
    return r;
}

static const sd_bus_vtable vtable[] = {
    SD_BUS_VTABLE_START(0),
    SD_BUS_METHOD("Start", "s", "u", method_start, SD_BUS_VTABLE_UNPRIVILEGED),
    SD_BUS_METHOD("Stop", "s", "u", method_stop, SD_BUS_VTABLE_UNPRIVILEGED),
    SD_BUS_METHOD("List", "", "a(suu)", method_list, SD_BUS_VTABLE_UNPRIVILEGED),
    SD_BUS_VTABLE_END
};

void process_io(Vm& vm, const Config& config)
{
    // process output to VM
    auto outbuf_size = vm.outbuf.size();
    for (int i = 0; i < outbuf_size; i++) {
        if (write(vm.fd, &(vm.outbuf[0]), 1) <= 0/*EAGAIN?*/) break;
        //else
        vm.outbuf.erase(vm.outbuf.begin());
    }
    // process input from VM
    while(true) {
        char buf[4096];
        int r = read(vm.fd, buf, sizeof(buf));
        if (r == 0/*EOF*/ || r < 0/*possibly EAGAIN*/) break;
        //else
        for (int i = 0; i < r; i++) {
            if (vm.peer_socket >= 0) vm.inbuf.push_back(buf[i]);
            vm.inbuf_tail.push_back(buf[i]);
        }
        if (vm.inbuf_tail.size() > vm.inbuf_tail_size) {
            vm.inbuf_tail.erase(vm.inbuf_tail.begin(), vm.inbuf_tail.begin() + (vm.inbuf_tail.size() - vm.inbuf_tail_size));
        }
        if (config.verbose) {
            std::cout << "read " << r << " bytes from " << vm.name << std::endl;
        }
    }
    // process listening socket
    int sock = accept(vm.listening_socket, NULL, NULL);
    if (sock >= 0) {
        if (vm.peer_socket < 0) {
            make_nonblocking(sock);
            vm.peer_socket = sock;
            vm.inbuf = vm.inbuf_tail;
            std::cout << "Peer accepted." << std::endl;
        } else {
            const char* msg = "Simultaneous connections are not allowed\n";
            write(sock, msg, strlen(msg));
            close(sock);
        }
    }

    // process output to peer(was input from VM)
    if (vm.peer_socket >= 0) {
        auto inbuf_size = vm.inbuf.size();
        int cnt = 0;
        for (int i = 0; i < inbuf_size; i++) {
            if (write(vm.peer_socket, &(vm.inbuf[0]), 1) <= 0/*EAGAIN?*/) break;
            //else
            vm.inbuf.erase(vm.inbuf.begin());
            cnt++;
        }
        if (config.verbose && inbuf_size > 0) std::cout << "wrote " << cnt << " bytes to peer" << std::endl;

        // process input from peer(will be output to VM)
        while(true) {
            uint8_t buf[4096];
            int r = read(vm.peer_socket, buf, sizeof(buf));
            if (r < 0/*possibly EAGAIN*/) break;
            if (r == 0/*EOF*/) {
                std::cout << "EOF from peer. Cleaning up." << std::endl;
                // cleanup socket when EOF
                close(vm.peer_socket);
                vm.peer_socket = -1;
                break;
            }
            //else
            for (int i = 0; i < r; i++) {
                if (buf[i] == 0xff) {
                    vm.inbuf_iac.push_back(0xff);
                    continue;
                }
                auto iac_size = vm.inbuf_iac.size();
                if (iac_size > 0) {
                    if (iac_size == 1 && buf[i] == 0xfa/*SB*/) {
                        vm.inbuf_iac.push_back(0xfa);
                        continue;
                    }
                    //else
                    if (iac_size == 2 && buf[i] == 0x1f/*window_size*/) {
                        vm.inbuf_iac.push_back(0x1f);
                        continue;
                    }
                    //else
                    if (iac_size >= 3 && iac_size < 7) {
                        vm.inbuf_iac.push_back(buf[i]);
                        if (iac_size >= 6) { // now it's >= 7
                            // set terminal window size
                            struct winsize winsz;
                            winsz.ws_row = (vm.inbuf_iac[5] << 8) + vm.inbuf_iac[6];
                            winsz.ws_col = (vm.inbuf_iac[3] << 8) + vm.inbuf_iac[4];
                            ioctl(vm.fd, TIOCSWINSZ, &winsz);

                            vm.inbuf_iac.clear();
                        }
                        continue;
                    }
                    // else
                    vm.inbuf_iac.clear(); // something strange. reset iac status
                }
                vm.outbuf.push_back(buf[i]);
            }
        }
    }
}

static void process_autostart(const Config& config)
{
    for_each_vmdir([&config](auto name, auto dir){
        char c;
        if (getxattr(dir.path().c_str(), WALBRIX_XATTR_AUTOSTART, &c, sizeof(c)) < 0) return;
        try {
            start(config, name);
        }
        catch (const AlreadyRunning&) {}
        catch (const NotExists&) {}
    });
}

static int _main(int argc, char *argv[])
{
    argparse::ArgumentParser program(argv[0]);

    program.add_argument("--verbose").help("verbose mode").default_value(false).implicit_value(true);
    program.add_argument("-b", "--bridge").help("bridge interface").default_value(std::string("br0"));

    program.parse_args(argc, argv);

    Config config { program.get<bool>("--verbose"), program.get<std::string>("--bridge") };

    if (config.verbose) {
        std::cout << "Bridge interface: " << config.bridge << std::endl;
    }

    sd_bus_slot *slot = NULL;
    sd_bus *bus = NULL;

    int status = 0;

    try {
        /* Connect to the user bus this time */
        auto r = sd_bus_open_system(&bus);
        if (r < 0) {
            throw std::runtime_error(std::string("Failed to connect to system bus: ") + strerror(-r));
        }

        /* Install the object */
        r = sd_bus_add_object_vtable(bus,
                                        &slot,
                                        WALBRIXD_OBJECT_PATH,  /* object path */
                                        WALBRIXD_INTERFACE_NAME,   /* interface name */
                                        vtable,
                                        &config);
        if (r < 0) {
            throw std::runtime_error(std::string("Failed to issue method call: ") + strerror(-r));
        }

        /* Take a well-known service name so that clients can find us */
        r = sd_bus_request_name(bus, WALBRIXD_SERVICE_NAME, 0);
        if (r < 0) {
            throw std::runtime_error(std::string("Failed to acquire service name: ") + strerror(-r));
        }

        sigset_t mask;
        sigemptyset (&mask);
        sigaddset (&mask, SIGINT);
        sigaddset (&mask, SIGTERM);
        sigaddset (&mask, SIGCHLD);
        sigprocmask(SIG_SETMASK, &mask, NULL);
        auto sigfd = signalfd (-1, &mask, SFD_NONBLOCK|SFD_CLOEXEC);

        if (config.verbose) {
            std::cout << getpid() << std::endl;
        }

        std::cout << "Processing autostart..." << std::endl;
        process_autostart(config);
        std::cout << "Autostart done." << std::endl;

        bool exit_flag = false;

        for (;;) {
            /* Process requests */
            auto r = sd_bus_process(bus, NULL);
            if (r < 0) {
                throw std::runtime_error(std::string("Failed to process bus: ") + strerror(-r));
            }
            if (r > 0) /* we processed a request, try to process another one, right-away */
                continue;

            std::vector<std::pair<int,short> > pollfds;
            pollfds.push_back({sigfd, POLLIN}); // 0
            pollfds.push_back({sd_bus_get_fd(bus), sd_bus_get_events(bus)}); // 1
            for (auto i = vms.begin(); i != vms.end(); i++) {
                Vm& vm = i->second;
                pollfds.push_back({vm.fd, vm.outbuf.size() > 0 ? (POLLIN|POLLOUT) : POLLIN});
                //std::cout << vm.outbuf.size() << std::endl;
                pollfds.push_back({vm.listening_socket, POLLIN});
                if (vm.peer_socket >= 0) pollfds.push_back({vm.peer_socket, vm.inbuf.size() > 0? (POLLIN|POLLOUT) : POLLIN});
            }

            struct pollfd c_pollfds[pollfds.size()];
            for (int i = 0; i < pollfds.size(); i++) {
                c_pollfds[i].fd = pollfds[i].first;
                c_pollfds[i].events = pollfds[i].second;
            }

            if (poll(c_pollfds, pollfds.size(), 1000) == 0) {
                if (config.verbose) {
                    std::cout << "poll() timeout" << std::endl;
                }
            }
            /* else {
                for (int i = 0; i < pollfds.size(); i++) {
                    std::string flags;
                    if (c_pollfds[i].events & POLLIN) flags = "POLLIN";
                    if (c_pollfds[i].events & POLLOUT) {
                        if (flags.length() > 0) flags += "|";
                        flags += "POLLOUT";
                    }
                    if (flags.length() > 0) std::cout << c_pollfds[i].fd << ": " << flags << std::endl;
                }
            }*/

            if (c_pollfds[0].revents & POLLIN) { // signal received
                struct signalfd_siginfo info;
                read(c_pollfds[0].fd, &info, sizeof(info));
                std::cout << "Signal received: signo=" << info.ssi_signo << ", code=" << info.ssi_code << ", pid=" << info.ssi_pid << std::endl;
                if (info.ssi_signo == SIGTERM || info.ssi_signo == SIGINT) {
                    for (auto i = vms.cbegin(); i != vms.cend(); i++) {
                        std::cout << "Shutting down " << i->first << std::endl;
                        kill(i->second.pid, SIGTERM);
                    }
                    exit_flag = true;
                }
            }

            // cleanup exited child processes
            pid_t pid;
            int status;
            while ((pid = waitpid(-1, &status, WNOHANG)) > 0) {
                std::cout << "PID " << pid << " exited with status " << status << "." << std::endl;
                for (auto i = vms.begin(), next_i = i; i != vms.end(); i = next_i) {
                    Vm& vm = i->second;
                    ++next_i;
                    if (vm.pid == pid/*exited process*/ || kill(vm.pid, 0) < 0/*stale process*/) {
                        // cleanup peer socket
                        if (vm.peer_socket >= 0) close(vm.peer_socket);
                        // cleanup listening socket
                        close(vm.listening_socket);
                        // remove socket file
                        std::filesystem::path path = WALBRIXD_CONSOLE_SOCKET_BASE_DIR / i->first;
                        if (std::filesystem::exists(path)) std::filesystem::remove(path);
                        vms.erase(i);
                        std::cout << "VM erased. remain=" << vms.size() << std::endl;
                    }
                }
            }

            if (exit_flag && vms.size() == 0) break;

            // process each vm's i/o
            for (auto i = vms.begin(); i != vms.end(); i++) {
                process_io(i->second, config);
            }

            if (config.verbose && c_pollfds[1].revents != 0) {
                std::cout << "Message received" << std::endl;
            }

            /* Wait for the next request to process */
            r = sd_bus_wait(bus, (uint64_t) 0);
            if (r < 0) {
                throw std::runtime_error(std::string("Failed to wait on bus: %s\n") + strerror(-r));
            }

        }
    }
    catch (const std::exception& ex) {
        std::cerr << ex.what() << std::endl;
        status = 1;
    }

    sd_bus_slot_unref(slot);
    sd_bus_unref(bus);

    return status;
}

#ifdef __MAIN_MODULE__
int main(int argc, char* argv[]) { return _main(argc, argv); }
#endif

