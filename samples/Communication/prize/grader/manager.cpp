#include <iostream>
#include <fstream>
#include <vector>
#include <algorithm>
#include <cstdio>
#include <set>
#include <cmath>

using namespace std;

#define forv(i, v) for (int i=0; i<int((v).size()); i++)
#define X first
#define Y second
#define MP make_pair

typedef pair<int,int> pii;
FILE *fin;
FILE *fout;

vector<pair<int,pii> > queries;
int n, answer=-1;
const int maxq=10000, maxgen=5;

struct ManagerStrategy {
    virtual void read_input(istream& in)=0;
    virtual pii ask(int index)=0;
    virtual bool isBest(int index)=0;
    virtual vector<int> get_levels()=0;
} *strategy;

inline void finish() {
  cout << n << " " << queries.size() << " " << answer << endl;
  vector<int> levels = strategy->get_levels();
  forv(i, levels)
    cout << (i>0?" ":"") << levels[i];
  cout << endl;
  forv(i, queries)
    cout << queries[i].X << " " << queries[i].Y.X << " " << queries[i].Y.Y << endl;
  cout.flush();
}

inline void doubleWrite(string code, string msg) {
  cout << code << endl << msg << endl;
#ifdef ERRLOG
  cerr << code << endl << msg << endl;
#endif
}

inline void die(string code, string msg, bool sendDie) {
    if (sendDie) {
      fprintf(fout, "%d %d\n", -1, -1);
      fflush(fout);
    }
    doubleWrite(code, msg);
    finish();
    exit(0);
}

const string OK ="OK";
const string WA = "WA";
const string FAIL = "FAIL";

inline int readValidIndex(string cmd, bool sendDie) {
    int index;
    if (fscanf(fin, "%d", &index) != 1) {
      die(WA, "io error, could not read index", sendDie);
    }
#ifdef ERRLOG
    cerr << cmd << " " << index << endl;
#endif
    if (index < 0 || index>=n) {
        die(WA, "invalid index" , sendDie);
    }
    return index;
}

struct ManagerStrategy_Plain : public ManagerStrategy {
    vector<int> g;
    vector<vector<int> > rank_count;

    virtual void read_input(istream& cin) {
      cin >> n ;

        g.resize(n);
        for (int i = 0; i < n; i++) {
            cin >> g[i];
        }

        int max_rank = *max_element(g.begin(), g.end());
        rank_count.resize(max_rank + 1, vector<int>(n + 1, 0));
        for (int r = 0; r <= max_rank; r++) {
            for (int i = 1; i <= n; i++) {
                rank_count[r][i] = rank_count[r][i - 1] + int(g[i - 1] == r);
            }
        }

        for (int i = 0; i <= n; i++) {
            for (int r = 1; r <= max_rank; r++) {
                rank_count[r][i] += rank_count[r - 1][i];
            }
        }
    }
    virtual pii ask(int i) {
        pii result;
        result.first = rank_count[g[i] - 1][i + 1];
        result.second = rank_count[g[i] - 1][n] - result.first;
        return result;
    }
    virtual bool isBest(int index) {
        return g[index] == 1;
    }
    virtual vector<int> get_levels(){
        return g;
    }
};

struct ManagerStrategy_Adversary : public ManagerStrategy {
  int max_rank;
  vector<int>num;
  set<int>s[maxgen+1];
  vector<vector<int> >t;
  virtual void read_input(istream& cin) {
      cin >> n >> max_rank;
      num.resize(max_rank+1, 0);
        for (int i = 1; i <=max_rank ; i++){
	  cin>>num[i];
	  num[i]+=num[i-1];
	}
      t.resize(max_rank + 1, vector<int>(n + 2, 0));
      for(int i=2;i<=max_rank;i++){
	s[i].insert(0);
	s[i].insert(num[i]+1);
	t[i][num[i]+1]=num[i]-num[i-1]+1;
      }
    }
    virtual pii ask(int x) {
      x++;
      for(int i = max_rank; i > 1; i--)
	{
	  set<int>:: iterator it = s[i].lower_bound(x);
	  int r = (*it);
	  int l = (*(--it));
	  if(r == x) return pii(x-t[i][x], num[i-1]-(x-t[i][x]));
	  if(t[i][r] > t[i][l] + 1) {
	      s[i].insert(x);
	      if(r-l-2==0) t[i][x] = t[i][l] + 1;
	      else t[i][x] = t[i][l] + 1 + round(((double)t[i][r]-t[i][l]-2)*(x-l-1)/(r-l-2));
	      return pii(x-t[i][x], num[i-1]-(x-t[i][x]));
	    }
	  else {
	    x -= t[i][l];
	  }
	}
      return pii(0,0);
    }
    virtual bool isBest(int index) {
      pii tmp = ask(index);
      return (tmp.X + tmp.Y == 0);
    }
    virtual vector<int> get_levels(){
      vector<int> ret;
      ret.resize(n);
      for(int i=0;i<n;i++)
	{
	  pii tmp=ask(i);
	  for(int j=1;j<=max_rank;j++)
	    if(tmp.X+tmp.Y==num[j-1])
	      ret[i]=j;
	}
      return ret;
    }
};


