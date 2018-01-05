#include "testlib.h"
using namespace std;
#define For(i,a,b)	for(int (i) = (a); (i) < (b); ++ (i))

const int maxn = 21;
const int maxn2 = maxn*maxn;
typedef int board[maxn2][maxn2];

int n, n2;

inline void read_board(InStream &is, board& c, int& emp) {
	emp = 0;
	For(i,0, n2) {
		if (i>0 && !is.seekEoln())
			is.quitf(_pe, "no new line in row %d after cell %d", i, n2);
		For(j, 0, n2) {
			if (is.seekEoln())
				is.quitf(_pe, "invalid new line in row %d before cell %d", i+1, j+1);
			c[i][j] = is.readInt();
			if (c[i][j]<0 || c[i][j]>n2)
				is.quitf(_wa, "invalid cell value %d in row %d, col %d", c[i][j], i+1, j+1);
			c[i][j]--;
			if (c[i][j]<0)
				emp++;
		}
	}
}

board a, b;

inline void check_unique(string s, int si, int i1, int i2, int j1, int j2){
	vector<bool> mark(n2, false);
	For(i, i1, i2)
		For (j, j1, j2)
			if (b[i][j]>=0) {
				if (mark[b[i][j]])
					quitf(_wa, "value %d appears more than once in %s %d", b[i][j]+1, s.c_str(), si+1);
				else
					mark[b[i][j]] = true;
			}
}

int main(int argc, char ** argv){
	registerChecker("sudoku", argc, argv);
	n = inf.readInt();
	inf.seekEoln();
	if (n>maxn)
		quitf(_fail, "n=%d > maxn=%d", n, maxn);
	n2 = n*n;
	int aemp, bemp;
	read_board(inf, a, aemp);
	read_board(ouf, b, bemp);
	
	For(i,0, n2)
		For(j, 0, n2)
			if(a[i][j]>=0 && b[i][j] != a[i][j])
				quitf(_wa, "Non-empty cell A[%d][%d]=%d has a different value in B: %d", i+1, j+1, a[i][j]+1, b[i][j]+1);
	
	For(i,0,n2)
		check_unique("row", i, i, i+1, 0, n2);
	
	For(j,0,n2)
		check_unique("column", j, 0, n2, j, j+1);
	
	For(i,0,n)
		For(j,0,n)
			check_unique("block", i*n+j, i*n, (i+1)*n, j*n, (j+1)*n);
	
	if (aemp==0)
		aemp = 1;
	quitp(double(aemp-bemp)/aemp);
	return 0;
}
