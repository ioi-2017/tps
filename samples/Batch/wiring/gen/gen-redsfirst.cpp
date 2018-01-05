#include "testlib.h"
#include<iostream>
#include<set>
#include<vector>
#include<algorithm>
#include<cassert>

using namespace std;

const int maxn=2000000+10, MAX = 1e9, MAXN = 1e5;
static const string input_secret = "071e691ce5776974f655a51a364bf5ca";

int val[maxn];
set<int> s;

int main(int argc, char **argv) {
	registerGen(argc, argv, 0);

	printf("%s\n", input_secret.c_str());

	argc = argc;
	
	int n = atoi(argv[1]);
	int m = atoi(argv[2]);
	int range = atoi(argv[3]) + 1;

	vector<int> pos,red,blue;

	assert(range > n + m);

	for(int i=0;i<n+m;i++){
		int x;
		while(true){
			x=rnd.next(0,range);
			if(s.find(x)==s.end())break;
		}
		pos.push_back(x);
		s.insert(x);
	}

	sort(pos.begin(),pos.end());
	
	vector<int> perm;
	for(int i=0;i<n+m;i++)perm.push_back(i);
	shuffle(perm.begin(),perm.end());

	
	int cur=0;
	bool mark=true;
	int step=0;
	int comp = n + m + 1;
	while(cur!=n+m){
		step++;
		if(mark){
			int bl=red.size();
			if(comp>n-red.size()){
				for(int i=cur;i<cur+n-bl;i++)red.push_back(pos[i]);	
				cur+=n-bl;
			}
			else{
				int x=rnd.next(comp,n-bl);
				for(int i=cur;i<cur+x;i++)red.push_back(pos[i]);
				cur+=x;
			}
		}
		else{
			int re=blue.size();
			if(comp>m-blue.size()){
				for(int i=cur;i<cur+m-re;i++)blue.push_back(pos[i]);
				cur+=m-re;
			}
			else{
				int x=rnd.next(comp,m-re);
				for(int i=cur;i<cur+x;i++)blue.push_back(pos[i]);
				cur+=x;
			}
		}
		mark=1-mark;
	}

//	fprintf(stderr, "%d %d %d %d %d %d %d Generated!\n", n, m, comp, range, gap, l, r);
	assert(n == red.size());
	assert(m == blue.size());
	assert(blue[0] > red.back());
	int x = min(n, m)/10;
	for(int i = 0; rnd.next(x - i + 1); i++)
	{
		assert(min(blue.size(), red.size()) > 0);
		if(rnd.next(2))
		{
			blue.push_back(red.back());
			red.pop_back();
			rotate(blue.begin(), blue.end() - 1, blue.end());
		}
		else
		{
			red.push_back(blue[0]);
			blue[0] = blue.back();
			blue.pop_back();
			rotate(blue.begin(), blue.begin() + 1, blue.end());
		}
	}
	while(red.size() > MAXN)
		red.pop_back();
	while(blue.size() > MAXN)
		blue.pop_back();
	assert(blue[0] > red.back());
	n = red.size();
	m = blue.size();
	cout << n << " " << m << endl;
	for(int i = 0; i < n; i++) cout << red[i] << (i + 1 == n ? "\n" : " ");
	for(int i = 0; i < m; i++) cout << blue[i] << (i + 1 == m ? "\n" : " ");
	return 0;
}
