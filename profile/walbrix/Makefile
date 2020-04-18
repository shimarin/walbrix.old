default: all

all: init.o ../common/initlib.o
	g++ -o /dev/null -lblkid -lmount -liniparser $^

.SUFFIXES:
.SUFFIXES: .cpp .o

.cpp.o:
	g++ -std=c++2a -I ../common -c $< -o $@

clean:
	rm -f *.o ../common/initlib.o
