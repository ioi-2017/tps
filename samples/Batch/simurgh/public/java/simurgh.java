public class simurgh {

	int[] find_roads(int n, int[] u, int[] v) {
		int[] r = new int[n - 1];
		for(int i = 0; i < n - 1; i++)
			r[i] = i;
		int common = grader.count_common_roads(r);
		if(common == n - 1)
			return r;
		r[0] = n - 1;
		return r;
	}
}