struct ManagerStrategy_AdversaryRandom : public ManagerStrategy {
  int max_rank;
  vector<int>num, tmp_place;
  set<int>s[maxgen+1];
  vector<vector<int> >t, here;
  vector<pii> g;
  virtual void read_input(istream& cin) {
      int seed_rand;
      cin>>seed_rand;
      srand(seed_rand);
      cin >> n >> max_rank;
      g.resize(n+1,pii(-1,-1));
      num.resize(max_rank+1, 0);
        for (int i = 1; i <=max_rank ; i++){
	  cin>>num[i];
	  num[i]+=num[i-1];
	}
      t.resize(max_rank + 1, vector<int>(n + 2, 0));
      here.resize(max_rank + 1, vector<int>(n + 2, 0));
      for(int i=2;i<=max_rank;i++){
	s[i].insert(0);
	s[i].insert(num[i]+1);
	t[i][num[i]+1]=num[i]-num[i-1];
      }
    }
    virtual pii ask(int x) {
      x++;
      //cout<<x<<": ";
      int index=x;
      if(g[x]!=pii(-1,-1)) return g[x];
      tmp_place.clear();
      for(int i = max_rank; i > 1; i--)
	{
	  set<int>:: iterator it = s[i].lower_bound(x);
	  int r = (*it);
	  int l = (*(--it));
	  int p = rand() % (r-l-1);
	  if(t[i][r] > t[i][l] + here[i][l] && p<t[i][r]-t[i][l]-here[i][l]) {
	      s[i].insert(x);
	      if(r-l-2 == 0) t[i][x] = t[i][l] + here[i][l];
	      else t[i][x] = t[i][l] + here[i][l] + round(((double)t[i][r] - t[i][l] - 1 - here[i][l]) * (x - l - 1) / (r - l - 2));
	      g[index] = pii(x-t[i][x]-1, num[i-1]-(x-t[i][x]-1));
	      here[i][x] = 1;
	      // cout<<g[index].X<<"--1--"<<g[index].Y<<endl;
	      return g[index];
	    }
	  else {
	    tmp_place.push_back(x);
	    s[i].insert(x);
	    if(r-l-2 == 0) t[i][x] = t[i][l] + here[i][l];
	    else t[i][x] = t[i][l] + here[i][l] + round(((double)t[i][r] - t[i][l] - here[i][l]) * (x - l - 1) / (r - l - 2));
	    x -= t[i][x];
	  }
	}
      for(int i = 0;i<(int)tmp_place.size();i++)
	  s[max_rank-i].erase(tmp_place[i]);
      x=index;
      for(int i = max_rank; i > 1; i--)
	{
	  set<int>:: iterator it = s[i].lower_bound(x);
	  int r = (*it);
	  int l = (*(--it));
	  if(t[i][r] > t[i][l] + here[i][l]) {
	    s[i].insert(x);
	    if(r-l-2 == 0) t[i][x] = t[i][l] + here[i][l];
	    else t[i][x] = t[i][l] + here[i][l] + round(((double)t[i][r] - t[i][l] - 1 - here[i][l]) * (x - l - 1) / (r - l - 2));
	    g[index] = pii(x-t[i][x]-1, num[i-1]-(x-t[i][x]-1));
	    here[i][x] = 1;
	    //cout<<g[index].X<<"--2--"<<g[index].Y<<endl;
	    return g[index];
	  }
	  else {
	    s[i].insert(x);
	    if(r-l-2 == 0) t[i][x] = t[i][l] + here[i][l];
	    else t[i][x] = t[i][l] + here[i][l] + round(((double)t[i][r] - t[i][l] - here[i][l]) * (x - l - 1) / (r - l - 2));
	    x -= t[i][x];
	  }
	}
      g[index] = pii(0, 0);
      //cout<<g[index].X<<"--3--"<<g[index].Y<<endl;
      return g[index];
    }
    virtual bool isBest(int index) {
      pii tmp = ask(index);
      return (tmp.X + tmp.Y == 0);
    }
    virtual vector<int> get_levels(){
      vector<int> ret;
      ret.resize(n);
      for(int i=0;i<n;i++)
	{
	  pii tmp=ask(i);
	  for(int j=1;j<=max_rank;j++)
	    if(tmp.X+tmp.Y==num[j-1])
	      ret[i]=j;
	}
      return ret;
    }
};


