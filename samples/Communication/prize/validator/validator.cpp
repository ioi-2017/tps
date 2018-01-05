#include "testlib.h"
using namespace std;
const int MAXN = 200000, MAXGEN=5;
int n,t[10], v;
int main(int argc, char *argv[])
{
  registerValidation();
  string subtask = inf.readToken();
  ensuref(subtask == "v2" || subtask == "no_limit", "subtask is invalid");
  inf.readSpace();
  string type=inf.readToken();
  ensuref(type == "plain" || type == "adversary" || type == "adversary_random" || type == "adversary_antirandom" || type == "adversary_betterantirandom", "input type doesn't supported");
  inf.readEoln();
  if(type == "plain"){
    n = inf.readInt(3,MAXN,"n");
    v=0;
    inf.readEoln();
    for (int i = 0; i < n; i++)
      {
	int tmp = inf.readInt(1, MAXGEN, "gen[i]");
	if(i<n-1)
	  inf.readSpace();
	else
	  inf.readEoln();
	t[tmp]++;
	v=max(v,tmp);
      }
  }
  else if(type == "adversary" || type == "adversary_random" || type == "adversary_antirandom" || type == "adversary_betterantirandom")
    {
      if(type == "adversary_random" || type == "adversary_betterantirandom") {
	inf.readToken();
	inf.readEoln();
      }
      n = inf.readInt(3,MAXN,"n");
      inf.readSpace();
      if(type == "adversary_betterantirandom")
	v = inf.readInt(3, MAXGEN, "max_rank");
      else
	v = inf.readInt(2, MAXGEN,"max_rank");
      inf.readEoln();
      int sum = 0;
      for(int i=1;i<=v;i++)
	{
	  t[i]=inf.readInt(1,n,"t[i]");
	  sum += t[i];
	  if(i<v)
	    inf.readSpace();
	  else
	    inf.readEoln();
	}
      ensuref(sum == n, "number of prize doesn't match sum of number of each rank");
    }
  ensuref(t[1]==1, "t[1]!=1");
  for(int i=2;i<=v;i++)
    ensuref(t[i]>t[i-1]*t[i-1], "i=%d: t[i]<=t[i-1]*t[i-1]", i);
  inf.readEof();
  return 0;
}
