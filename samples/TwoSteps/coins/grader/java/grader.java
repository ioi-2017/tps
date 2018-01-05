import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.InputMismatchException;
import java.util.Random;

public class grader {

	private static final String input_secret = "8ad886d6-2d9e-4cab-aaed-47175facae96";
	private static final String pipe_secret = "3f900aa0-f7c9-4935-ac07-3f34523a67ab";
	private static final String output_secret = "aa118b2a-086a-420f-811f-e3648ef86a25";
	
	private static final int board_width = 8;
	private static final int board_height = 8;
	private static final int board_size = board_width * board_height;
	
	private static void shuffle(int[] v){
		Random rnd = new Random(850928);
		int n = v.length;
		for(int i = n-1; i > 0; i--){
			int j = rnd.nextInt(i+1);
			int tmp = v[i];
			v[i] = v[j];
			v[j] = tmp;
		}
	}
	
	private PrintWriter pipe1;
	
	private void error1(String msg, String reason) {
		pipe1.println(pipe_secret);
		pipe1.println(msg);
		pipe1.println(reason);
		pipe1.close();
		System.exit(0);
	}
	
	private void error1(String msg) {
		error1(msg, "");
	}
	
	private void error1() {
		error1("WA");
	}
	
	private void pass1(String pipe_path) {
		System.out.close();
		
		try {
			pipe1 = new PrintWriter(new File(pipe_path));
		} catch (FileNotFoundException e) {
			e.printStackTrace(System.err);
			System.exit(1);
		}
		
		InputReader inputReader = new InputReader(System.in);
		String secret = inputReader.readString();
		if (!input_secret.equals(secret)) {
			error1("SV");
		}
		
		int tests = inputReader.readInt();
		int k = inputReader.readInt();
		
		int[] cs = new int[tests];
		int[][] bs = new int[tests][];
		
		for (int t = 0; t < tests; t++) {
			cs[t] = inputReader.readInt();
			bs[t] = new int[board_size];
			for (int i = 0; i < board_height; i++) {
				String row = inputReader.readString();
				for(int j = 0; j < board_width; j++) {
					bs[t][i * board_width + j] = ((int)(row.charAt(j))) - (int)'0';
				}
			}
		}
		inputReader.close();
		
		coins solver = new coins();
		for (int t = 0; t < tests; t++) {
			int[] board_copy = bs[t].clone();
			int[] flips = solver.coin_flips(board_copy, cs[t]);
			int flen = flips.length;
			
			if (flen == 0 || flen > k) {
				error1("WA", "invalid flips length");
			}
			
			for (int i = 0; i < flen; i++) {
				if (flips[i] < 0 || flips[i] >= board_size) {
					error1("WA", "invalid coin index in flips");
				}
			}
			
			for (int i = 0; i < flen; i++) {
				int j = flips[i];
				bs[t][j] = 1 - bs[t][j];
			}
		}
		
		pipe1.println(pipe_secret);
		pipe1.println("OK");
		pipe1.println(tests); 
		for (int t = 0; t < tests; t++) {
			for (int i = 0; i < bs[t].length; i++) {
				pipe1.print(bs[t][i]);
			}
			pipe1.println();
		}
		pipe1.close();
	}
	
	private void error2(String msg, String reason) {
		System.out.println(output_secret);
		System.out.println(msg);
		System.out.println(reason);
		System.out.close();
		System.exit(0);
	}
	
	private void error2(String msg) {
		error2(msg, "");
	}
	
	
	private void pass2(String pipe_path) {
		String secret;
		//InputReader inputReader = new InputReader(System.in);
		//secret = inputReader.readString();
		//if (!input_secret.equals(secret)) {
		//	 error2("SV");
		//}
		//inputReader.close();
		
		InputReader pipe2 = null;
		try {
			pipe2 = new InputReader(new FileInputStream(pipe_path));
		} catch (FileNotFoundException e) {
			error2("FAIL", "pipe not found: "+pipe_path);
		}
		secret = pipe2.readString();
		if (!pipe_secret.equals(secret)) {
			error2("SV");
		}
	
		String status = pipe2.readString();
		if (!"OK".equals(status)) {
			String reason = pipe2.readLine();
			error2(status, reason);
		}
	
		int tests = pipe2.readInt();
	
		int[][] bs = new int[tests][];
		for (int t = 0; t < tests; t++) {
			bs[t] = new int[board_size];
			String row = pipe2.readString();
			for (int i = 0; i < board_size; i++) {
				bs[t][i] = ((int)(row.charAt(i))) - (int)'0';
			}
		}
		pipe2.close();
		
		int[] p = new int[tests];
		for (int t = 0; t < tests; t++) {
			p[t] = t;
		}
		shuffle(p);
	
		int[] coin = new int[tests];
		coins solver = new coins();
		for (int _t = 0; _t < tests; _t++) {
			int t = p[_t];
			coin[t] = solver.find_coin(bs[t]);
		}
	
		System.out.println(output_secret);
		System.out.println("OK");
		for (int t = 0; t < tests; t++) {
			System.out.println(coin[t]);
		}
	}

	public static void main(String[] args) throws IOException {
		if (args.length < 2) {
			System.out.println("invalid arguments");
			System.exit(1);
		}
		int type =  Integer.parseInt(args[0]);
		if (type == 0) {
			new grader().pass1(args[1]);
		} else {
			new grader().pass2(args[1]);
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
	
	public void close() {
		try {
			this.stream.close();
		} catch (IOException e) {
		}
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

	public String readLine() {
		StringBuilder res = new StringBuilder();
		while (true) {
			int c = read();
			if (c == '\n' || c == '\r' || c == -1)
				break;
			if (Character.isValidCodePoint(c))
				res.appendCodePoint(c);
		}
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
