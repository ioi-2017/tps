all: checker.exe

clean:
	rm -f *.exe *~

%.exe: %.cpp testlib.h
	g++ $< -o $@ -O2 -Wall

