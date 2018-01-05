import java.io.IOException;
import java.io.InputStream;
import java.util.InputMismatchException;

public class grader {

	private static final int WORLD_SIZE = 1000_000_000; 
	private static int t;
	private static int[] a, b, qc;
	
	private static void wrong_answer(){
		System.out.println(-1);
		System.exit(0);
	}
	
	public static int ask_shahrasb(int x, int y) {
		qc[t]++;
		if (Math.abs(x) > WORLD_SIZE || Math.abs(y) > WORLD_SIZE) {
			wrong_answer();
		}
		int dx = a[t] - x;
		int dy = b[t] - y;
		return Math.abs(dx) ^ Math.abs(dy);
	}

	public static void main(String[] args) {
		InputReader inputReader = new InputReader(System.in);
		int tests = inputReader.readInt();
		a = new int[tests];
		b = new int[tests];
		qc = new int[tests];
		
		for (t = 0; t < tests; t++){
			a[t] = inputReader.readInt();
			b[t] = inputReader.readInt();
		}
		cup jam = new cup();
		for (t = 0; t < tests; t++){
			qc[t] = 0;
			int[] result = jam.find_cup();
			if (result == null || result.length != 2) {
				wrong_answer();
			}
			int x = a[t];
			int y = b[t];
			if (result[0] != x || result[1] != y) {
				qc[t] = -1;
			}
		}
		for (t = 0; t < tests; t++){
			System.out.println(qc[t]);
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
