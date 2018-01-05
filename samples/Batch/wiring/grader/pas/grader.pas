uses wiring;

type
	TIntArray = array of longint;

var
	n, m, i: longint;
	r, b: TIntArray;
	res: int64;
	// BEGIN SECRET
	secret: string;
	// END SECRET

begin
	// BEGIN SECRET
	readln(secret);
	if secret <> '071e691ce5776974f655a51a364bf5ca' then
	begin
		writeln('9eb1604f9d1771bc19d90f43da7e264a');
		writeln('SV');
		halt(0);
	end;
	// END SECRET
	read(n);
	read(m);

	setlength(r, n);
	setlength(b, m);
	for i := 0 to n - 1 do
		read(r[i]);
	for i := 0 to m - 1 do
		read(b[i]);

	res := wiring.min_total_length(r, b);
	// BEGIN SECRET
	writeln('9eb1604f9d1771bc19d90f43da7e264a');
	writeln('OK');
	// END SECRET
	writeln(res);
end.
