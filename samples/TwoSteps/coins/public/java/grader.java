import java.io.IOException;
import java.io.InputStream;
import java.util.InputMismatchException;


public class grader {
	
	private static InputReader inputReader;
	private static coins coins_prog;

	private static String run_test() {
		int c = inputReader.readInt();
		int[] b = new int[64];
		for (int i = 0; i < 8; i++) {
			String s = inputReader.readString();
			for (int j = 0; j < 8; j++) {
				b[i * 8 + j] = (int)(s.charAt(j) - '0');
			}
		}
		
		int[] flips = coins_prog.coin_flips(b, c);
		if (flips.length == 0) {
			return "0 turn overs";
		}
		for (int i = 0; i < flips.length; i++) {
			if (flips[i] < 0 || flips[i] > 63) {
				return "cell number out of range";
			}
			b[flips[i]] = 1 - b[flips[i]];
		}
		int coin = coins_prog.find_coin(b);
		if (coin != c) {
			return "wrong coin";
		}
		return "ok";
	}
	
	public static void main(String[] args) {
		inputReader = new InputReader(System.in);
		coins_prog = new coins();
		int tests = inputReader.readInt();
		for (int t = 1; t <= tests; t++) {
			String result = run_test();
			System.out.println("test #" + t + ": " + result);
		}
	}
	
}


class InputReader {
	private InputStream stream;
	private byte[] buf = new byte[1024];
	private int curChar;
	private int numChars;

	public InputReader(InputStream stream) {
		this.stream = stream;
	}

	public int read() {
		if (numChars == -1) {
			throw new InputMismatchException();
		}
		if (curChar >= numChars) {
			curChar = 0;
			try {
				numChars = stream.read(buf);
			} catch (IOException e) {
				throw new InputMismatchException();
			}
			if (numChars <= 0) {
				return -1;
			}
		}
		return buf[curChar++];
	}

	public int readInt() {
		int c = eatWhite();
		int sgn = 1;
		if (c == '-') {
			sgn = -1;
			c = read();
		}
		int res = 0;
		do {
			if (c < '0' || c > '9') {
				throw new InputMismatchException();
			}
			res *= 10;
			res += c - '0';
			c = read();
		} while (!isSpaceChar(c));
		return res * sgn;
	}

	public String readString() {
		int c = eatWhite();
		StringBuilder res = new StringBuilder();
		do {
			if (Character.isValidCodePoint(c))
				res.appendCodePoint(c);
			c = read();
		} while (!isSpaceChar(c));
		return res.toString();
	}

	private int eatWhite() {
		int c = read();
		while (isSpaceChar(c)) {
			c = read();
		}
		return c;
	}
	
	public static boolean isSpaceChar(int c) {
		return c == ' ' || c == '\n' || c == '\r' || c == '\t' || c == -1;
	}
}
