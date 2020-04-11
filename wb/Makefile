default: all

all: wb

wb: wb.cpp
	g++ -o $@ -lgflags -lxenlight -lxentoollog -lpam -lpam_misc -lncursesw -lncurses++w -ltinfow -lpanelw -lmenuw -liniparser $<

clean:
	rm -f wb *.o