struct ManagerStrategy_AdversaryAntiRandom : public ManagerStrategy {
  int max_rank;
  vector<int>num, tmp_place;
  set<int>s[maxgen+1];
  vector<vector<int> >t, here;
  vector<pii> g;
  virtual void read_input(istream& cin) {
      cin >> n >> max_rank;
      g.resize(n+1,pii(-1,-1));
      num.resize(max_rank+1, 0);
        for (int i = 1; i <=max_rank ; i++){
	  cin>>num[i];
	  num[i]+=num[i-1];
	}
      t.resize(max_rank + 1, vector<int>(n + 2, 0));
      here.resize(max_rank + 1, vector<int>(n + 2, 0));
      for(int i=2;i<=max_rank;i++){
	s[i].insert(0);
	s[i].insert(num[i]+1);
	t[i][num[i]+1]=num[i]-num[i-1];
      }
    }
    virtual pii ask(int x) {
      x++;
      int index=x;
      if(g[x]!=pii(-1,-1)) return g[x];
      tmp_place.clear();
      for(int i = max_rank; i > 1; i--)
	{
	  set<int>:: iterator it = s[i].lower_bound(x);
	  int r = (*it);
	  int l = (*(--it));
	  int p = 0;
	  if(i == max_rank)
	    p = r-l-2;
	  if(t[i][r] > t[i][l] + here[i][l] && p<t[i][r]-t[i][l]-here[i][l]) {
	      s[i].insert(x);
	      if(r-l-2 == 0) t[i][x] = t[i][l] + here[i][l];
	      else t[i][x] = t[i][l] + here[i][l] + round(((double)t[i][r] - t[i][l] - 1 - here[i][l]) * (x - l - 1) / (r - l - 2));
	      g[index] = pii(x-t[i][x]-1, num[i-1]-(x-t[i][x]-1));
	      here[i][x] = 1;
	      return g[index];
	    }
	  else {
	    tmp_place.push_back(x);
	    s[i].insert(x);
	    if(r-l-2 == 0) t[i][x] = t[i][l] + here[i][l];
	    else t[i][x] = t[i][l] + here[i][l] + round(((double)t[i][r] - t[i][l] - here[i][l]) * (x - l - 1) / (r - l - 2));
	    x -= t[i][x];
	  }
	}
      for(int i = 0;i<(int)tmp_place.size();i++)
	  s[max_rank-i].erase(tmp_place[i]);
      x=index;
      for(int i = max_rank; i > 1; i--)
	{
	  set<int>:: iterator it = s[i].lower_bound(x);
	  int r = (*it);
	  int l = (*(--it));
	  if(t[i][r] > t[i][l] + here[i][l]) {
	    s[i].insert(x);
	    if(r-l-2 == 0) t[i][x] = t[i][l] + here[i][l];
	    else t[i][x] = t[i][l] + here[i][l] + round(((double)t[i][r] - t[i][l] - 1 - here[i][l]) * (x - l - 1) / (r - l - 2));
	    g[index] = pii(x-t[i][x]-1, num[i-1]-(x-t[i][x]-1));
	    here[i][x] = 1;
	    return g[index];
	  }
	  else {
	    s[i].insert(x);
	    if(r-l-2 == 0) t[i][x] = t[i][l] + here[i][l];
	    else t[i][x] = t[i][l] + here[i][l] + round(((double)t[i][r] - t[i][l] - here[i][l]) * (x - l - 1) / (r - l - 2));
	    x -= t[i][x];
	  }
	}
      g[index] = pii(0, 0);
      return g[index];
    }
    virtual bool isBest(int index) {
      pii tmp = ask(index);
      return (tmp.X + tmp.Y == 0);
    }
    virtual vector<int> get_levels(){
      vector<int> ret;
      ret.resize(n);
      for(int i=0;i<n;i++)
	{
	  pii tmp=ask(i);
	  for(int j=1;j<=max_rank;j++)
	    if(tmp.X+tmp.Y==num[j-1])
	      ret[i]=j;
	}
      return ret;
    }
};


