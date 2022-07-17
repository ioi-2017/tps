import java.util.Scanner;

class add1 {
	public static void main(String... args) {
		int argc = args.length;
		System.out.println("#args="+argc);
		for (int i = 0; i < argc; i++)
			System.out.println("arg["+(i+1)+"]='"+args[i]+"'");
		Scanner sc = new Scanner(System.in);
		int a = sc.nextInt();
		int b = sc.nextInt();
		System.out.println(a+b);
	}
}
