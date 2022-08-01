import java.util.Scanner;

public class grader {
	public static void main(String... args) {
		Scanner sc = new Scanner(System.in);
		int a = sc.nextInt();
		int b = sc.nextInt();
		sc.close();

		add1 solver = new add1();
		int res = solver.solve(a, b);

		try (java.io.PrintWriter out = new java.io.PrintWriter(System.out)) {
			out.println(res);
		}
	}
}
