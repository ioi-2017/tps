unit wiring;

interface

type
	TIntArray = array of longint;

function min_total_length(b, r: TIntArray): int64;

implementation

const
	max_n = 200005;

var
	n, m: longint;
	p, t, head, cnt: array[0..max_n] of longint;
	ps, d: array[0..max_n] of int64;

function val (l, r: longint) : int64;
var
	m: longint;
	res, x, y: int64;
begin
	m := head[r];
	x := r + 1 - m;
	y := m - l;
	res := (ps[r+1] - ps[m]) - (ps[m] - ps[l]);
	if x > y then
		res := res - (x-y) * p[m-1];
	if x < y then
		res := res + (y-x) * p[m];
	val := res;
end;

function min_total_length (b, r: TIntArray) : int64;
var
	i, j, pb, pr, prev: longint;
begin
	n := length(b);
	m := length(r);
	pb := 0;
	pr := 0;
	i := 0;
	while i < n + m do
	begin
		if (pr = m) or ((pb <> n) and (b[pb] < r[pr])) then
		begin
			p[i] := b[pb];
			t[i] := 1;
			inc(pb);
		end
		else
		begin
			p[i] := r[pr];
			t[i] := 0;
			inc(pr);
		end;
		inc(i);
	end;

	n := n + m;
	ps[0] := 0;
	for i := 1 to n do
		ps[i] := ps[i-1] + p[i-1];

	for i := 1 to n do
		d[i] := 3617008641903833650;

	for i := 1 to n-1 do
	begin
		head[i] := head[i-1];
		if t[i] <> t[i-1] then
		begin
			prev := head[i];
			head[i] := i;
			d[i+1] := d[i] + val(i-1, i);
			cnt[i] := 1;
			for j := prev to i-1 do
				if d[i+1] > d[j] + val(j, i) then
				begin
					cnt[i] := i - j;
					d[i+1] := d[j] + val(j, i);
				end;
		end
		else
			if head[i] > 0 then
			begin
				cnt[i] := cnt[i-1];
				j := head[i] - cnt[i];
				if cnt[i-1] = i - head[i] then
					if (j > head[j]) and (d[j] + val(j, i) > d[j-1] + val(j-1, i)) then
					begin
						inc(cnt[i]);
						dec(j);
					end;
					d[i+1] := d[j] + val(j, i);
					if d[j+1] < d[j] then
						d[i+1] := d[j+1] + val(j, i);
			end;
	end;
	min_total_length := d[n];
end;

end.
