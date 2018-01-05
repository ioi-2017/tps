unit simurgh;

interface
uses graderlib;

function find_roads(n: longint; u, v: TIntArray): TIntArray;

implementation

function find_roads(n: longint; u, v: TIntArray): TIntArray;
var
	i, common: longint;
	r: TIntArray;
begin
	setlength(r, n - 1);
	for i := 0 to n - 2 do
		r[i] := i;
	common := count_common_roads(r);
	if common = n - 1 then
	begin
		find_roads := r;
		exit;
	end;
	r[0] := n - 1;
	find_roads := r;
end;

end.
