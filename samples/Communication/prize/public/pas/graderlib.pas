unit graderlib;

interface

type
	TIntArray = array of longint;

function ask(i: longint): TIntArray;

implementation

uses prize, math;

const
	max_q = 10000;

var
	n: longint;
	query_count: longint = 0;
	g: TIntArray;
	rank_count: array of TIntArray;

function ask(i: longint): TIntArray;
var
	res: TIntArray;
begin
	query_count += 1;
	if query_count > max_q then
	begin
		writeln(stderr, 'Query limit exceeded');
		halt(0);
	end;

	if (i < 0) or (i >= n) then
	begin
		write(stderr, 'Bad index: ');
		writeln(stderr, i);
		halt(0);
	end;

	setlength(res, 2);
	res[0] := rank_count[g[i] - 1][i + 1];
	res[1] := rank_count[g[i] - 1][n] - res[0];
	ask := res;
end;

var
	i, max_rank, r, res: longint;
begin
	read(n);

	setlength(g, n);
	for i := 0 to n - 1 do
	begin
		read(g[i]);
		if g[i] < 1 then
		begin
			writeln(stderr, 'Invalid rank ', g[i], ' at index ', i);
			halt(0);
		end;
	end;

	max_rank := g[0];
	for i := 0 to n - 1 do
		max_rank := max(max_rank, g[i]);

	setlength(rank_count, max_rank + 1);
	for r := 0 to max_rank do
	begin
		setlength(rank_count[r], n + 1);
		rank_count[r][0] := 0;
		for i := 1 to n do
		begin
			rank_count[r][i] := rank_count[r][i - 1];
			if g[i - 1] = r then
				rank_count[r][i] += 1;
		end;
	end;

	for i := 0 to n do
		for r := 1 to max_rank do
			rank_count[r][i] += rank_count[r - 1][i];
	
	res := prize.find_best(n);
	writeln(res);
	writeln('Query count:' , query_count);
end.
