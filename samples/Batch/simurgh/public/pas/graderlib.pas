unit graderlib;

interface

type
	TIntArray = array of longint;

function count_common_roads(var r: TIntArray): longint;

implementation

uses simurgh;

const
	maxq = 30000;

var
	n, m: longint;
	q: longint = 0;
	u, v: TIntArray;
	goal: array of boolean;

procedure wrong_answer();
begin
	writeln('NO');
	halt(0);
end;

function is_valid(var r: TIntArray): boolean;
var
	i: longint;
begin
	if length(r) <> n - 1 then
	begin
		is_valid := false;
		exit;
	end;

	for i := 0 to n - 2 do
		if (r[i] < 0) or (r[i] >= m) then
		begin
			is_valid := false;
			exit;
		end;

	is_valid := true;
end;

function _count_common_roads_internal(var r: TIntArray): longint;
var
	common, i: longint;
	is_common: boolean;
begin
	if not is_valid(r) then
		wrong_answer();

	common := 0;
	for i := 0 to n - 2 do
	begin
		is_common := goal[r[i]];
		if is_common then
			inc(common);
	end;

	_count_common_roads_internal := common;
end;

function count_common_roads(var r: TIntArray): longint;
begin
	inc(q);
	if q > maxq then
		wrong_answer();

	count_common_roads := _count_common_roads_internal(r);
end;

procedure run;
var
	res: TIntArray;
	i, id: longint;
begin
	read(n);
	read(m);

	setlength(u, m);
	setlength(v, m);

	for i := 0 to m - 1 do
	begin
		read(u[i]);
		read(v[i]);
	end;

	setlength(goal, m);
	for i := 0 to m - 1 do
		goal[i] := false;

	for i := 0 to n - 2 do
	begin
		read(id);
		goal[id] := true;
	end;

	res := find_roads(n, u, v);

	if _count_common_roads_internal(res) <> n - 1 then
		wrong_answer();

	writeln('YES');
end;

begin
	run;
end.
