default: all

all: wb

wb: wb.cpp start.cpp monitor.cpp
	g++ -std=c++2a -o $@ -lgflags -lxenlight -lxentoollog -lxenstore -lpam -lpam_misc -lncursesw -lncurses++w -ltinfow -lpanelw -lmenuw -liniparser -lsmartcols $^

clean:
	rm -f wb *.o
