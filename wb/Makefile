default: all

all: wb

wb: wb.cpp
	g++ -o $@ -lgflags -lxenlight -lxentoollog -lpam -lpam_misc $<

clean:
	rm -f wb *.o
