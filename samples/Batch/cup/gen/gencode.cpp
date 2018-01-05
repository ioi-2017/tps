#include <cassert>
#include <string>
#include <vector>
#include <set>
#include <iostream>
#include "testlib.h"
#define X first
#define Y second

using namespace std;

typedef pair<long long,long long> pii;
const long long maxn=500000000;
long long a[2],b[2],c[2],cnt,f1[3]={maxn,maxn+1,2*maxn},f2[3]={1,1,2};
pii P[100000];

bool validate()
{
  if(P[cnt].X<(-maxn) || P[cnt].X>maxn || P[cnt].Y<(-maxn) || P[cnt].Y>maxn)
    return false;
  return true;
}

void generate()
{
  a[0]=a[1]=-2;
  for(int i=0;i<25;i++){
    P[cnt].X=a[0],P[cnt].Y=a[1];
    cnt++;
    a[1]++;
    if(a[1]==3) a[0]++,a[1]=-2;
  }
  c[0]=1070596096,c[1]=c[0]/2;
  for(int z=0;z<=2;z++)
    for(int k=0;k<2;k++){
      a[0]=a[1]=-1;
      for(int i=0;i<9;i++){
	b[0]=b[1]=-1;
	for(int j=0;j<9;j++)
	  {
	    P[cnt].X=f1[z]*a[0]+f2[z]*c[k]*b[0],P[cnt].Y=f1[z]*a[1]+f2[z]*c[k]*b[1];
	    if(validate())
	    cnt++;
	    b[1]++;
	    if(b[1]==2) b[0]++,b[1]=-1;
	  }
	a[1]++;
	if(a[1]==2) a[0]++,a[1]=-1;
      }
    }
  sort(P,P+cnt);
  cnt=unique(P,P+cnt)-P;
}

int main(int argc, char** argv) {
  ios_base::sync_with_stdio(false); cin.tie(0);
  cout << "e8a66651-560d-46a7-9496-0782b8bb7081\n";
  registerGen(argc, argv,1);

  long long numb=atoi(argv[1]);
  generate();
  long long lim=maxn;
  for(;cnt<numb-100;cnt++)
    P[cnt].X=rnd.next(-lim,+lim),P[cnt].Y=rnd.next(-lim,+lim);
  lim=10000;
  for(;cnt<numb+100;cnt++)
    P[cnt].X=rnd.next(-lim,+lim),P[cnt].Y=rnd.next(-lim,+lim);
  sort(P,P+cnt);
  cnt=unique(P,P+cnt)-P;
  shuffle(P,P+cnt);
  cnt=min(cnt,numb);
  cout<<cnt<<endl;
  for(int i=0;i<cnt;i++)
    cout<<P[i].X<<" "<<P[i].Y<<endl;
}

