#include<iostream>
#include<vector>
//#include"wiring.h"

using namespace std;

typedef long long ll;

const int maxn=200000+10;
const ll inf = 1LL << 62;

ll dp[maxn],sum[maxn];

ll get_sum(int r,int l){
	if(l<0)return sum[r];
	return sum[r]-sum[l];
}


ll min_total_length(vector<int> red,vector<int> blue){
    int n = red.size();
    int m = blue.size();
	vector<pair<ll,ll> > all;
	int x=0,y=0;
	while(x < n || y < m){
		if(x==n)
			all.push_back(make_pair(blue[y++],1));
		else if(y==m || red[x]<blue[y])
			all.push_back(make_pair(red[x++],0));
		else
			all.push_back(make_pair(blue[y++],1));
	}
	dp[0] = inf;
	sum[0] = all[0].first;
	for(int i=1;i<n+m;i++)sum[i]=sum[i-1]+all[i].first;
	ll pos=0;
	for(int i=1;i<n+m;i++){
		pos=i;
		if(all[i].second == all[0].second)
			dp[i]=inf;
		else 
			break;
	}
	for(ll i=pos;i<n+m;i++){
		if(all[i].second != all[0].second)
			dp[i] = get_sum(i,pos-1) - (i-pos+1)*all[pos].first + pos*all[pos-1].first - get_sum(pos-1,-1) + max(pos,i-pos+1)*(all[pos].first - all[pos-1].first);
		else{
			pos=i;
			break;
		}
		if(i==n+m-1)pos=n+m;
	}
	for(ll i=pos;i<n+m;i++){
		dp[i] = inf;
		if(dp[i-1]==inf && all[i].second == all[i-1].second) continue;
		ll ind = -1;
		for(int j=i-1;j>=0;j--){
			if(all[j].second != all[i].second){
				ind = j;
				break;
			}
		}
		for(int j=ind;j>=0;j--){
			if(all[j].second == all[i].second) break;
			dp[i] = min(dp[i], min(dp[j],dp[j-1]) + get_sum(i,ind) - (i-ind)*all[ind+1].first + (ind-j+1)*all[ind].first - get_sum(ind,j-1) + max(ind-j+1,i-ind)* (all[ind+1].first-all[ind].first));
		}
	}
    return dp[n+m-1];
}
