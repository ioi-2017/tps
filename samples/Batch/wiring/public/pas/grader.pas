uses wiring;

type
	TIntArray = array of longint;

var
	n, m, i: longint;
	r, b: TIntArray;
	res: int64;

begin
	read(n);
	read(m);

	setlength(r, n);
	setlength(b, m);
	for i := 0 to n - 1 do
		read(r[i]);
	for i := 0 to m - 1 do
		read(b[i]);

	res := wiring.min_total_length(r, b);
	writeln(res);
end.
