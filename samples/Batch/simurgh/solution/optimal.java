//        IOI 2017
//        Problem: Finding Spanning Tree
//        Author: PrinceOfPersia
//        Subtask: 5

import java.util.*;

class pii{
    public int x, y;
    pii() {
        x = y = 0;
    }
    public void set(int a, int b) {
        x = a;
        y = b;
    }
    public void copy(pii p){
        x = p.x;
        y = p.y;
    }
    pii(int a, int b){
        set(a, b);
    }
}

public class simurgh {
    private static final int maxn = 1012, maxm = maxn * maxn / 2;
    pii[] highest = new pii[maxn], edges = new pii[maxm];
    boolean[] mark = new boolean[maxn], bit = new boolean[maxm];
    int[] h = new int[maxn], state = new int[maxn], par = new int[maxn], last_num = new int[maxm], deg = new int[maxn],
            __edges, _last_id = new int[maxm];
    int[][] ind = new int[maxn][maxn];
    int n, m;
    ArrayList __edges_vec = new ArrayList(), tree = new ArrayList(), ans = new ArrayList();
    ArrayList[] adj = new ArrayList[maxn];
    int _next_ = 1;
    int [] __ans;
    private int boolean_to_int(boolean x){
        return (x)? 1: 0;
    }
    private void _renew() {
        ArrayList __edges_new = new ArrayList();
        for(Object o: __edges_vec){
            int i = getIntValue(o);
            if(bit[i] && _last_id[i] != _next_) {
                __edges_new.add(i);
                _last_id[i] = _next_;
            }
        }
        ++ _next_;
        __edges_vec.clear();
        __edges_vec = __edges_new;
    }

    private int getIntValue(Object o) {
        return ((Integer)o).intValue();
    }

