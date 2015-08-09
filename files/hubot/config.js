var conf = {};

conf.user = "";
conf.group = "";

conf.log = "kiwi.log";

conf.servers = [];
conf.servers.push({
    port:   80,
    address: "0.0.0.0"
});

conf.outgoing_address = {
    IPv4: '0.0.0.0'
    //IPv6: '::'
};

conf.identd = {
    enabled: false,
    port: 113,
    address: "0.0.0.0"
};

conf.public_http = "client/";
conf.max_client_conns = 5;
conf.max_server_conns = 0;
conf.default_encoding = 'utf8';
//conf.default_gecos = 'Web IRC Client';
conf.ircd_reconnect = true;

conf.client_plugins = [
    // "http://server.com/kiwi/plugins/myplugin.html"
];

conf.module_dir = "../server_modules/";
conf.modules = [];
//conf.webirc_pass = "foobar";
//conf.webirc_pass = {
//    "irc.network.com":  "configured_webirc_password",
//    "127.0.0.1":        "foobar"
//};

conf.ip_as_username = [
    //"irc.network.com",
    //"127.0.0.1"
];

conf.reject_unauthorised_certificates = false;
conf.http_proxies = ["127.0.0.1/32","10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"];
conf.http_proxy_ip_header = "x-forwarded-for";
conf.http_base_path = "/kiwi";

conf.socks_proxy = {};
conf.socks_proxy.enabled = false;
conf.socks_proxy.all = false;
conf.socks_proxy.proxy_hosts = [
    "irc.example.com"
];

conf.socks_proxy.address = '127.0.0.1';
conf.socks_proxy.port = 1080;
conf.socks_proxy.user = null;
conf.socks_proxy.pass = null;

conf.quit_message = "http://www.kiwiirc.com/ - A hand-crafted IRC client";

conf.client = {
    server: 'localhost',
    port:    6667,
    ssl:     false,
    channel: '#default',
    channel_key: '',
    nick:    'user_?',
    settings: {
        theme: 'relaxed',
        text_theme: 'default',
        channel_list_style: 'tabs',
        scrollback: 250,
        show_joins_parts: true,
        show_timestamps: false,
        use_24_hour_timestamps: true,
        mute_sounds: false,
        show_emoticons: true,
        count_all_activity: false,
        locale: null // null = use the browser locale settings
    },
    window_title: 'Kiwi IRC'
};

conf.client_themes = [
    'relaxed',
    'mini',
    'cli',
    'basic'
];

conf.restrict_server = "localhost";
conf.restrict_server_port = 6667;

module.exports.production = conf;
