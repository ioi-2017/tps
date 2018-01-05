public class prize {

	public int find_best(int n) {
		for(int i = 0; i < n; i++) {
			int[] res = grader.ask(i);
			if(res[0] + res[1] == 0)
				return i;
		}
		return 0;
	}
}
