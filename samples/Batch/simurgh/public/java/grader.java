import java.io.IOException;
import java.io.InputStream;
import java.util.InputMismatchException;

public class grader {

	private static int MAXQ = 30000;

	private static int n, m, q = 0;
	private static int[] u, v;
	private static boolean[] goal;

	private static void wrong_answer() {
		System.out.println("NO");
		System.exit(0);
	}

	private static boolean is_valid(int[] r) {
		if(r.length != n - 1)
			return false;

		for(int i = 0; i < n - 1; i++)
			if(r[i] < 0 || r[i] >= m)
				return false;

		return true;
	}

	private static int _count_common_roads_internal(int[] r) {
		if(!is_valid(r))
			wrong_answer();

		int common = 0;
		for(int i = 0; i < n - 1; i++) {
			boolean is_common = goal[r[i]];
			if(is_common)
				common++;
		}

		return common;
	}

	public static int count_common_roads(int[] r) {
		q++;
		if(q > MAXQ)
			wrong_answer();

		return _count_common_roads_internal(r);
	}

	public static void main(String[] args) throws IOException {
		InputReader inputReader = new InputReader(System.in);
		n = inputReader.readInt();
		m = inputReader.readInt();

		u = new int[m];
		v = new int[m];

		for(int i = 0; i < m; i++) {
			u[i] = inputReader.readInt();
			v[i] = inputReader.readInt();
		}

		goal = new boolean[m];
		for(int i = 0; i < m; i++)
			goal[i] = false;

		for(int i = 0; i < n - 1; i++) {
			int id = inputReader.readInt();
			goal[id] = true;
		}

		simurgh solver = new simurgh();
		int[] res = solver.find_roads(n, u, v);

		if(_count_common_roads_internal(res) != n - 1)
			wrong_answer();

		System.out.println("YES");

		System.out.close();
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
