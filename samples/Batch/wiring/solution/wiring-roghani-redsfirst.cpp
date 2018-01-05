#include<iostream>
#include<vector>
#include"wiring.h"

using namespace std;

typedef long long ll;

ll min_total_length(vector<int> red,vector<int> blue){
	int n = red.size();
	int m = blue.size();
	ll ret=0;
	if(m > n){
		for(int i=0;i<n;i++)ret += blue[i] - red[i];
		for(int i=n;i<m;i++)ret += blue[i] - red[n-1];
	}
	else{
		for(int i=1;i<=m;i++)ret += blue[m-i] - red[n-i];
		for(int i=0;i<n-m;i++)ret += blue[0] - red[i];
	}
	return ret;
}
