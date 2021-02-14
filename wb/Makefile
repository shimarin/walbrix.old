default: all

all: wb wbc walbrixd wg-walbrix

.cpp.o:
	g++ -std=c++2a -c $<

.c.o:
	gcc -c $<

wb: wb.o start.o monitor.o ui.o install.o termbox.o
	g++ -std=c++2a -o $@ -lxenlight -lxentoollog -lxenstore -lpam -lpam_misc -liniparser4 -lsmartcols -lmount -lxlutil -lblkid $^

wbc: wbc.o console.o terminal.o uicontext.o status.o shutdown.o installer.o messagebox.o -lblkid -lmount
	g++ -std=c++2a -o $@ -lutil -licuuc -lSDL2 -lSDL2_image -lSDL2_ttf -lvterm -lpam $^

walbrixd: walbrixd.o
	g++ -std=c++2a -o $@ $^ -lsystemd -lutil

wg-walbrix: wg-walbrix.o
	g++ -std=c++2a -o $@ $^ -lsystemd -lutil -lPocoNet -lPocoNetSSL -lPocoFoundation -lPocoJSON -lssl -lcrypto

install: wb wbc walbrixd walbrixd.service walbrixd.conf wg-walbrix wg-walbrix.service wg-walbrix.conf
	cp -a wb wbc walbrixd wg-walbrix /usr/sbin/
	cp -a walbrixd.service wg-walbrix.service /lib/systemd/system/
	cp -a walbrixd.conf wg-walbrix.conf /etc/dbus-1/system.d/
	mkdir -p /usr/share/wb/themes/default
	cp -a default_theme/. /usr/share/wb/themes/default/

clean:
	rm -f wb wbc walbrixd wg-walbrix *.o *.gch
