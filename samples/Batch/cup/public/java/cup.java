
class cup {
	public int[] find_cup() {
		int[] result = new int[2];
		if (grader.ask_shahrasb(0, 0) < grader.ask_shahrasb(1, 2)) {
			result[0] = 0;
			result[1] = 0;
		} else {
			result[0] = 1;
			result[1] = 2;
		}
		return result;
	}
}
