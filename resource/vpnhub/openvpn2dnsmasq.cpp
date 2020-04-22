#include <string.h>
#include <signal.h>

#include <string>
#include <fstream>
#include <filesystem>
#include <vector>
#include <map>
#include <optional>
#include <iostream>

#include <openvpn-plugin.h>

struct Peer {
  std::optional<std::string> ip_address;
  std::optional<std::string> origin;
  bool active = true;
};

struct Context {
  std::string domain_suffix;
  std::filesystem::path hosts_file, dnsmasq_pid_file, path;

  std::map<std::string, Peer> hosts;

  std::ofstream log;

  Context(const std::string& _domain_suffix,
    const std::filesystem::path& _hosts_file,
    const std::filesystem::path& _dnsmasq_pid_file,
    const std::filesystem::path& logfile)
    : domain_suffix(_domain_suffix), hosts_file(_hosts_file), dnsmasq_pid_file(_dnsmasq_pid_file), log(logfile) {;}
};

static void update_hosts_file(const std::map<std::string, Peer>& hosts, const std::string& suffix, const std::filesystem::path& hosts_file)
{
  std::ofstream f(hosts_file);
  for (auto i = hosts.begin(); i != hosts.end(); i++) {
    if (!i->second.ip_address) continue;
    if (!i->second.active) f << "# ";

    f << i->second.ip_address.value() << '\t' << (i->first + suffix);
    if (i->second.origin) f << '\t' << "# " << i->second.origin.value();

    f << std::endl;
  }
}

static void send_hup_to_dnsmasq(const std::filesystem::path& pid_file)
{
  std::ifstream f(pid_file);
  if (f) {
    pid_t pid;
    f >> pid;
    kill(pid, SIGHUP);
  }
}

static int deactivate_ip_address(std::map<std::string, Peer>& hosts, const std::string& ip_address)
{
  int cnt = 0;
  for (auto i = hosts.begin(); i != hosts.end(); i++) {
    if (i->second.ip_address == ip_address) {
      i->second.active = false;
      cnt++;
    }
  }
  return cnt;
}

extern "C" {
OPENVPN_EXPORT int
openvpn_plugin_open_v3(const int v3structver,
                       struct openvpn_plugin_args_open_in const *args,
                       struct openvpn_plugin_args_open_return *ret)
{
  ret->type_mask = /*OPENVPN_PLUGIN_MASK(OPENVPN_PLUGIN_AUTH_USER_PASS_VERIFY) |*/ OPENVPN_PLUGIN_MASK(OPENVPN_PLUGIN_CLIENT_CONNECT_V2) |
    OPENVPN_PLUGIN_MASK(OPENVPN_PLUGIN_CLIENT_DISCONNECT) | OPENVPN_PLUGIN_MASK(OPENVPN_PLUGIN_IPCHANGE) |
    OPENVPN_PLUGIN_MASK(OPENVPN_PLUGIN_LEARN_ADDRESS);

  std::vector<std::string> arg_list;
  for (int i = 0; args->argv[i]; i++) {
    arg_list.push_back(args->argv[i]);
  }

  auto arg_len = arg_list.size();
  std::string suffix = (arg_len > 1 && arg_list[1][0] != '\0') ? arg_list[1] : ".openvpn";

  auto context = new Context(
    suffix,
    arg_len > 2 ? arg_list[2] : ((std::string)"/etc/hosts" + suffix),
    arg_len > 3 ? arg_list[3] : "/run/dnsmasq.pid",
    arg_len > 4 ? arg_list[4] : "/dev/null"
  );
  ret->handle = context;
  context->log << "start" << std::endl;
  return OPENVPN_PLUGIN_FUNC_SUCCESS;
}

OPENVPN_EXPORT int
openvpn_plugin_func_v3(const int version,
                       struct openvpn_plugin_args_func_in const *args,
                       struct openvpn_plugin_args_func_return *retptr)
{
  auto context = (Context*)args->handle;
  try {
    if (args->type == OPENVPN_PLUGIN_IPCHANGE) {
      auto origin = args->argv[1];

      for (int i = 0; args->envp[i] != NULL; i++) {
        if (strlen(args->envp[i]) > 12 && strncmp(args->envp[i], "common_name=", 12) == 0) {
          auto common_name = args->envp[i] + 12;
          context->hosts[common_name].origin = origin;
        }
      }
    } else if (args->type == OPENVPN_PLUGIN_LEARN_ADDRESS) {
      std::string op = args->argv[1];
      //context->log << "op=" << op << std::endl;
      if (op == "add" || op == "update") {
        auto common_name = args->argv[3];
        auto ip_address = args->argv[2];
        deactivate_ip_address(context->hosts, ip_address);
        context->hosts[common_name].ip_address = ip_address;
        context->hosts[common_name].active = true;
        //context->log << common_name << ':' << ip_address << std::endl;
      } else if (op == "delete") {
        auto ip_address = args->argv[2];
        deactivate_ip_address(context->hosts, ip_address);
      }
      update_hosts_file(context->hosts, context->domain_suffix, context->hosts_file);
      send_hup_to_dnsmasq(context->dnsmasq_pid_file);
    }
  }
  catch (const std::exception& ex) {
    context->log << ex.what() << std::endl;
    return OPENVPN_PLUGIN_FUNC_ERROR;
  }

  return OPENVPN_PLUGIN_FUNC_SUCCESS;
}

OPENVPN_EXPORT void
openvpn_plugin_close_v1(openvpn_plugin_handle_t handle)
{
  auto context = (Context*)handle;
  context->log << "end" << std::endl;
  delete context;
}

} // extern "C"
