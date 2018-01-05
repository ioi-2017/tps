#include "testlib.h"
using namespace std;
const int MAXN = 200000, MAXGEN=2;
int n,v;
int main(int argc, char *argv[])
{
  registerValidation();
  inf.readToken("v2", "subtask isn't v2");
  inf.readSpace();
  string type=inf.readToken();
  inf.readEoln();
  if(type == "plain"){
    n = inf.readInt(3,MAXN,"n");
    inf.readEoln();
    v=0;
    for (int i = 0; i < n; i++)
      {
	int tmp = inf.readInt(1, MAXGEN, "gen[i]");
	if(i<n-1)
	  inf.readSpace();
	else
	  inf.readEoln();
	v=max(v, tmp);
      }
    ensuref(v==2, "in subtask v2, v must be 2");
  }
  else if(type == "adversary" || type == "adversary_random" || type == "adversary_antirandom" || type == "adversary_betterantirandom")
    {
      if(type == "adversary_random" || type == "adversary_betterantirandom") {
	// read seed
	inf.readToken();
	inf.readEoln();
      }
      n = inf.readInt(3,MAXN,"n");
      inf.readSpace();
      v = inf.readInt(2,MAXGEN,"v");
    }
  skip_ok();
  return 0;
}
