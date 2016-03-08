<?php 

return [
    "general" => [
        "timezone" => "Asia/Tokyo",
        "php_cli" => "",
        "domain" => "",
        "redirect_to_maindomain" => FALSE,
        "language" => "ja",
        "validLanguages" => "ja",
        "fallbackLanguages" => [
            "ja" => "en"
        ],
        "defaultLanguage" => "ja",
        "theme" => NULL,
        "extjs6" => "1",
        "loginscreencustomimage" => "",
        "disableusagestatistics" => FALSE,
        "debug" => FALSE,
        "debug_ip" => "",
        "http_auth" => [
            "username" => "",
            "password" => ""
        ],
        "custom_php_logfile" => TRUE,
        "debugloglevel" => "error",
        "disable_whoops" => FALSE,
        "debug_admin_translations" => FALSE,
        "devmode" => FALSE,
        "logrecipient" => NULL,
        "viewSuffix" => "",
        "instanceIdentifier" => "",
        "show_cookie_notice" => FALSE
    ],
    "database" => [
        "adapter" => "Pdo_Mysql",
        "params" => [
            "username" => "pimcore",
            "password" => "",
            "dbname" => "pimcore",
            "host" => "localhost",
            "port" => "3306"
        ]
    ],
    "documents" => [
        "versions" => [
            "days" => NULL,
            "steps" => 10
        ],
        "default_controller" => "default",
        "default_action" => "default",
        "error_pages" => [
            "default" => "/error"
        ],
        "createredirectwhenmoved" => FALSE,
        "allowtrailingslash" => "no",
        "allowcapitals" => "no",
        "generatepreview" => TRUE,
        "wkhtmltoimage" => "",
        "wkhtmltopdf" => ""
    ],
    "objects" => [
        "versions" => [
            "days" => NULL,
            "steps" => 10
        ]
    ],
    "assets" => [
        "versions" => [
            "days" => NULL,
            "steps" => 10
        ],
        "ffmpeg" => "",
        "ghostscript" => "",
        "libreoffice" => "",
        "pngcrush" => "",
        "imgmin" => "",
        "jpegoptim" => "",
        "pdftotext" => "",
        "icc_rgb_profile" => "",
        "icc_cmyk_profile" => "",
        "hide_edit_image" => FALSE
    ],
    "services" => [
        "google" => [
            "client_id" => "655439141282-tic94n6q3j7ca5c5as132sspeftu5pli.apps.googleusercontent.com",
            "email" => "655439141282-tic94n6q3j7ca5c5as132sspeftu5pli@developer.gserviceaccount.com",
            "simpleapikey" => "AIzaSyCo9Wj49hYJWW2WgOju4iMYNTvdcBxmyQ8",
            "browserapikey" => "AIzaSyBJX16kWAmUVEz1c1amzp2iKqAfumbcoQQ"
        ]
    ],
    "cache" => [
        "enabled" => FALSE,
        "lifetime" => NULL,
        "excludePatterns" => "",
        "excludeCookie" => ""
    ],
    "outputfilters" => [
        "less" => FALSE,
        "lesscpath" => ""
    ],
    "webservice" => [
        "enabled" => FALSE
    ],
    "httpclient" => [
        "adapter" => "Zend_Http_Client_Adapter_Socket",
        "proxy_host" => "",
        "proxy_port" => "",
        "proxy_user" => "",
        "proxy_pass" => ""
    ],
    "email" => [
        "sender" => [
            "name" => "pimcore Demo",
            "email" => "pimcore-demo@byom.de"
        ],
        "return" => [
            "name" => "pimcore Demo",
            "email" => "pimcore-demo@byom.de"
        ],
        "method" => "sendmail",
        "smtp" => [
            "host" => "",
            "port" => "",
            "ssl" => "",
            "name" => "",
            "auth" => [
                "method" => "",
                "username" => ""
            ]
        ],
        "debug" => [
            "emailaddresses" => "pimcore@byom.de"
        ],
        "bounce" => [
            "type" => "",
            "maildir" => "",
            "mbox" => NULL,
            "imap" => [
                "host" => NULL,
                "port" => NULL,
                "username" => "",
                "password" => "",
                "ssl" => FALSE
            ]
        ]
    ],
    "newsletter" => [
        "sender" => [
            "name" => "",
            "email" => ""
        ],
        "return" => [
            "name" => "",
            "email" => ""
        ],
        "method" => NULL,
        "smtp" => [
            "host" => "",
            "port" => "",
            "ssl" => "",
            "name" => "",
            "auth" => [
                "method" => "",
                "username" => ""
            ]
        ],
        "usespecific" => FALSE
    ],
    "applicationlog" => [
        "mail_notification" => [
            "send_log_summary" => FALSE,
            "filter_priority" => NULL,
            "mail_receiver" => ""
        ],
        "archive_treshold" => "30",
        "archive_alternative_database" => ""
    ]
];
