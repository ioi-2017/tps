{
	Author: Saeed
	Verdict: Correct solution
}

unit prize;

interface

type
	TIntArray = array of longint;

function find_best(n : longint) : longint;


implementation

uses graderlib;

var
    cnt : longint;

function bs(l, r, nl, nr, numb : longint) : longint;
var
	tmp : TIntArray;
	i, tmpl, tmpr, midl, midr, mid : longint;
begin
	if cnt <= 0 then
	begin
		bs := -1;
		exit;
	end;
        dec(cnt);
	if l > r then
	begin
		bs := -1;
		exit;
	end;
	for i := 0 to r-l do
	begin
		midl := (l + r) div 2 - i div 2;
		midr := (l + r) div 2 + (i+1) div 2;
		if i mod 2 = 0 then
			mid := midl
		else
			mid := midr;
		tmp := ask(mid);
		if tmp[0] + tmp[1] = 0 then
		begin
			bs := mid;
			exit;
		end;
                if tmp[0] + tmp[1] > numb then
                begin
                    cnt := 0;
                    bs := -1;
                    exit;
                end;
		if tmp[0] + tmp[1] = numb then
		begin
			if i mod 2 = 0 then
                        begin
				tmpl := 0;
				tmpr := midr - midl;
                        end
			else
                        begin
				tmpl := midr - midl;
				tmpr := 0;
			end;
			if tmp[0] - tmpl > nl then
			begin
				bs := bs(l, midl-1, nl, tmp[1] + tmpl, numb);
				if bs <> -1 then
					exit;
			end;
			if tmp[1] - tmpr > nr then
                        begin
				bs := bs(midr+1, r, tmp[0] + tmpr, nr, numb);
				if bs <> -1 then
					exit;
                        end;
                        break;
		end;
	end;
	bs := -1;
end;

function find_best(n : longint) : longint;
var
	tmp : TIntArray;
	p, i, numb : longint;
begin
	if n = 1 then
	begin
		find_best := 0;
		exit;
	end;
	numb := 1;
        cnt := 20;
	find_best := bs(0, n-1, 0, 0, numb);
	if find_best <> -1 then
		exit;
	p := 0;
	for i := 0 to round(Sqrt(n)) + 30 do
	begin
		if numb > 26 then
			break;
                tmp := ask(i);
		if tmp[0] + tmp[1] = 0 then
		begin
			find_best := i;
			exit;
		end;
		if numb < tmp[0] + tmp[1] then
                begin
                        writeln(p);
			p := i;
			numb := tmp[0] + tmp[1];
                end;
	end;
        cnt := 1000000;
	find_best := bs(p, n-1, p, 0, numb);
end;

end.
