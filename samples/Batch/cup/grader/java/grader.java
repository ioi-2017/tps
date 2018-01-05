import java.io.IOException;
import java.io.InputStream;
import java.util.InputMismatchException;

public class grader {

	// BEGIN SECRET
	private static String input_secret = "e8a66651-560d-46a7-9496-0782b8bb7081";
	private static String output_secret = "be6fe19e-6ee7-4837-a81e-6f6902743b31";
	
	private static final int codelen = 2;
	private static final int[] code = {0x971CBAB, 0x3C3D64EE};

	private static int crypt(int value, int pos) {
		return value ^ code[pos & (codelen-1)];
	}
	// END SECRET
	private static final int WORLD_SIZE = 1000_000_000; 
	private static int t;
	private static int[] a, b, qc;
	
	private static void wrong_answer(){
		// BEGIN SECRET
		System.out.println(output_secret);
		System.out.println("WA");
		// END SECRET
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
		// BEGIN SECRET
		dx = crypt(a[t], 0) - x;
		dy = crypt(b[t], 1) - y;
		// END SECRET
		return Math.abs(dx) ^ Math.abs(dy);
	}

	public static void main(String[] args) {
		InputReader inputReader = new InputReader(System.in);
		// BEGIN SECRET
		{
			String secret = inputReader.readString();
			if(!input_secret.equals(secret)) {
				System.out.println(output_secret);
				System.out.println("SV");
				System.exit(0);
			}
		}
		// END SECRET
		int tests = inputReader.readInt();
		a = new int[tests];
		b = new int[tests];
		qc = new int[tests];
		
		for (t = 0; t < tests; t++){
			a[t] = inputReader.readInt();
			b[t] = inputReader.readInt();
			// BEGIN SECRET
			a[t] = crypt(a[t], 0);
			b[t] = crypt(b[t], 1);
			// END SECRET
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
			// BEGIN SECRET
			x = crypt(x, 0);
			y = crypt(y, 1);
			// END SECRET
			if (result[0] != x || result[1] != y) {
				qc[t] = -1;
			}
		}
		// BEGIN SECRET
		System.out.println(output_secret);
		System.out.println("OK");
		// END SECRET
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
