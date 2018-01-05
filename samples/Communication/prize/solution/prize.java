public class prize {
	class Pair{
		int first, second;
		Pair(){
			first = 0;
			second = 0;
		}
		Pair(int x, int y) {
			first = x;
			second = y;
		}
		boolean cmp(Pair p) {
			if(first < p.first) return true;
			if(first > p.first) return false;
			return second < p.second;
		}
	}
	final int MAX = 210000;
	int numb,cnt,ans;
	Pair[] P = new Pair[MAX];
	boolean[] mark = new boolean[MAX];
	public Pair query(int x)
	{
		if(mark[x]) return P[x];
		mark[x]=true;
		int[] result = grader.ask(x);
		if(result[0]+result[1]==0) ans=x;
		return P[x]=new Pair(result[0],result[1]);
	}

	public void bs(int l,int r,int nl,int nr)
	{
		if((cnt--)<=0) return;
		if(l>r) return;
		for(int i=0;i<=r-l;i++)
		{
			int mid,midl=(l+r)/2-i/2,midr=(l+r)/2+(i+1)/2;
			if(i%2==0) mid=midl;
			else mid=midr;
			Pair tmp=query(mid);
			if(tmp.first+tmp.second>numb) {cnt=0;return;}
			if(tmp.first+tmp.second==numb)
			{
				int tmpl=(i%2==0?0:midr-midl);
				int tmpr=(i%2==1?0:midr-midl);
				if(tmp.first-tmpl>nl) bs(l,midl-1,nl,tmp.second+tmpl);
				if(tmp.second-tmpr>nr) bs(midr+1,r,tmp.first+tmpr,nr);
				break;
			}
		}
	}

	public int find_best(int n)
	{
		if(n==1) return 0;
		numb=1;
		cnt=20;
		bs(0,n-1,0,0);
		int p=0;
		for(int i=0;i<Math.sqrt(n)+30 && i<n && numb<=26;i++)
		{
			Pair tmp=query(i);
			if(tmp.first+tmp.second>numb) p=i;
			numb=Math.max(numb,tmp.first+tmp.second);
		}
		cnt=1000000;
		bs(p,n-1,p,0);
		return ans;
	}
}
