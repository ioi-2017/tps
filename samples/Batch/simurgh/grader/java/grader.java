import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.InputMismatchException;





/**
 * A security system used in java graders for restricting the access of contestant's code to grader data.
 * <br>
 * It prevents access to declared members of classes using a {@link SecurityManager} and loading classes with different class loaders.
 * <br>
 * You have to put the main grader implementation in a separate class called <i>PrivateGrader</i>,
 * whose instance must be created by method {@link #instantiateGrader}.
 * This will also result in installing the java security manager which protects the private fields of the instantiated PrivateGrader.
 * It also prevents setting another {@link SecurityManager} or calling the <code>main()</code> method for a second time!
 * <br>
 * The front-end {@link grader} methods should delegate their works to similar methods in PrivateGrader.
 * To do that you have to introduce a <i>public</i> interface which is implemented by the PrivateGrader.
 * <br>
 * @author Kian Mirjalali
 * @since IOI2017, Iran
 *
 */
class GraderSecuritySystem {
	
	private java.util.List<String> protectedClassNames;
	
	private boolean isProtectedClassName(String name) {
		for (String protectedClassName : protectedClassNames) {
			if (name.equals(protectedClassName) || name.startsWith(protectedClassName+"$"))
				return true;
		}
		return false;
	}
	
	
	private class GraderClassLoader extends ClassLoader {
		@Override
		protected Class<?> loadClass(String name, boolean resolve) throws ClassNotFoundException {
			if (!isProtectedClassName(name))
				return super.loadClass(name, resolve);
			synchronized (getClassLoadingLock(name)) {
				// First, check if the class has already been loaded
				Class<?> c = findLoadedClass(name);
				if (c == null) {
					//System.err.println("loading protected class: "+name);
					String path = name.replaceAll("\\Q.\\E", "/")+".class";
					try (InputStream in = ClassLoader.getSystemResourceAsStream(path)) {
						if (in == null)
							throw new ClassNotFoundException("no class with path: "+path);
						byte[] a = new byte[1000000];
						int len = in.read(a);
						c = defineClass(name, a, 0, len);
					} catch (IOException e) {
						throw new ClassNotFoundException("", e);
					}
				}
				if (resolve) {
					resolveClass(c);
				}
				return c;
			}
		}
	}


	private ClassLoader classLoader = new GraderClassLoader();
	
	
	/**
	 * @param protectedClassNames list of class names which are going to be loaded with a separate class loader. 
	 */
	public GraderSecuritySystem(String... protectedClassNames) {
		this.protectedClassNames = Arrays.asList(protectedClassNames);
	}
	
	/**
	 * @param protectedClassNames list of classes which are going to be loaded with a separate class loader. 
	 */
	public GraderSecuritySystem(Class<?>... protectedClasses) {
		this.protectedClassNames = new java.util.ArrayList<>();
		for (Class<?> pc : protectedClasses)
			this.protectedClassNames.add(pc.getName());
	}
	
	/**
	 * The {@link SecurityManager} which prevents access to declared members of classes with different class loaders.
	 */
	private class GraderSecurityManager extends SecurityManager {
		
		@Override
		public void checkPermission(java.security.Permission perm) {
			if (perm instanceof RuntimePermission && perm.getName().equals("accessDeclaredMembers")) {
				/*
				throw new SecurityException();
				/*/
				System.out.println("lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs");
				System.out.println("SV");
				System.out.println("accessing declared members of grader");
				System.exit(0);
				//*/
			}
		}
	}
	
	
	/**
	 * You can call <code>instantiateGrader</code> method only once.
	 * @param privateGraderClassName the class name of PrivateGrader whose instance is going to be created.
	 * @return the created instance of PrivateGrader
	 */
	public Object instantiateGrader(String privateGraderClassName) {
		try {
			java.lang.reflect.Constructor<?> constructor = this.classLoader.loadClass(privateGraderClassName).getDeclaredConstructor();
			constructor.setAccessible(true);
			Object graderInstance = constructor.newInstance();
			System.setSecurityManager(new GraderSecurityManager());
			return graderInstance;
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
	}
	
	/**
	 * You can call <code>instantiateGrader</code> method only once.
	 * @param privateGraderClass the PrivateGrader class whose instance is going to be created.
	 * @return the created instance of PrivateGrader
	 */
	public Object instantiateGrader(Class<?> privateGraderClass) {
		return this.instantiateGrader(privateGraderClass.getName());
	}
}



public class grader {
	
