unit graderlib;

interface

type
  TIntArray = array of longint;

function ask(i: longint): TIntArray;

implementation

uses prize;

var
  fin, fout: Text;

function ask(i: longint): TIntArray;
var
  result: TIntArray;
begin
  writeln(fout, 'A ', i);
  flush(fout);
  setLength(result, 2);
  {$i-}
  readln(fin, result[0], result[1]);
  {$i+}
  if IOResult <> 0 then
  begin
    writeln(stderr, 'tester error');
    writeln(stderr, 'could not read query response');
  end;
  if result[0] < 0 then
    halt;
  ask := result;
end;

procedure run;
var
  n, result: longint;
begin
  {$i-}
  assign(fin, ParamStr(1));
	reset(fin);
	assign(fout, ParamStr(2));
	append(fout);
  {$i+}

  {$i-}
  readln(fin, n);
  {$i+}
  if IOResult <> 0 then
  begin
    writeln(stderr, 'tester error');
    writeln(stderr, 'could not read ''n''');
  end;
  result := find_best(n);
  writeln(fout, 'B ', result);
  flush(fout);
end;

begin
	run;
end.
