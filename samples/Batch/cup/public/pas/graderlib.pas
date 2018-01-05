unit graderlib;

interface

type
  TIntArray = array of longint;

function ask_shahrasb(x, y: longint): longint;

implementation

uses cup;

const
  WORLD_SIZE = 1000 * 1000 * 1000;

var
  t: longint;
  a, b, qc: TIntArray;


procedure wrong_answer;
begin
  writeln(-1);
  halt;
end;

function ask_shahrasb(x, y: longint): longint;
var
  dx, dy: longint;
begin
  inc(qc[t]);
  if (abs(x) > WORLD_SIZE) or (abs(y) > WORLD_SIZE) then
  begin
    wrong_answer();
  end;
  dx := a[t] - x;
  dy := b[t] - y;
  ask_shahrasb := abs(dx) xor abs(dy);
end;

procedure run;
var
  result: array of longint;
  tests: longint;
  x, y: longint;
begin
  readln(tests);
  setLength(a, tests);
  setLength(b, tests);
  setLength(qc, tests);
  for t := 0 to tests - 1 do
  begin
    readln(a[t], b[t]);
  end;
  for t := 0 to tests - 1 do
  begin
    qc[t] := 0;
    result := find_cup();
    if length(result) <> 2 then
    begin
      wrong_answer;
    end;
    x := a[t];
    y := b[t];
    if (result[0] <> x) or (result[1] <> y) then
    begin
      qc[t] := -1;
    end;
  end;
  for t := 0 to tests - 1 do
  begin
    writeln(qc[t]);
  end;
end;

begin
	run;
end.
