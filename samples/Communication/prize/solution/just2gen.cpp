#include <vector>
#include "prize.h"
#define X first
#define Y second
using namespace std;

typedef pair<int,int> pii;
vector<int>inp;

int bs(int l,int r)
{
  int mid=(l+r)/2;
  inp=ask(mid);
  pii tmp=pii(inp[0],inp[1]);
  if(tmp.X+tmp.Y!=1) return mid;
  if(tmp.X) return bs(l,mid-1);
  return bs(mid+1,r);
}

int find_best(int n)
{
  return bs(0,n-1);
}
