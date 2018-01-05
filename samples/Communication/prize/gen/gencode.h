#include "testlib.h"
#include <iostream>

using namespace std;

typedef long long ll;
const int MAXN=2e5+10;
int n,q,gen,a[MAXN],t[10],lastspace;
string gen_number_arg, place_arg;

ll aftergen(ll fi,int remgen)
{
  ll ret=fi;
  for(int i=0;i<remgen;i++)
    {
      fi=fi*fi+1;
      ret+=fi;
      if(ret>MAXN) return ret;
    }
  return ret;
}

int MAX(int rem,int remgen)
{
  int l=1,r=rem;
  while(l<r)
    {
      int mid=(l+r+1)/2;
      if(aftergen(mid,remgen)>rem)
	r=mid-1;
      else
	l=mid;
    }
  return l;
}

void gen_number_count()
{
  t[1]=1;
  if(gen_number_arg=="min")
    {
      int rem=n-1;
      for(int i=2;i<gen;i++)
	{
	  t[i]=t[i-1]*t[i-1]+1;
	  rem-=t[i];
	}
      t[gen]=rem;
    }
  else if(gen_number_arg=="max")
    {
      int rem=n-1;
      for(int i=2;i<gen;i++)
	{
	  t[i]=MAX(rem,gen-i);
	  rem-=t[i];
	}
      t[gen]=rem;
    }
  else if(gen_number_arg=="random")
    {
      int rem=n-1;
      for(int i=2;i<gen;i++)
	{
	  t[i]=rnd.next(t[i-1]*t[i-1]+1,MAX(rem,gen-i));
	  rem-=t[i];
	}
      t[gen]=rem;
    }
  else exit(1);
}



void print()
{
  for(int i=0;i<n;i++){
    cout<<a[i];
    if(i<n-1)  cout<<' ';
    else cout<<'\n';
  }
}

void chap(int x,int y)
{
  for(int i=0;i<y;i++){
    lastspace++;
    cout<<x;
    if(lastspace<n) cout<<' ';
    else cout<<'\n';
  }
}

void choose_place()
{
  if(place_arg=="random")
    {
      int p=1;
      for(int i=0;i<n;i++)
	{
	  while(t[p]==0) p++;
	  t[p]--;
	  a[i]=p;
	}
      shuffle(a+0,a+n);
      print();
    }
  else if(place_arg=="pakhsh" || place_arg=="pakhsh4" || place_arg=="pakhshl" || place_arg=="pakhshr")
    {
      int p=0;
      for(int i=1;i<gen;i++)
	for(int j=0;j<t[i];j++)
	  a[p++]=i;

      if(place_arg=="pakhshl"){
	if(p>1) shuffle(a+1,a+p);}
      else if(place_arg=="pakhshr"){
	if(p>1){
	  swap(a[0],a[p-1]);
	  shuffle(a,a+p-1);
	}}
      else shuffle(a,a+p);
      
      int k=(n-p)/(p+1);
      if(place_arg=="pakhsh4") k=max(0,k-4);

      int sum=n-p-(p+1)*k;
      for(int i=0;i<p;i++)
	{
	  int x=rnd.next(0,sum/(p-i));
	  sum-=x;
	  chap(gen,k+x);
	  lastspace++;
	  cout<<a[i];
	  if(lastspace<n) cout<<' ';
	  else cout<<'\n';
	}
      chap(gen,sum+k);
    }
  else if(place_arg=="middle")
    {
      vector<int>v1,v2;
      for(int i=0;i<n;i++)
	v1.push_back(i);
      for(int i=gen;i>0;i--)
	{
	  int other=v1.size()-t[i];
	  int k=t[i]/(other+1),p=0;
	  for(int j=0;j<=other;j++)
	    {
	      for(int x=0;x<k+((j<t[i]%(other+1))?1:0);x++)
	        a[v1[p++]]=i;
	      if(j!=other) v2.push_back(v1[p++]);
	    }
	  v1=v2;
	  v2.clear();
	}
      print();
    }
  else if(place_arg=="notuniform")
    {
      vector<int>gens;
      for(int i=1;i<=gen;i++)
	gens.push_back(i);
      shuffle(gens.begin(),gens.end());
      for(int i=0;i<n;i++)
	{
	  while(t[gens.back()]==0)
	    gens.pop_back();
	  a[i]=gens.back();
	  t[gens.back()]--;
	}
      print(); 
    }
  else exit(1);
}


void generate(string subtask,int argc, char* argv[])
{
  string type = argv[1];
  cout<<subtask<<" "<<type<<"\n";
  n=atoi(argv[2]);
  gen=atoi(argv[3]);
  gen_number_arg=argv[4];
  if(type=="plain"){
    place_arg=argv[5];
    if(gen==1) cout<<1<<'\n'<<1<<'\n';
    else
      {
	cout<<n<<'\n';
	gen_number_count();
	choose_place();
      }
  }
  else if(type=="adversary" || type == "adversary_random" || type == "adversary_antirandom" || type == "adversary_betterantirandom")
    {
      if(type == "adversary_random" || type == "adversary_betterantirandom")
	cout<<rnd.next(0,100000)<<endl;
      cout<<n<<' '<<gen<<endl;
      gen_number_count();
      for(int i=1;i<=gen;i++)
	cout<<t[i]<<(i<gen?' ':'\n');
    }
}
