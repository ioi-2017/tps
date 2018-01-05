	//     . .. ... .... ..... be name khoda ..... .... ... .. .     \\

#include<iostream>
#include<algorithm>
#include "wiring.h"
using namespace std;

const long long INF = 1e18;
const int N = 202;

long long dp[N][N];

long long min_total_length(vector<int> red, vector<int> blue)
{
	int n = red.size();
	int m = blue.size();
	fill(dp[0] + 1, dp[0] + m + 1, INF);
	for(int i = 1; i <= n; i++)
	{
		dp[i][0] = INF;
		for(int j = 1; j <= m; j++)
			dp[i][j] = min(dp[i - 1][j], min(dp[i][j - 1], dp[i - 1][j - 1])) + abs(red[i - 1] - blue[j - 1]);
	}
	return dp[n][m];
}
