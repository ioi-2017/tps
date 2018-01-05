#include<cstring>
#include<vector>
#include "testlib.h"

using namespace std;

const int MAXN = 5e8;

int main(){
	registerValidation();
	inf.readLine();
	int T = inf.readInt(1, 1000, "T");inf.readEoln();
	while(T--){
		int x=inf.readInt(-MAXN,MAXN,"x");
		inf.readSpace();
		int y=inf.readInt(-MAXN,MAXN,"y");
		inf.readEoln();
	}
	inf.readEof();
	return 0;
}
