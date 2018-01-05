#include<bits/stdc++.h>
#include "prize.h"
#define X first
#define Y second
using namespace std;

typedef pair<int,int> pii;

int numb, q_count = 5600;
pii P[210000];
bool mark[210000];
vector<int>vtmp;

pii query(int x)
{
  if(mark[x]) return P[x];
  mark[x]=true;
  q_count --;
  vtmp=ask(x);
  pii tmp=pii(vtmp[0],vtmp[1]);
  if(tmp.X+tmp.Y==0) throw x;
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
	  int tmpl=(i%2==0?0:midr-midl);
	  int tmpr=(i%2==1?0:midr-midl);
	  if(tmp.X-tmpl>nl) bs(l,midl-1,nl,tmp.Y+tmpl);
	  if(tmp.Y-tmpr>nr) bs(midr+1,r,tmp.X+tmpr,nr);
	  break;
	}
    }
}

int find_best(int n)
{
  if(n==1) return 0;
  try{
    numb=0;
    memset(mark,false,sizeof mark);
    int p=0;
    for(int i=0;i<sqrt(n)+30 && i<n && numb<27;i++)
      {
	pii tmp=query(i);
	if(tmp.X+tmp.Y>numb) p=i;
	numb=max(numb,tmp.X+tmp.Y);
      }
    bs(p,n-1,p,0);
  }
  catch(int ans){
    for(int i=0;i<q_count;i++)
      ask(0);
    return ans;
  }
  return -1;
}
