#include "testlib.h"
#include<iostream>
#include<set>
#include<vector>
#include<algorithm>
#include<cassert>

using namespace std;

const int maxn=2000000+10, MAX = 1e9;
static const string input_secret = "071e691ce5776974f655a51a364bf5ca";

int val[maxn];
set<int> s;

int main(int argc, char **argv) {
	registerGen(argc, argv, 0);

	printf("%s\n", input_secret.c_str());
	argc = argc;
	
	int n = atoi(argv[1]);
	int m = atoi(argv[2]);
	int comp = atoi(argv[3]);
	int range = atoi(argv[4]) + 1;
	int gap = atoi(argv[5]);
	int l = atoi(argv[6]);
	int r = atoi(argv[7]);
	int maxComp = atoi(argv[8]);
	vector<int> pos,red,blue;

	for(int i=0;i<n+m;i++){
		int x = i + 1;
		pos.push_back(x);
		s.insert(x);
	}

	sort(pos.begin(),pos.end());
	
	int cur=0;
	bool mark=0;
	int step=0;
	while(cur!=n+m){
		step++;
		if(mark){
			int bl=red.size();
			if(comp>n-red.size()){
				for(int i=cur;i<cur+n-bl;i++)red.push_back(pos[i]);
				cur+=n-bl;
			}
			else{
				int x=rnd.next(comp,min(n-bl, maxComp));
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
				int x=rnd.next(comp,min(m-re, maxComp));
				for(int i=cur;i<cur+x;i++)blue.push_back(pos[i]);
				cur+=x;
			}
		}
		mark=1-mark;
	}

	if(rnd.next(2))
		red.swap(blue);
	fprintf(stderr, "%d %d %d %d %d %d %d %d Generated!\n", n, m, comp, range, gap, l, r, maxComp);
	n = red.size();
	m = blue.size();
	cout << n << " " << m << endl;
	for(int i = 0; i < n; i++) cout << red[i] << (i + 1 == n ? "\n" : " ");
	for(int i = 0; i < m; i++) cout << blue[i] << (i + 1 == m ? "\n" : " ");
	return 0;
}