struct ManagerStrategy_AdversaryBetterAntiRandom : public ManagerStrategy {
  int max_rank, num[6],sumnum[6];
  vector<pii>g;
  vector<int>gen2,vec,mark;
  vector<vector<int> >t;
  set<int>s[maxgen+1];
  virtual void read_input(istream& cin) {
    int seed_rand;
    cin>>seed_rand;
    srand(seed_rand);
    cin >> n >> max_rank;
    for(int i=1;i<=max_rank;i++){
      cin>>num[i];
      sumnum[i]=sumnum[i-1]+num[i];
    }
    mark.resize(n,-1);
    g.resize(n,pii(-1,-1));
    while(vec.size()<sumnum[max_rank-2])
      {
	int tmp=rand()%n;
	if(mark[tmp] == -1){
	  mark[tmp]=0;
	  vec.push_back(tmp);
	}
      }
    sort(vec.begin(),vec.end());
    for(int i=0;i<vec.size();i++) mark[vec[i]]=i+1;
    t.resize(max_rank - 1, vector<int>(sumnum[max_rank-2] + 2, 0));
    for(int i=2;i<=max_rank-2;i++){
      s[i].insert(0);
      s[i].insert(sumnum[i]+1);
      t[i][sumnum[i]+1]=num[i]+1;
    }
  }
  virtual pii ask(int x) {
    if(g[x].X!=-1) return g[x];
    int index = x;
    
    if(mark[x] != -1){
      x = mark[x];
      for(int i = max_rank-2; i > 1; i--)
	{
	  set<int>:: iterator it = s[i].lower_bound(x);
	  int r = (*it);
	  int l = (*(--it));
	  if(r == x) return pii(x-t[i][x], sumnum[i-1]-(x-t[i][x]));
	  if(t[i][r] > t[i][l] + 1) {
	      s[i].insert(x);
	      if(r-l-2==0) t[i][x] = t[i][l] + 1;
	      else t[i][x] = t[i][l] + 1 + round(((double)t[i][r]-t[i][l]-2)*(x-l-1)/(r-l-2));
	      return g[index] = pii(x-t[i][x], sumnum[i-1]-(x-t[i][x]));
	    }
	  else {
	    x -= t[i][l];
	  }
	}
      return g[index] = pii(0,0);
    }
    
    if(gen2.size()<num[max_rank-1]){
      gen2.push_back(x);
      if(gen2.size() == num[max_rank-1]) sort(gen2.begin(),gen2.end());
      int less_than = lower_bound(vec.begin(),vec.end(),x) - vec.begin();
      return g[x]=pii(less_than, sumnum[max_rank-2] - less_than);
    }
    
    int tmp = lower_bound(gen2.begin(),gen2.end(),x)-gen2.begin();
    tmp += lower_bound(vec.begin(),vec.end(),x) - vec.begin();
    return g[x]=pii(tmp, sumnum[max_rank-1]-tmp);
  }
  virtual bool isBest(int index) {
    pii tmp = ask(index);
    return (tmp.X + tmp.Y == 0);
  }
  virtual vector<int> get_levels(){
    vector<int> ret;
    ret.resize(n);
    for(int i=0;i<n;i++)
      {
	pii tmp=ask(i);
	for(int j=1;j<=max_rank;j++)
	  if(tmp.X+tmp.Y==sumnum[j-1])
	    ret[i]=j;
      }
    return ret;
  }
};


int main(int argc, char **argv) {
    fout = fopen(argv[2], "a");
    fin = fopen(argv[1], "r");

    string subtask_type, strategy_type;
    cin >> subtask_type >> strategy_type;
    if (strategy_type == "plain") {
        strategy = new ManagerStrategy_Plain();
    } else if (strategy_type == "adversary") {
        strategy = new ManagerStrategy_Adversary();
    } else if (strategy_type == "adversary_random") {
        strategy = new ManagerStrategy_AdversaryRandom();
    } else if (strategy_type == "adversary_antirandom") {
        strategy = new ManagerStrategy_AdversaryAntiRandom();
    } else if (strategy_type == "adversary_betterantirandom") {
        strategy = new ManagerStrategy_AdversaryBetterAntiRandom();
    } else {
        doubleWrite(FAIL, "invalid strategy type: "+strategy_type);
        exit(0);
    }

    strategy->read_input(cin);

    fprintf(fout, "%d\n", n);
    fflush(fout);

    int qcount = 0;
    while (true) {
        char tmp[1000];
        if (fscanf(fin, "%999s", tmp) != 1) {
	  die(WA, "io error, could not read command", false);
        }
        string cmd(tmp);
        if (cmd=="A") {//query
	  int index = readValidIndex("A",true);
            qcount++;
            if (qcount>maxq) {
	      die(WA, "query limit exceeded", true);
            }
            pii ans = strategy->ask(index);
            fprintf(fout, "%d %d\n", ans.first, ans.second);
            fflush(fout);
#ifdef ERRLOG
	    cerr << ans.first << " " << ans.second << endl;
#endif
	    queries.push_back(MP(index,ans) );
        } else if (cmd=="B") {//answer
	  int index = readValidIndex("B",false);
	    answer = index;
            bool ok = strategy->isBest(index);
            if (ok) {
	        cout << OK << endl;
#ifdef ERRLOG
                cerr << OK << endl;
#endif
	    } else {
	        doubleWrite(WA, "answer is not correct");
            }
	    finish();
            exit(0);
        } else {
	  die(WA, "io error, invalid command", false);
        }
    }
    return 0;
}
