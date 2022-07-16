g++ -g -O1 -std=gnu++1y -Wall -fstack-protector -D_FORTIFY_SOURCE=2 -fPIE -Wformat -Wformat-security -pedantic -fPIE -Wl,-z,relro -Wl,-z,now "checker.cpp" -o "run"
