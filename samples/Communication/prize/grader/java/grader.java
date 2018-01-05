import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.InputMismatchException;

public class grader {
	
	private static InputReader inputReader;
	private static PrintWriter outputWriter; 
	
	public static int[] ask(int i) {
		outputWriter.println("A "+i);
		outputWriter.flush();
		int[] result = new int[2];
		try {
			result[0] = inputReader.readInt();
			result[1] = inputReader.readInt();
		} catch (InputMismatchException e) {
			System.err.println("tester error");
			System.err.println("could not read query response");
			System.exit(0);
		}
		if (result[0] < 0) {
			System.exit(0);
		}
		return result;
	}

	
	public static void main(String[] args) {
		try {
			inputReader = new InputReader(new FileInputStream(args[0]));
			outputWriter = new PrintWriter(new File(args[1]));
		} catch (FileNotFoundException e) {
			System.err.println("tester error");
			e.printStackTrace(System.err);
			System.exit(0);
		}

		int n = 0;
		try {
			n = inputReader.readInt();
		} catch (InputMismatchException e) {
			System.err.println("tester error");
			System.err.println("could not read 'n'");
			System.exit(0);
		}

		prize solver = new prize();
		int result = solver.find_best(n);
		outputWriter.println("B "+result);
		outputWriter.flush();
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
