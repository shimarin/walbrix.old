#include <unistd.h>
#include <argparse/argparse.hpp>

#include "walbrixd.h"

int console(const std::vector<std::string>& args);

int start(const std::vector<std::string>& args)
{
    argparse::ArgumentParser program(args[0]);
    program.add_argument("vmname").help("VM name");
    try {
        program.parse_args(args);
    }
    catch (const std::runtime_error& err) {
        std::cout << err.what() << std::endl;
        std::cout << program;
        return 1;
    }

    auto vmname = program.get<std::string>("vmname");
    
    execlp("busctl", "busctl", "--system", "call", 
        WALBRIXD_SERVICE_NAME, WALBRIXD_OBJECT_PATH, WALBRIXD_INTERFACE_NAME, 
        "Start", "s", vmname.c_str(), NULL
    );

    return 0;
}

int stop(const std::vector<std::string>& args)
{
    argparse::ArgumentParser program(args[0]);
    program.add_argument("vmname").help("VM name");
    try {
        program.parse_args(args);
    }
    catch (const std::runtime_error& err) {
        std::cout << err.what() << std::endl;
        std::cout << program;
        return 1;
    }
    
    auto vmname = program.get<std::string>("vmname");
    
    execlp("busctl", "busctl", "--system", "call", 
        WALBRIXD_SERVICE_NAME, WALBRIXD_OBJECT_PATH, WALBRIXD_INTERFACE_NAME, 
        "Stop", "s", vmname.c_str(), NULL
    );

    return 0;
}

int list(const std::vector<std::string>& args)
{
    execlp("busctl", "busctl", "--system", "call", 
        WALBRIXD_SERVICE_NAME, WALBRIXD_OBJECT_PATH, WALBRIXD_INTERFACE_NAME, 
        "List", NULL
    );

    return 0;
}

static const std::map<std::string,std::pair<int (*)(const std::vector<std::string>&),std::string> > subcommands {
  {"console", {console, "Enter VM console"}},
  {"start", {start, "Start VM"}},
  {"stop", {stop, "Stop VM"}},
  {"list", {list, "List VM"}},
};

void show_subcommands()
{
    for (auto i = subcommands.cbegin(); i != subcommands.cend(); i++) {
        std::cout << i->first << '\t' << i->second.second << std::endl;
    }
}

int main(int argc, char* argv[])
{
    setlocale( LC_ALL, "ja_JP.utf8"); // TODO: read /etc/locale.conf

    if (argc < 2) {
        std::cout << "Subcommand not specified. Valid subcommands are:" << std::endl;
        show_subcommands();
        return 1;
    }

    std::string subcommand(argv[1]);

    if (!subcommands.contains(subcommand)) {
        std::cout << "Invalid subcommand '" << subcommand << "'. Valid subcommands are:" << std::endl;
        show_subcommands();
        return 1;
    }

    std::vector<std::string> args;

    args.push_back(std::string(argv[0]) + ' ' + subcommand);
    for (int i = 2; i < argc; i++) {
        args.push_back(argv[i]);
    }

    return subcommands.at(subcommand).first(args);
}
