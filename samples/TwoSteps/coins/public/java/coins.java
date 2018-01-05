
public class coins {
	
	int[] coin_flips(int[] b, int c) {
		int[] flips = new int[1];
		if (b[c] == 1) {
			flips[0] = 0;
		} else {
			flips[0] = 4;
		}
		return flips;
	}
	
	int find_coin(int[] b) {
		if (b[0] == 0) {
			return 0;
		}
		return 7;
	}
}
