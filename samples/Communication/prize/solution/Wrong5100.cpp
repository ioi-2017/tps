#include <vector>
#include <cstring>
#include "prize.h"
#define X first
#define Y second
using namespace std;

typedef pair<int,int> pii;

int ans,numb;
pii P[210000];
bool mark[210000];

vector<int>vtmp;

pii query(int x)
{
  if(mark[x]) return P[x];
  mark[x]=true;
  vtmp=ask(x);
  pii tmp=pii(vtmp[0],vtmp[1]);
  if(tmp.X+tmp.Y==0) ans=x;
  return P[x]=tmp;
}

void bs(int l,int r,int nl,int nr)
{
  if(l>r) return;
  for(int i=0;i<=r-l;i++)
    {
      int mid,midl=(l+r)/2-i/2,midr=(l+r)/2+(i+1)/2;
      if(i%2==0) mid=midl;
      else mid=midr;
      pii tmp=query(mid);
      if(tmp.X+tmp.Y==numb)
	{
	  if(tmp.X>nl) bs(l,midl-1,nl,tmp.Y);
	  if(tmp.Y>nr) bs(midr+1,r,tmp.X,nr);
	  break;
	}
    }
}

int find_best(int n)
{
  if(n==1) return 0;
  numb=ans=0;
  memset(mark,false,sizeof mark);
  int p=0;
  for(int i=0;i<474 && i<n;i++)
    {
      pii tmp=query(i);
      if(tmp.X+tmp.Y>numb) p=i;
      numb=max(numb,tmp.X+tmp.Y);
    }
  bs(p,n-1,p,0);
  return ans;
}
