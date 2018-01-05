#include "testlib.h"
#include <vector>
using namespace std;

const int MAXGEN = 5, MAXN = 2e5;
int n, Q, max_gen, answer, t[MAXGEN+1], tl[MAXN+10][MAXGEN+1], tr[MAXN+10][MAXGEN+1];
string subtask;

#ifdef __GNUC__
__attribute__ ((format (printf, 2, 3)))
#endif
	void ensure_val(bool condition, const char *msg, ...) {
		if (!condition) {
			FMT_TO_RESULT(msg, msg, message);
			quitf(_fail, message.c_str());
		}
	}

void validate() {
	n = ouf.readInt();
	Q = ouf.readInt();
	answer = ouf.readInt();
	ouf.eoln();
	vector<int> p;
	for (int i=0; i<n; i++){
		p.push_back(ouf.readInt());
		max_gen = max(max_gen, p[i]);
		if(p[i]<1 || p[i]>MAXGEN)
			ensure_val(1<=p[i] && p[i]<=MAXGEN, "object in array is out of boundry");
		t[p[i]]++;
	}
	ensure_val(max_gen > 1, "max_gen is one");
	if(subtask == "v2")
		ensure_val(max_gen == 2, "for subtask v2, max_gen isn't 2");
	ensure_val(t[1]==1, "t[1]!=1");
	for(int i=2;i<=max_gen;i++)
		ensure_val(t[i-1] * t[i-1] < t[i], "t[i] <= t[i-1]*t[i-1]");
	for(int i=1;i<=n;i++)
		for(int j=1;j<=max_gen;j++)
			tl[i][j]=tl[i-1][j]+(p[i-1]<j);
	for(int i=n;i>0;i--)
		for(int j=1;j<=max_gen;j++)
			tr[i][j]=tr[i+1][j]+(p[i-1]<j);

	for (int i=0; i<Q; i++)
	{
		int index, left, right;
		index = ouf.readInt();
		left = ouf.readInt();
		right = ouf.readInt();
		ouf.eoln();
		ensure_val(tl[index][p[index]] == left && tr[index+2][p[index]] == right,	"manager answer wrong on query %d", i);
	}
}


NORETURN void qp(double grade) {
  quitp(grade/double(80), "number of queries: %d", Q);
}


int main(int argc, char * argv[])
{
	registerChecker("prize", argc, argv);
	subtask = inf.readWord();
	string result = ouf.readWord();
	ouf.eoln();
	if (result == _grader_SV) {
		quitf(_sv, "security violation in manager");
	}
	if (result == _grader_FAIL) {
		if (ouf.eof())
			quitf(_fail, "FAIL in manager");
		string msg = ouf.readLine();
		quitf(_fail, "FAIL in manager: %s", msg.c_str());
	}
	if (result == _grader_WA) {
	  string msg = ouf.readLine();
		validate();
		quitf(_wa, "%s", msg.c_str());
	}
	if (result == _grader_OK) {
		validate();
		if(subtask == "v2") {
			if(10000 < Q) quitf(_wa, "too many queries");
			quit(_ok);
		}
		else if(subtask == "no_limit") {
			if (10000 < Q)	quitf(_wa, "too many queries");
			if (6000 < Q)	qp(70.0);
			if (5000 < Q)	qp(80 - ((Q - 5000) / 100.0));
			quit(_ok);
		}
		else
			quitf(_fail, "unknown subtask '%s'", subtask.c_str());
	}
	quitf(_fail, "unknown manager result");
}
