#!/bin/sh
UNIT_FILE=/lib/systemd/system/tomcat.service

TOMCAT_VER=$(echo /usr/share/tomcat-*/conf|sed 's/^.\+\/\(tomcat-.\+\)\/.\+$/\1/')
TOMCAT_LIBS=$(java-config --query DEPEND --package=$TOMCAT_VER)
TOMCAT_CLASSPATH=$(java-config --with-dependencies --classpath "${TOMCAT_LIBS//:/,}"):/usr/share/$TOMCAT_VER/bin/bootstrap.jar:/usr/share/$TOMCAT_VER/bin/tomcat-juli.jar

echo -e '[Unit]\nDescription=Apache Tomcat\n\n[Service]' > $UNIT_FILE
echo "ExecStart=/usr/bin/java -cp $TOMCAT_CLASSPATH -Dcatalina.home=/usr/share/$TOMCAT_VER org.apache.catalina.startup.Bootstrap" >> $UNIT_FILE
echo -e 'User=tomcat\nGroup=tomcat\n\n[Install]\nWantedBy=multi-user.target' >> $UNIT_FILE

systemctl enable tomcat || exit 1

mkdir -p /var/lib/tomcat/work
mv /usr/share/$TOMCAT_VER/webapps /var/lib/tomcat/
mv /usr/share/$TOMCAT_VER/logs /var/log/tomcat
chown -R tomcat.tomcat /var/log/tomcat /var/lib/tomcat
chmod g+w /var/lib/tomcat/webapps

mv /usr/share/$TOMCAT_VER/conf /etc/tomcat

cd /usr/share/$TOMCAT_VER
ln -s ../../../var/lib/tomcat/webapps .
ln -s ../../../var/lib/tomcat/work .
ln -s ../../../var/log/tomcat logs
ln -s ../../../etc/tomcat conf

TOMCAT_VER_REV=$(cat /var/db/pkg/www-servers/tomcat-*/PF | sed 's/^tomcat-//' | sed 's/-r[0-9]\+$//')
wget https://repo1.maven.org/maven2/org/apache/tomcat/tomcat-dbcp/$TOMCAT_VER_REV/tomcat-dbcp-$TOMCAT_VER_REV.jar -O /usr/share/$TOMCAT_VER/lib/tomcat-dbcp.jar || exit 1
