unit prize;

interface
uses graderlib;

function find_best(n: longint): longint;

implementation

function find_best(n: longint): longint;
var
	res: array of longint;
	i: longint;
begin
	for i := 0 to n - 1 do
	begin
		res := ask(i);
		if res[0] + res[1] = 0 then
		begin
			find_best := i;
			exit;
		end;
	end;
	find_best := 0;
end;

end.
