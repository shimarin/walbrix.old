default: all

all: wb wbc walbrixd

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

install: wb wbc walbrixd walbrixd.service walbrixd.conf
	cp -a wb wbc walbrixd /usr/sbin/
	cp -a walbrixd.service /lib/systemd/system/
	cp -a walbrixd.conf /etc/dbus-1/system.d/
	mkdir -p /usr/share/wb/themes/default
	cp -a default_theme/. /usr/share/wb/themes/default/

clean:
	rm -f wb wbc walbrixd *.o *.gch
