//In the name of Allah
//Wiring - IOI 2017
//Mahdi Safarnejad-Boroujeni

import static java.lang.Math.*;

public class wiring{
	final static int N = 200002;
	final static int BLUE = 1;
	final static int RED = 2;

	class Point implements Comparable<Point>{
		int x, color;
		public Point(int _x, int _color) {
			x = _x;
			color = _color;
		}
		public int compareTo(Point comparePoint) {
			//ascending order
			return this.x - comparePoint.x;
		}
	}

	Point tmp[] = new Point[N];
	Point p[] = new Point[N];

	long f[] = new long[N];
	long g[] = new long[N];
	long sum[] = new long[N];
	long dp[] = new long[N];

	long min_total_length(int red[], int blue[]) {
		int nr = red.length;
		int nb = blue.length;
		int n = nb + nr;

		for (int i=0; i<=n+1; ++i)
			tmp[i] = new Point(0, 0);

		for (int i = 0; i < nr; i++) {
			tmp[i].x = red[i];
			tmp[i].color = RED;
		}
		for (int i = 0; i < nb; i++) {
			tmp[nr + i].x = blue[i];
			tmp[nr + i].color = BLUE;
		}

		{
			//Arrays.sort(p, 1, n+1);

			int r_index = 0, b_index = nr;
			for (int k=1; k<=n; ++k) {
				if (r_index >= nr)
					p[k] = tmp[b_index++];
				else if (b_index >= nr+nb)
					p[k] = tmp[r_index++];
				else if (tmp[r_index].x < tmp[b_index].x)
					p[k] = tmp[r_index++];
				else
					p[k] = tmp[b_index++];
			}
		}
		p[0] = tmp[n];
		p[n+1] = tmp[n+1];

		long ONE = 1;
		int st = 1, lastSz = 0;
		for (int i = 1; i <= n; i++) {
			if (p[i].color != p[i - 1].color) {
				for (int j = i; p[j].color == p[i].color; j++)
					sum[i] += p[j].x;
				for(int j = i - 1; j >= st; j--) {
					f[j] = -sum[j] + min(dp[j - 1], dp[j]) + ONE * (i - j) * p[i - 1].x;
					if(j < i - 1)
						f[j] = min(f[j], f[j + 1]);
				}
				for(int j = st; j < i; j++) {
					g[j] = -sum[j] + min(dp[j - 1], dp[j]) + ONE * (i - j) * p[i].x;
					if(j > st)
						g[j] = min(g[j], g[j - 1]);
				}
				lastSz = i - st;
				st = i;
			} else
				sum[i] = sum[i - 1] - p[i - 1].x;
			if(st == 1) {
				dp[i] = Double.valueOf(1E+18).longValue();
				continue;
			}
			int sz = i - st + 1;
			long curSum = sum[st] - sum[i] + p[i].x;
			if (sz >= lastSz)
				dp[i] = f[st - lastSz] + curSum - ONE * sz * p[st - 1].x;
			else
				dp[i] = min(g[st - sz - 1] + curSum - ONE * sz * p[st].x,
						f[st - sz] + curSum - ONE * sz * p[st - 1].x);
		}
		return dp[n];
	}
}

