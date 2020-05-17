import {f,dir,exec,write,env} from "./collect.ts";

f(
  "/etc/nsswitch.conf",
  "/sbin/ldconfig",
  `/${env.LIB}/libnss_db.so.2`,
  `/${env.LIB}/libnss_dns.so.2`,
  `/${env.LIB}/libnss_files.so.2`,
  "/usr/share/locale/locale.alias",
  "/etc/ld.so.conf"
);

dir("/etc/ld.so.conf.d");

exec("find /usr/lib/gcc -name 'lib*.so*' -exec touch {} \\;", {overlay:true});

f(
  "/usr/bin/locale",
  "/usr/bin/localedef",
  "/usr/sbin/locale-gen"
);
// generate locale archive
write("/etc/locale.gen", 'en_US.UTF-8 UTF-8\nen_GB.UTF-8 UTF-8\nja_JP.UTF-8 UTF-8');
exec("/usr/sbin/locale-gen", {overlay:true});

f(
  `/usr/${env.LIB}/gconv/gconv-modules.cache`,
  `/usr/${env.LIB}/gconv/CP932.so`,
  `/usr/${env.LIB}/gconv/EUC-JISX0213.so`,
  `/usr/${env.LIB}/gconv/EUC-JP-MS.so`,
  `/usr/${env.LIB}/gconv/EUC-JP.so`,
  `/usr/${env.LIB}/gconv/IBM850.so`,
  `/usr/${env.LIB}/gconv/ISO-2022-JP-3.so`,
  `/usr/${env.LIB}/gconv/ISO-2022-JP.so`,
  `/usr/${env.LIB}/gconv/SJIS.so`,
  `/usr/${env.LIB}/gconv/UNICODE.so`,
  `/usr/${env.LIB}/gconv/UTF-16.so`,
  `/usr/${env.LIB}/gconv/UTF-32.so`,
  `/usr/${env.LIB}/gconv/UTF-7.so`,
  `/usr/${env.LIB}/gconv/libJIS.so`,
  `/usr/${env.LIB}/gconv/libJISX0213.so`
);

exec("ldconfig");
