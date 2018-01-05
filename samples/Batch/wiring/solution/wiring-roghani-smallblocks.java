import java.io.*;
import java.lang.*;
import java.util.*;

public class wiring{

    final int maxn = 200000 + 10;
	final long inf = 1L << 62;

	long[] sum = new long[maxn];
	long[] dp = new long[maxn];

    class Pair{
        long first, second;
        Pair(){
            first = 0;
            second = 0;
        }
        Pair(long x, long y) {
            first = x;
            second = y;
        }
        boolean cmp(Pair p) {
            if(first < p.first) return true;
            if(first > p.first) return false;
            return second < p.second;
        }
    }

	long get_sum(int r,int l){
		if(l<0)return sum[r];
		return sum[r]-sum[l];
	}

	long min_total_length(int red[], int blue[]) {
        int n = red.length;
        int m = blue.length;
		ArrayList<Pair> all = new ArrayList();
        int x=0,y=0;
        while(x < n || y < m){
            if(x==n)
                all.add(new Pair(blue[y++],1));
            else if(y==m || red[x]<blue[y])
                all.add(new Pair(red[x++],0));
            else
                all.add(new Pair(blue[y++],1));
        }
        dp[0] = inf;
        sum[0] = all.get(0).first;
        for(int i=1;i<n+m;i++)sum[i]=sum[i-1]+all.get(i).first;
        int pos=0;
        for(int i=1;i<n+m;i++){
            pos=i;
            if(all.get(i).second == all.get(0).second)
                dp[i]=inf;
            else
                break;
        }
        for(int i=pos;i<n+m;i++){
			if(all.get(i).second != all.get(0).second)
                dp[i] = get_sum(i,pos-1) - (i-pos+1)*all.get(pos).first + pos*all.get(pos-1).first - get_sum(pos-1,-1) + Math.max(pos,i-pos+1)*(all.get(pos).first - all.get(pos-1).first);
            else{
                pos = i;
				break;
			}
			if(i==n+m-1)pos=n+m;
        }
        for(int i=pos;i<n+m;i++){
			dp[i] = inf;
            if(dp[i-1]==inf && all.get(i).second == all.get(i-1).second) continue;
            int ind = -1;
            for(int j=i-1;j>=0;j--){
                if(all.get(j).second != all.get(i).second){
                    ind = j;
                    break;
                }
            }
            for(int j=ind;j>=0;j--){
                if(all.get(j).second == all.get(i).second) break;
                dp[i] = Math.min(dp[i], Math.min(dp[j],dp[j-1]) + get_sum(i,ind) - (i-ind)*all.get(ind+1).first + (ind-j+1)*all.get(ind).first - get_sum(ind,j-1) + Math.max(ind-j+1,i-ind)* (all.get(ind+1).first-all.get(ind).first));
            }
        }
        return dp[n+m-1];


	}
}

