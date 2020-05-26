import {f,exec,LIB} from "./collect.ts";

f(
  "/etc/nsswitch.conf",
  "/sbin/ldconfig",
  `/${LIB}/libnss_db.so.2`,
  `/${LIB}/libnss_dns.so.2`,
  `/${LIB}/libnss_files.so.2`,
  "/usr/share/locale/locale.alias",
  "/etc/ld.so.conf"
);

exec("find /etc/ld.so.conf.d -exec touch -ch {} \\;")

exec("find /usr/lib/gcc -name 'lib*.so*' -exec touch {} \\;");

f(
  "/usr/bin/locale",
  "/usr/bin/localedef",
  "/usr/sbin/locale-gen"
);
// generate locale archive
exec("echo 'en_US.UTF-8 UTF-8\nen_GB.UTF-8 UTF-8\nja_JP.UTF-8 UTF-8' > /etc/locale.gen");
exec("/usr/sbin/locale-gen");

f(
  `/usr/${LIB}/gconv/gconv-modules.cache`,
  `/usr/${LIB}/gconv/CP932.so`,
  `/usr/${LIB}/gconv/EUC-JISX0213.so`,
  `/usr/${LIB}/gconv/EUC-JP-MS.so`,
  `/usr/${LIB}/gconv/EUC-JP.so`,
  `/usr/${LIB}/gconv/IBM850.so`,
  `/usr/${LIB}/gconv/ISO-2022-JP-3.so`,
  `/usr/${LIB}/gconv/ISO-2022-JP.so`,
  `/usr/${LIB}/gconv/SJIS.so`,
  `/usr/${LIB}/gconv/UNICODE.so`,
  `/usr/${LIB}/gconv/UTF-16.so`,
  `/usr/${LIB}/gconv/UTF-32.so`,
  `/usr/${LIB}/gconv/UTF-7.so`,
  `/usr/${LIB}/gconv/libJIS.so`,
  `/usr/${LIB}/gconv/libJISX0213.so`
);

exec("ldconfig");
