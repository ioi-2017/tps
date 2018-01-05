uses mountains;
// BEGIN SECRET
const
	input_secret = '3f130aac-d629-40d9-b3ad-b75ea9aa8052';
	output_secret = 'f3697e79-76f0-4a15-8dc8-212253e98c61';
// END SECRET

type 
	TIntArray = array of longint;

var
	n, i, result: longint;
	y: TIntArray;
// BEGIN SECRET
	secret: string;
// END SECRET
begin
	// BEGIN SECRET
	readln(secret);
	if secret <> input_secret then
	begin
		writeln(output_secret);
		writeln('SV');
		halt(0);
	end;
	// END SECRET
	readln(n);
	setlength(y, n);
	for i := 0 to n - 1 do
	begin
		read(y[i]);
	end;
	result := maximum_deevs(y);
	// BEGIN SECRET
	writeln(output_secret);
	writeln('OK');
	// END SECRET
	writeln(result);
end.
