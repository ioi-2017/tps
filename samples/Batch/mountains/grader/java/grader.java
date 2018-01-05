import java.io.IOException;
import java.io.InputStream;
import java.util.InputMismatchException;

public class grader {
    // BEGIN SECRET
    static private String input_secret = "3f130aac-d629-40d9-b3ad-b75ea9aa8052";
    static private String output_secret = "f3697e79-76f0-4a15-8dc8-212253e98c61";
    // END SECRET
    public static void main(String[] args) throws IOException {
        InputReader inputReader = new InputReader(System.in);
        // BEGIN SECRET
        String secret = inputReader.readString();
        if(!input_secret.equals(secret)){
            System.out.println(output_secret);
            System.out.println("SV");
            System.out.close();
            System.exit(0);
        }
        // END SECRET
        int n = inputReader.readInt();
        int[] y = new int[n];
        for (int i = 0; i < n; i++) {
            y[i] = inputReader.readInt();
        }
        mountains solver = new mountains();
        int result = solver.maximum_deevs(y);
        // BEGIN SECRET
        System.out.println(output_secret);
        System.out.println("OK");
        // END SECRET
        System.out.println(result);
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

