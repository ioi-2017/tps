public class simurgh{

	final int MAX = 7;
	int[] par =new int[MAX];
	int [] __ans;	
	public int find(int v){
		if(par[v] == v)
			return v;
		else{
			par[v] = find(par[v]);
			return par[v];
		}
	}	

	public boolean merge(int u,int v){
		u = find(u);
		v = find(v);
		if(u == v)
			return false;
		par[u] = v;
		return true;
	}

	public int[] find_roads(int N, int[] v, int[] u){
		int n = N;
		int m = v.length;
		int num = 0;
		for(int mask = 0; mask < (1 << m); mask++){
			int res = 0;
			for(int i = 0 ; i < m ; i++)
				if((mask&(1<<i)) != 0)
					res++;
			if(res == n-1){
				for(int i=0;i<n;i++)
					par[i] = i;
				boolean valid = true;
				num=0;
				__ans = new int[n-1];
				for(int i=0;i<m;i++){
					if(((1<<i)&mask) != 0){
						__ans[num++]=i;
						valid &= merge(u[i],v[i]);
					}
				}
				if(valid && grader.count_common_roads(__ans) == n-1)
					return __ans;
			}
		}
		return __ans;
	}
}
