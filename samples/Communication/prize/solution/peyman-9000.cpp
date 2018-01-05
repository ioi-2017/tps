#include<bits/stdc++.h>
#include "prize.h"
#define X first
#define Y second
using namespace std;

typedef pair<int,int> pii;

int numb,cnt;
pii P[210000];
bool mark[210000];
vector<int>inp;

pii query(int x)
{
  if(mark[x]) return P[x];
  mark[x]=true;
  inp=ask(x);
  pii tmp=pii(inp[0],inp[1]);
  if(tmp.X+tmp.Y==0) throw x;
  return P[x]=tmp;
}

int bs(int l,int r,int nl,int nr)
{
  if((cnt--)<=0) return -1;
  if(l>r) return -1;
  for(int i=0;i<=r-l;i++)
    {
      int mid,midl=(l+r)/2-i/2,midr=(l+r)/2+(i+1)/2;
      if(i%2==0) mid=midl;
      else mid=midr;
      pii tmp=query(mid);
      if(tmp.X+tmp.Y>numb) {cnt=0;return -1;}
      if(tmp.X+tmp.Y==numb)
	{
	  int tmpl=(i%2==0?0:midr-midl);
	  int tmpr=(i%2==1?0:midr-midl);
	  if(tmp.X-tmpl>nl) return bs(l,midl-1,nl,tmp.Y+tmpl);
	  else if(i>0)
	    {
	      if(i%2==0) return midl+1;
	      else return midl;
	    }
	  return bs(midr+1,r,tmp.X+tmpr,nr);
	}
    }
  return l;
}

int find_best(int n)
{
  if(n==1) return 0;
  try{
    numb=1;
    cnt=20;
    bs(0,n-1,0,0);
    int p=0;
    for(int i=0;i<sqrt(n)+30 && i<n && numb<=26;i++)
      {
	pii tmp=query(i);
	if(tmp.X+tmp.Y>numb) p=i;
	numb=max(numb,tmp.X+tmp.Y);
      }
    cnt=1000000;
    int last=p-1;
    while(p<numb)
      {
	last=bs(last+1,n-1,p,0);
	p++;
      }
  }
  catch(int ans){
    return ans;
  }
}
