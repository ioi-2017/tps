import java.io.IOException;
import java.io.InputStream;
import java.util.InputMismatchException;

public class grader {

	private static final int max_q = 10000;
	private static int n;
	private static int query_count = 0;
	private static int[] g;
	private static int[][] rank_count;

	public static int[] ask(int i) {
		query_count++;
		if(query_count > max_q) {
			System.err.println("Query limit exceeded");
			System.exit(0);
		}

		if(i < 0 || i >= n) {
			System.err.print("Bad index: ");
			System.err.println(i);
			System.exit(0);
		}

		int[] res = new int[2];
		res[0] = rank_count[g[i] - 1][i + 1];
		res[1] = rank_count[g[i] - 1][n] - res[0];
		return res;
	}

	public static void main(String[] args) throws IOException {
		InputReader inputReader = new InputReader(System.in);
		n = inputReader.readInt();

		g = new int[n];
		for (int i = 0; i < n; i++) {
			g[i] = inputReader.readInt();
			if (g[i] < 1) {
				System.err.print("Invalid rank ");
				System.err.print(g[i]);
				System.err.print(" at index ");
				System.err.println(i);
				System.exit(0);
			}
		}

		int max_rank = g[0];
		for(int i = 0; i < n; i++)
			max_rank = Math.max(max_rank, g[i]);

		rank_count = new int[max_rank + 1][n + 1];
		for (int r = 0; r <= max_rank; r++) {
			rank_count[r][0] = 0;
			for(int i = 1; i <= n; i++) {
				rank_count[r][i] = rank_count[r][i - 1];
				if(g[i - 1] == r)
					rank_count[r][i]++;
			}
		}

		for(int i = 0; i <= n; i++)
			for (int r = 1; r <= max_rank; r++)
				rank_count[r][i] += rank_count[r - 1][i];

		prize solver = new prize();
		int res = solver.find_best(n);
		System.out.println(res);
		System.out.println("Query count: " + query_count);

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
