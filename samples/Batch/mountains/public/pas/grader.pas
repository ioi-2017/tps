uses mountains;

type 
	TIntArray = array of longint;

var
	n, i, result: longint;
	y: TIntArray;
begin
	readln(n);
	setlength(y, n);
	for i := 0 to n - 1 do
	begin
		read(y[i]);
	end;
	result := maximum_deevs(y);
	writeln(result);
end.
