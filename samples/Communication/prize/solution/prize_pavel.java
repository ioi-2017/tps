public class prize {

    private int notMax;
    private int res;

    public int find_best(int n) {
        notMax = 0;
        for (int i = 0; i < Math.min(n, 500); i++) {
            int[] c = grader.ask(i);
            notMax = Math.max(notMax, c[0] + c[1]);
        }
        res = -1;
        find(0, n, 0, notMax);
        return res;
    }

    private void find(int l, int r, int ln, int rn) {
        if (r <= l || res >= 0 || rn == ln) return;
        int m = (l + r) / 2;
        for (int i = m; i < r; i++) {
            int[] c = grader.ask(i);
            if (c[0] + c[1] == 0) {
                res = m;
                return;
            }
            if (c[0] + c[1] == notMax) {
                find(l, m, ln, c[0] - (i - m));
                find(i + 1, r, c[0], rn);
                return;
            }
        }
        find(l, m, ln, rn - (r - m));
    }

}