    private int query(){
        _renew();
        int nx = 0;
        for(Object o: __edges_vec){
            int i = getIntValue(o);
            __edges[nx ++] = i;
        }
        int res =  grader.count_common_roads(__edges);
        if(res == n-1){
            for(int i = 0 ; i < n-1; ++ i)
                __ans[i] = __edges[i];
        }
        return res;
    }
    private void toggle(int i){
        if(!bit[i]){
            bit[i] = true;
            __edges_vec.add(i);
        }
        else
            bit[i] = false;
    }
    private void reset(){
        for(Object o: __edges_vec) {
            int i = getIntValue(o);
            bit[i] = false;
        }
        __edges_vec.clear();
    }
    private void dfs(int v, int p){
        par[v] = p;
        mark[v] = true;
        highest[v].set(h[v], -1);
        for(Object o: adj[v]){
            int u = getIntValue(o);
            int e = ind[v][u];
            if(!mark[u]){
                h[u] = h[v] + 1;
                dfs(u, v);
                if(highest[v].x > highest[u].x)
                    highest[v].copy(highest[u]);
            }
            else if(highest[v].x > h[u] && u != p)
                highest[v].set(h[u], e);
        }
        if(p != -1)
            toggle(ind[v][p]);
    }
    private void DFS(int v){
        int p = par[v];
        for(Object o: adj[v]){
            int u = getIntValue(o);
            if(par[u] == v)
                DFS(u);
        }

        if(p != -1 && state[v] == -1){
            if(highest[v].x > h[p]){
                state[v] = 1;
                return ;
            }
            int back_edge = highest[v].y;
            int x = edges[back_edge].x, y = edges[back_edge].y;
            if(h[x] > h[y]){
                int temp = x;
                x = y;
                y = temp;
            }
            int back_edge_num = query();
            int mn = back_edge_num, mx = mn;
            int cur = y;
            int for_a_one = -1;
            toggle(back_edge);
            while(cur != x){
                if(state[cur] == -1 || for_a_one == -1){
                    int cur_edge = ind[cur][par[cur]];
                    toggle(cur_edge);
                    last_num[cur_edge] = query();
                    if(mn > last_num[cur_edge])
                        mn = last_num[cur_edge];
                    if(mx < last_num[cur_edge])
                        mx = last_num[cur_edge];
                    if(state[cur] != -1)
                        for_a_one = last_num[cur_edge] - (1 - state[cur]);
                    toggle(cur_edge);
                }
                cur = par[cur];
            }
            toggle(back_edge);
            cur = y;
            while(cur != x){
                if(state[cur] == -1){
                    int cur_edge = ind[cur][par[cur]];
                    if(for_a_one != -1)
                        state[cur] = boolean_to_int(last_num[cur_edge] == for_a_one);
                    else if(mn == mx)
                        state[cur] = 0;
                    else
                        state[cur] = boolean_to_int(last_num[cur_edge] == mn);
                }
                cur = par[cur];
            }
        }
    }
    private int root(int v){
        if(par[v] < 0)  return v;
        return par[v] = root(par[v]);
    }
    private boolean merge(int in){
        int x = edges[in].x, y = edges[in].y;
        x = root(x);
        y = root(y);
        if(x == y)	return false;
        toggle(in);
        if(par[y] < par[x]) {
            int temp = x;
            x = y;
            y = temp;
        }
        par[x] += par[y];
        par[y] = x;
        return true;
    }
    private int edge_state(int i){
        int x = edges[i].x, y = edges[i].y;
        if(h[x] > h[y]){
            int temp = x;
            x = y;
            y = temp;
        }
        return state[y];
    }
    private int query_for_forest(ArrayList subset){
        reset();
        int sum = 0;
        Arrays.fill(par, -1);
        for(Object o: subset) {
            int e = getIntValue(o);
            merge(e);
        }
        for(Object o: tree) {
            int e = getIntValue(o);
            if(merge(e))
                sum += edge_state(e);
        }
        //System.out.println(query());
        return query() - sum;
    }
    private void calc_deg(int v){
        ArrayList subset = new ArrayList();
        for(Object o: adj[v]) {
            int u = getIntValue(o);
            subset.add(ind[v][u]);
        }
        deg[v] = query_for_forest(subset);
    }
    private void remove(int v){
        if(deg[v] == 0 || mark[v])	return ;
        assert deg[v] == 1;
        ArrayList ed = new ArrayList();
        for(Object o: adj[v]){
            int u = getIntValue(o);
            if(!mark[u])
                ed.add(ind[v][u]);
        }
        int l = 0, r = ed.size() - 1;
        while(r > l){
            int mid = (l + r)/2;
            ArrayList subset = new ArrayList();
            for(int i = l; i <= mid; ++ i)
                subset.add(ed.get(i));
            if(query_for_forest(subset) > 0)
                r = mid;
            else
                l = mid + 1;
        }
        int e = getIntValue(ed.get(l));
        int u = edges[e].x + edges[e].y - v;
        ans.add(e);
        -- deg[u];
        mark[v] = true;
        if(deg[u] == 1)
            remove(u);
    }
    public int[] find_roads(int N, int[] v, int[] u){
        n = N;
        m = v.length;
        __ans = new int[n-1];
        __edges = new int[n-1];
        Arrays.fill(state, -1);
        for(int i = 0; i < maxn; ++ i)
            for(int j = 0; j < maxn; ++ j)
                ind[i][j] = -1;
        for(int i = 0; i < n; ++ i) highest[i] = new pii();
        for(int i = 0; i < m; ++ i) edges[i] = new pii();
        for(int i = 0; i < n; ++ i) adj[i] = new ArrayList();
        for(int i = 0; i < m; ++ i){
            edges[i].set(v[i], u[i]);
            ind[v[i]][u[i]] = ind[u[i]][v[i]] = i;
            adj[v[i]].add(u[i]);
            adj[u[i]].add(v[i]);
        }
        dfs(0, -1);
        DFS(0);
        Arrays.fill(mark, false);
        for(int i = 0; i < m; ++ i)	if(bit[i])
            tree.add(i);
        for(int i = 0; i < n; ++ i)	calc_deg(i);
        for(int i = 0; i < n; ++ i)	if(deg[i] == 1)	remove(i);
        query_for_forest(ans);
        return __ans;
    }
}
