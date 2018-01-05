// .... .... .....!
// ...... ......!
// .... ....... ..... ..!

#include<iostream>
#include<algorithm>
#include<cstdio>
#include<cmath>
#include<ctime>
#include<vector>
#include<set>
#include"testlib.h"
using namespace std;

#define rep(i, n) for (int i = 0, _n = (int)(n); i < _n; i++)
#define fer(i, x, n) for (int i = (int)(x), _n = (int)(n); i < _n; i++)
#define rof(i, n, x) for (int i = (int)(n), _x = (int)(x); i-- > _x; )
#define sz(x) (int((x).size()))
#define pb push_back
#define all(X) (X).begin(),(X).end()
#define X first
#define Y second

template<class P, class Q> inline void smin(P &a, Q b) { if (b < a) a = b; }
template<class P, class Q> inline void smax(P &a, Q b) { if (a < b) a = b; }

typedef long long ll;
typedef pair<int, int> pii;

////////////////////////////////////////////////////////////////////////////////

vector<int> make(int k, int sum) { // makes k numbers each >= 1
	sum -= k;
	vector<int> v(k);
	if(k == 0) return v;
	v.back() = sum;
	rep(i, k-1) v[i] = rnd.next(0, sum);
	sort(all(v));
	rof(i, k, 1) v[i] -= v[i-1];
	rep(i, k) v[i]++;
	return v;
}

vector<pii> tree_long(int n, int dia) {
	smax(dia, 1); smin(dia, n);
	vector<pii> e; e.reserve(n-1);
	fer(i, 1, dia) e.pb(pii(i, i-1));
	fer(i, dia, n) e.pb(pii(i, rnd.next(dia)));
	return e;
}

vector<pii> tree_beard(int n, int rootdeg) {
	smax(rootdeg, 1); smin(rootdeg, n-1);
	vector<pii> e; e.reserve(n-1);
	fer(i, 1, n) e.pb(pii(i, max(0, i - rootdeg)));
	return e;
}

vector<pii> tree_kite(int n, int rootdeg) {
	smax(rootdeg, 1); smin(rootdeg, n-1);
	vector<pii> e; e.reserve(n-1);
	fer(i, 1, rootdeg+1) e.pb(pii(i, 0));
	fer(i, rootdeg+1, n) e.pb(pii(i, i-1));
	return e;
}

vector<pii> tree_normal(int n) {
	vector<pii> e; e.reserve(n-1);
	fer(i, 1, n) e.pb(pii(i, rnd.next(i)));
	return e;
}

vector<pii> tree_knary(int n, int k) {
	smax(k, 1); smin(k, n-1);
	vector<pii> e; e.reserve(n-1);
	fer(i, 1, n) e.pb(pii(i, (i-1)/k));
	return e;
}

vector<pii> tree_sqrt(int n) {
	int k = 1; while(k*(k+1)/2 < n) k++;
	vector<pii> e; e.reserve(n-1);
	fer(i, 1, k) e.pb(pii(i, i-1));
	int cur = k;
	rep(i, k) {
		int prev = k-i-1;
		rep(j, i) if(cur < n)
			e.pb(pii(prev, cur)), prev = cur, cur++;
	}
	return e;
}


set<pii> se,tt;
vector<pii> edges;
vector<int> perm;

bool add_edge(int u, int v) {
	u = perm[u], v = perm[v];
	if(u > v) swap(u, v);
	if(se.find(pii(u, v)) != se.end()) return false;
	se.insert(pii(u, v));
	tt.insert(pii(u, v));
	if(rnd.next(2)) swap(u, v);
	edges.pb(pii(u, v));
	return true;
}

int main(int argc, char **argv) {
	ios_base::sync_with_stdio(false); cin.tie(0);
	registerGen(argc, argv);

	argc = argc;
	int q = atoi(argv[1]);
	int n = atoi(argv[2]);
	int m = atoi(argv[3]);
	string type = string(argv[4]);
	int p;
	if(type!="normal" && type!="sqrt") p = atoi(argv[5]);
    cout << "wrslcnopzlckvxbnair_input_simurgh_lmncvpisadngpiqdfngslcnvd" << endl;

	vector<pii> tree;
	if(type == "normal")	tree = tree_normal(n);
	if(type == "kite")		tree = tree_kite(n, p);
	if(type == "beard")		tree = tree_beard(n, p);
	if(type == "long")		tree = tree_long(n, p);
	if(type == "sqrt")      tree = tree_sqrt(n);
	if(type == "knary") 	tree = tree_knary(n, p);

	
	for(int i=0;i<n;i++)perm.push_back(i);
	shuffle(all(perm));
	rep(i, n-1) add_edge(tree[i].X, tree[i].Y);
	shuffle(all(edges));
	
	
	vector<pair<int,int> > graph;
	graph.clear();
	for(pii e: edges)graph.push_back(e);
	if(m<n*(n-1)/2){
		for(int i=1;i<=m-n+1;i++){
			while(true){
				int u=rnd.next(0,n-1);
				int v=rnd.next(0,n-1);
				if(u>v)swap(u,v);
				if(u!=v && se.find(pii(u,v)) == se.end()){
					se.insert(pii(u,v));
					if(rnd.next(0,1))graph.push_back(pii(u,v));
					else graph.push_back(pii(v,u));
					break;
				}
			}
		}
	}
	else{
		for(int i=1;i<=n*(n-1)/2 - m;i++){
			while(true){
				int u=rnd.next(0,n-1);
				int v=rnd.next(0,n-1);
				if(u>v)swap(u,v);
				if(u!=v && se.find(pii(u,v)) == se.end()){
					se.insert(pii(u,v));
					break;
				}
			}
		}
		for(int i=0;i<n;i++){
			for(int j=i+1;j<n;j++){
				if(se.find(pii(i,j)) == se.end()){
					if(rnd.next(0,1))graph.push_back(pii(i,j));
					else graph.push_back(pii(j,i));
				}
			}
		}
	}
	shuffle(all(graph));
	cout<<n<<" "<<m<<" "<<q<<endl;
	for(int i=0;i<m;i++){
		cout<<graph[i].X<<" "<<graph[i].Y<<endl;
	}
	vector<int> index;
	index.clear();
	for(int i=0;i<m;i++){
		int u=graph[i].X;
		int v=graph[i].Y;
		if(u>v)swap(u,v);
		if(tt.find(pii(u,v)) != tt.end()){
			index.push_back(i);
		}
	}
	shuffle(all(index));
	for(int i=0;i<n-1;i++){
		cout<<index[i];
		if(i!=n-2)cout<<" ";
	}
	cout<<endl;
	return 0;
}