	public static interface GraderInterface {
		public int count_common_roads(int[] r);
		public void main(String[] args);
	}
	
	private static GraderInterface privateGrader;
	
	public static int count_common_roads(int[] r) {
		return privateGrader.count_common_roads(r);
	}
	
	public static void main(String[] args) {
		GraderSecuritySystem graderSecuritySystem = new GraderSecuritySystem(PrivateGrader.class, InputReader.class);
		privateGrader = (GraderInterface) graderSecuritySystem.instantiateGrader(PrivateGrader.class);
		privateGrader.main(args);
	}
	
	public static int[] find_roads(int n, int[] from, int[] to) {
		simurgh solver = new simurgh();
		return solver.find_roads(n, from, to);
	}
}

class PrivateGrader implements grader.GraderInterface {
	private int CIPHER_SIZE = 64;
	private int[] CIPHER_KEY = {1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0};

	private int btoi(boolean x){
		if(x)   return 1;
		return 0;
	}

	private boolean itob(int x){
		if(x == 0)  return false;
		return true;
	}
	private int xored(int v, int i) {
		return v ^ (CIPHER_KEY[i % CIPHER_SIZE] & 1);
	}

	private static int MAXQ = 30000;

	private int n, m, q = 0;
	private int[] from, to;
	private boolean[] goal;


	private int[] parent;

	private int find(int v) {
		if(parent[v] == v)
			return v;
		parent[v] = find(parent[v]);
		return parent[v];
	}

	private boolean merge(int u, int v) {
		u = find(u);
		v = find(v);
		if (u == v)
			return false;
		parent[u] = v;
		return true;
	}

	private void wrong_answer() {
		System.out.println("lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs");
		System.out.println("WA");
		System.out.println("NO");
		System.exit(0);
	}

	private boolean is_valid(int[] r) {
		if (r.length != n - 1)
			return false;

		for (int i = 0; i < n - 1; i++)
			if (r[i] < 0 || r[i] >= m)
				return false;

		for (int i = 0; i < n; i++)
			parent[i] = i;
		for (int i = 0; i < n - 1; i++)
			if (!merge(from[r[i]], to[r[i]]))
				return false;
		return true;
	}
	
	private int _count_common_roads_internal(int[] r) {
		if (!is_valid(r))
			wrong_answer();

		int common = 0;
		for (int i = 0; i < n - 1; i++) {
			boolean is_common = goal[r[i]];
			is_common = itob(xored(btoi(goal[r[i]]), r[i]));
			if (is_common)
				common++;
		}
		return common;
	}

	@Override
	public int count_common_roads(int[] r) {
		q ++;
		if (q > MAXQ)
			wrong_answer();
		return _count_common_roads_internal(r);
	}
	
	@Override
	public void main(String[] args) {
		InputReader inputReader = new InputReader(System.in);
		String output_secret = "lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs";
		{
			String secret = inputReader.readString();
			if (!secret.equals("wrslcnopzlckvxbnair_input_simurgh_lmncvpisadngpiqdfngslcnvd")) {
				System.out.println(output_secret);
				System.out.println("SV");
				System.exit(0);
			}
		}
		n = inputReader.readInt();
		m = inputReader.readInt();
		MAXQ = inputReader.readInt();

		from = new int[m];
		to = new int[m];

		parent = new int[n];

		for (int i = 0; i < m; i++) {
			int u, v;
			u = inputReader.readInt();
			v = inputReader.readInt();
			from[i] = u;
			to[i] = v;
		}

		goal = new boolean[m];
		for(int i = 0; i < m; ++ i) goal[i] = false;

		for (int i = 0; i < n - 1; i++) {
			int id = inputReader.readInt();
			goal[id] = true;
		}

		for (int i = 0; i < m; i++)
			goal[i] = itob(xored(btoi(goal[i]), i));
		int[] result = grader.find_roads(n, from, to);

		if (_count_common_roads_internal(result) != n - 1)
			wrong_answer();
		System.out.println(output_secret);
		System.out.println("OK");
		for(int i = 0; i < result.length; ++ i){
			if(i > 0)
				System.out.format(" ");
			System.out.format("%d", result[i]);
		}
		System.out.println("");
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
