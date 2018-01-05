unit graderlib;

interface

type
	TIntArray = array of longint;

function count_common_roads(var r: TIntArray): longint;

implementation

uses simurgh;

const
	cipher_size = 64;
	cipher_key: array [0..cipher_size - 1] of longint = (1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 1, 0);

var
	maxq: longint = 30000;
	n, m: longint;
	q: longint = 0;
	u, v: TIntArray;
	goal: array of boolean;
	parent: TIntArray;

function xored(var v: array of boolean; i: longint): boolean; 
begin
	xored := v[i] xor boolean(cipher_key[i mod cipher_size] and 1);
end;

function find(v: longint): longint;
begin
	if parent[v] = v then
		find := v
	else
	begin
		parent[v] := find(parent[v]);
		find := parent[v];
	end;
end;

function merge(u, v: longint): boolean;
begin
	u := find(u);
	v := find(v);
	if u = v then
	begin
		merge := false;
		exit;
	end;
	parent[u] := v;
	merge := true;
end;

procedure wrong_answer();
begin
	writeln('lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs');
	writeln('WA');
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
	begin
		if (r[i] < 0) or (r[i] >= m) then
		begin
			is_valid := false;
			exit;
		end;
	end;
	setlength(parent, n);
	for i := 0 to n - 1 do
		parent[i] := i;
	for i := 0 to n - 2 do
	begin
		if not merge(u[r[i]], v[r[i]]) then
		begin
			is_valid := false;
			exit;
		end;
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
		is_common := xored(goal, r[i]);
		if is_common then
		begin
			inc(common);
		end;
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
	i, id, u_i, v_i: longint;
	secret: string;
begin
	readln(secret);
	if secret <> 'wrslcnopzlckvxbnair_input_simurgh_lmncvpisadngpiqdfngslcnvd' then
	begin
		writeln('lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs');
		writeln('SV');
		halt(0);
	end;
	read(n, m);
	read(maxq);
	setlength(u, m);
	setlength(v, m);
	for i := 0 to m - 1 do
	begin
		read(u_i, v_i);
		u[i] := u_i;
		v[i] := v_i;
	end;

	setlength(goal, m);
	for i := 0 to m - 1 do
		goal[i] := false;

	for i := 0 to n - 2 do
	begin
		read(id);
		goal[id] := true;
	end;

	for i := 0 to m - 1 do
	begin
		goal[i] := xored(goal, i);
	end;
	res := find_roads(n, u, v);
	
	if _count_common_roads_internal(res) <> n - 1 then
		wrong_answer();
	writeln('lxndanfdiadsfnslkj_output_simurgh_faifnbsidjvnsidjbgsidjgbs');
	writeln('OK');
	for i := 0 to length(res) - 1 do
	begin
		if i > 0 then
			write(' ');
		write(res[i]);
	end;
	writeln('');
end;

begin
	run;
end.
