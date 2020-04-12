default: all

all: wb

wb: wb.cpp start.cpp
	g++ -std=c++2a -o $@ -lgflags -lxenlight -lxentoollog -lpam -lpam_misc -lncursesw -lncurses++w -ltinfow -lpanelw -lmenuw -liniparser $^

clean:
	rm -f wb *.o
