#include <unistd.h>
#include <wait.h>
#include <poll.h>
#include <sys/signalfd.h>
#include <netinet/icmp6.h>

#include <iostream>
#include <fstream>
#include <filesystem>
#include <regex>

#include <systemd/sd-bus.h>

#include <Poco/URI.h>
#include <Poco/Net/HTTPSClientSession.h>
#include <Poco/Net/HTTPRequest.h>
#include <Poco/Net/HTTPResponse.h>
#include <Poco/Net/ICMPClient.h>
#include <Poco/Net/NetException.h>
#include <Poco/JSON/Parser.h>

#include "wg-walbrix.h"

const size_t WG_KEY_LEN = 32;
const std::string interface("wg-walbrix");
const std::filesystem::path privkey_path("/etc/walbrix/privkey");

static int exec_command(const std::string& cmd, const std::vector<std::string>& args)
{
    pid_t pid = fork();
    if (pid < 0) std::runtime_error("fork");
    //else
    if (pid == 0) { //child
        char* argv[args.size() + 2];
        int i = 0;
        argv[i++] = strdup(cmd.c_str());
        for (auto arg : args) {
            argv[i++] = strdup(arg.c_str());
        }
        argv[i] = NULL;
        if (execvp(cmd.c_str(), argv) < 0) _exit(-1);
    }
    // else {
    int status;
    waitpid(pid, &status, 0);
    return status;
}

std::tuple<std::string,std::string,std::string,std::string,std::string,std::optional<std::string> > register_peer(const std::string& url, const std::string& my_pubkey)
{
    Poco::Net::initializeSSL();
    Poco::URI uri(url);
    Poco::Net::HTTPSClientSession session(uri.getHost(), uri.getPort());
    Poco::Net::HTTPRequest req(Poco::Net::HTTPRequest::HTTP_POST, uri.getPath(), Poco::Net::HTTPMessage::HTTP_1_1);
    std::string body = std::string("pubkey=");
    Poco::URI::encode(my_pubkey, "", body);
    req.setContentType("application/x-www-form-urlencoded");
    req.setContentLength(body.length());
    std::ostream& os = session.sendRequest(req);
    os << body;
    Poco::Net::HTTPResponse res;
    std::istream& rs = session.receiveResponse(res);

    Poco::JSON::Parser parser;
    Poco::JSON::Object::Ptr ret = parser.parse(rs).extract<Poco::JSON::Object::Ptr>();
    auto me = ret->getObject("me");
    auto you = ret->getObject("you");

    auto their_address = me->getValue<std::string>("address");
    auto endpoint = me->getValue<std::string>("endpoint");
    auto their_pubkey = me->getValue<std::string>("pubkey");
    auto sshkey = me->getValue<std::string>("sshkey");
    auto my_address = you->getValue<std::string>("address");
    auto psk = ret->has("psk") ? std::optional(ret->getValue<std::string>("psk")) : std::nullopt;

    return std::make_tuple(their_address,endpoint,their_pubkey,sshkey,my_address,psk);
}

static int method_status(sd_bus_message *m, void *userdata, sd_bus_error *ret_error) 
{
    return sd_bus_reply_method_return(m, "u", 1);
}

static const sd_bus_vtable vtable[] = {
    SD_BUS_VTABLE_START(0),
    SD_BUS_METHOD("status", "s", "u", method_status, SD_BUS_VTABLE_UNPRIVILEGED),
    SD_BUS_VTABLE_END
};

