default: all

all: wb wbc walbrixd

.cpp.o:
	g++ -std=c++2a -c $<
.c.o:
	gcc -c $<

wb: wb.o start.o monitor.o ui.o install.o termbox.o
	g++ -std=c++2a -o $@ -lxenlight -lxentoollog -lxenstore -lpam -lpam_misc -liniparser4 -lsmartcols -lmount -lxlutil -lblkid $^

wbc: wbc.o console.o terminal.o
	g++ -std=c++2a -o $@ -lutil -licuuc -lSDL2 -lSDL2_ttf -lvterm $^

walbrixd: walbrixd.o
	g++ -std=c++2a -o $@ $^ -lsystemd -lutil

install: wb wbc walbrixd
	cp -a wb wbc walbrixd /usr/sbin/

clean:
	rm -f wb wbc walbrixd *.o *.gch
