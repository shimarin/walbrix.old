default: all

all: wb

.cpp.o:
	g++ -std=c++2a -c $<
.c.o:
	gcc -c $<

wb: wb.o start.o monitor.o ui.o install.o termbox.o
	g++ -std=c++2a -o $@ -lgflags -lxenlight -lxentoollog -lxenstore -lpam -lpam_misc -liniparser4 -lsmartcols -lmount -lxlutil -lblkid $^

install: wb
	cp -a wb /usr/sbin/

clean:
	rm -f wb *.o