static std::string get_pubkey()
{
    uint8_t privkey_oct[WG_KEY_LEN];
    std::ifstream f(privkey_path);
    if (f) {
        std::string privkey_base64((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
        unsigned char privkey_decoded[3*privkey_base64.length()/4];
        auto n = EVP_DecodeBlock(privkey_decoded, (const unsigned char*)privkey_base64.c_str(), privkey_base64.length());
        if (n < WG_KEY_LEN) throw std::runtime_error("Private key is invalid");
        //else
        memcpy(privkey_oct, privkey_decoded, WG_KEY_LEN);
    } else {
        if (getentropy(privkey_oct, WG_KEY_LEN) != 0) throw std::runtime_error("getentropy");
        // else
        // curve25519_clamp_secret
        privkey_oct[0] &= 248;
        privkey_oct[31] = (privkey_oct[31] & 127) | 64;

        auto privkey_len = sizeof(privkey_oct);
        char privkey_base64[4*((privkey_len+2)/3)];
        if (!EVP_EncodeBlock((unsigned char*)privkey_base64, privkey_oct, privkey_len)) throw std::runtime_error("EVP_EncodeBlock");

        std::filesystem::create_directories(privkey_path.parent_path());
        {
            std::ofstream f2(privkey_path);
            if (!f2) throw std::runtime_error("Unable to write to private key file");
            f2 << privkey_base64;
        }
        std::filesystem::permissions(privkey_path, 
            std::filesystem::perms::owner_read | std::filesystem::perms::owner_write,
            std::filesystem::perm_options::replace);
    }

    //else
    auto privkey = std::shared_ptr<EVP_PKEY>(EVP_PKEY_new_raw_private_key(EVP_PKEY_X25519, NULL, privkey_oct, WG_KEY_LEN), EVP_PKEY_free);
    if (!privkey) std::runtime_error("Private key is invalid(EVP_PKEY_new_raw_private_key failed)");
    //else
    unsigned char pubkey_oct[WG_KEY_LEN];
    size_t pubkey_len = sizeof(pubkey_oct);
    if (!EVP_PKEY_get_raw_public_key(privkey.get(), pubkey_oct, &pubkey_len)) {
        throw std::runtime_error("Unable to generate public key from private key(EVP_PKEY_get_raw_public_key failed).");
    }

    char pubkey_base64[4*((pubkey_len+2)/3)];
    if (!EVP_EncodeBlock((unsigned char*)pubkey_base64, pubkey_oct, pubkey_len)) throw std::runtime_error("EVP_EncodeBlock");
    //else
    return pubkey_base64;
}

static int loop(const std::string& their_address)
{
    struct sockaddr_in6 whereto;
    whereto.sin6_family = AF_INET6;
    whereto.sin6_port = htons(0);
    if (!inet_pton(AF_INET6, their_address.c_str(), &whereto.sin6_addr)) {
        throw std::runtime_error("inet_pton");
    }

    auto sock = socket(AF_INET6, SOCK_RAW, IPPROTO_ICMPV6); // You need to be root to do this
    if (sock < 0) throw std::runtime_error("socket");

    auto last_ping_time = time(NULL);
    auto last_pong_time = last_ping_time;
    int retry_count = 0;

    // https://tools.ietf.org/html/rfc4443
    unsigned char icmpv6_packet[sizeof(struct icmp6_hdr) + 8];

    auto ping = [icmpv6_packet,sock,&whereto,&last_ping_time]() {
        //std::cout << "PING" << std::endl;
        auto icmph = (struct icmp6_hdr *)icmpv6_packet;
        icmph->icmp6_type = ICMP6_ECHO_REQUEST;
        icmph->icmp6_code = 0;
        icmph->icmp6_cksum = 0;
        icmph->icmp6_seq= 1;
        icmph->icmp6_id= 0;
        strcpy((char*)icmpv6_packet + sizeof(struct icmp6_hdr), "RUTHERE");
        last_ping_time = time(NULL);
        return sendto(sock, icmpv6_packet, sizeof(icmpv6_packet), 0/*flags*/, (struct sockaddr *)&whereto, sizeof(struct sockaddr_in6));
    };

    sd_bus_slot *slot = NULL;
    sd_bus *bus = NULL;

    auto r = sd_bus_open_system(&bus);
    if (r < 0) {
        throw std::runtime_error(std::string("Failed to connect to system bus: ") + strerror(-r));
    }

    /* Install the object */
    r = sd_bus_add_object_vtable(bus,
                                    &slot,
                                    WG_WALBRIX_OBJECT_PATH,  /* object path */
                                    WG_WALBRIX_INTERFACE_NAME,   /* interface name */
                                    vtable,
                                    NULL);
    if (r < 0) {
        throw std::runtime_error(std::string("Failed to issue method call: ") + strerror(-r));
    }

    /* Take a well-known service name so that clients can find us */
    r = sd_bus_request_name(bus, WG_WALBRIX_SERVICE_NAME, 0);
    if (r < 0) {
        throw std::runtime_error(std::string("Failed to acquire service name: ") + strerror(-r));
    }

    sigset_t mask;
    sigemptyset (&mask);
    sigaddset (&mask, SIGINT);
    sigaddset (&mask, SIGTERM);
    sigprocmask(SIG_SETMASK, &mask, NULL);
    auto sigfd = signalfd (-1, &mask, SFD_NONBLOCK|SFD_CLOEXEC);
    struct pollfd pollfds[2];
    pollfds[0].fd = sigfd;
    pollfds[0].events = POLLIN;
    pollfds[1].fd = sock;
    pollfds[1].events = POLLIN;
    pollfds[2].fd = sd_bus_get_fd(bus);
    pollfds[2].events = sd_bus_get_events(bus);
    while (true) {
        if (poll(pollfds, 3, 1000) < 0) throw std::runtime_error("poll");
        if (pollfds[0].revents & POLLIN) break;
        //else
        auto now = time(NULL);
        if (pollfds[1].revents & POLLIN) {
            auto n = recvfrom(sock, icmpv6_packet, sizeof(icmpv6_packet), 0, NULL, NULL);
            auto hdrsize = sizeof(struct icmp6_hdr);
            if (n == hdrsize + 8 && icmpv6_packet[0] == ICMP6_ECHO_REPLY && memcmp(icmpv6_packet + hdrsize, "RUTHERE", 8) == 0) {
                last_pong_time = now;
                retry_count = 0;
                //std::cout << "PONG" << std::endl;
            }
        }
        if (pollfds[2].revents) {
            auto r = sd_bus_process(bus, NULL);
        }
        if (last_ping_time > last_pong_time && last_ping_time < now - 5) {
            if (retry_count >= 10) {
                std::cout << "No ping reply. service will be restarted." << std::endl;
                break;
            }
            ping();
            retry_count ++;
        } else if (last_ping_time < now - 60) {
            ping();
        }
    }
    close(sock);
    return 1;
}

int main(int argc, char* argv[])
{
    if (argc < 2) {
        std::cout << argv[0] << " URL" << std::endl;
        return 1;
    }
    auto url = argv[1];
    int rst = 0;
    try {
        auto const& [their_address,endpoint,pubkey,sshkey,my_address,psk] = register_peer(url, get_pubkey());
        if (exec_command("ip", {"link", "add", interface, "type", "wireguard"}) != 0) throw std::runtime_error("ip link add");
        //else
        exec_command("wg", {"set", interface, "private-key", privkey_path.string()});
        exec_command("wg", {"set", interface, "peer", pubkey, "endpoint", endpoint, "persistent-keepalive", "25", "allowed-ips", their_address});
        exec_command("ip", {"link", "set", interface, "up"});
        exec_command("ip", {"-6", "address", "replace", my_address, "dev", interface});
        exec_command("ip", {"route", "replace", their_address, "dev", interface});
        rst = loop(std::regex_replace(their_address, std::regex("/\\d+$"), ""));
    }
    catch ( const std::runtime_error& ex ) {
        std::cerr << ex.what() << std::endl;
        rst = 1;
    }
    catch ( const Poco::Net::NetException& ex) {
        std::cerr << ex.message() << std::endl;
        rst = 1;
    }
    exec_command("ip", {"link", "set", interface, "down"});
    exec_command("ip", {"link", "del", interface});
    return rst;
}

// g++ -std=c++2a -o wg-walbrix wg-walbrix.cpp -lPocoNet -lPocoNetSSL -lPocoFoundation -lPocoJSON
