
.PHONY: all clean

all: checker.exe

clean:
	rm -f *.exe *~

%.exe: %.cpp ../testlib-cms.h
	g++ $< -o $@ -O2 -Wall

