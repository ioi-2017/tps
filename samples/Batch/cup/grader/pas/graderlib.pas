unit graderlib;

interface

type
  TIntArray = array of longint;

function ask_shahrasb(x, y: longint): longint;

implementation

uses cup;

const
  // BEGIN SECRET
  input_secret = 'e8a66651-560d-46a7-9496-0782b8bb7081';
  output_secret = 'be6fe19e-6ee7-4837-a81e-6f6902743b31';
  codelen = 2;
  code : array [0..codelen - 1] of longint = ($971CBAB, $3C3D64EE);
  // END SECRET
  WORLD_SIZE = 1000 * 1000 * 1000;

var
  t: longint;
  a, b, qc: TIntArray;

// BEGIN SECRET
function crypt(value, pos: longint): longint;
begin
  crypt := value xor code[pos and (codelen - 1)];
end;
// END SECRET

procedure wrong_answer;
begin
  // BEGIN SECRET
  writeln(output_secret);
  writeln('WA');
  // END SECRET
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
  // BEGIN SECRET
  dx := crypt(a[t], 0) - x;
  dy := crypt(b[t], 1) - y;
  // END SECRET
  ask_shahrasb := abs(dx) xor abs(dy);
end;

procedure run;
var
  result: array of longint;
  // BEGIN SECRET
  secret: string;
  // END SECRET
  tests: longint;
  x, y: longint;
begin
  // BEGIN SECRET
  readln(secret);
  if secret <> input_secret then
  begin
    writeln(output_secret);
    writeln('SV');
    halt;
  end;
  // END SECRET
  readln(tests);
  setLength(a, tests);
  setLength(b, tests);
  setLength(qc, tests);
  for t := 0 to tests - 1 do
  begin
    readln(a[t], b[t]);
    // BEGIN SECRET
    a[t] := crypt(a[t], 0);
    b[t] := crypt(b[t], 1);
    // END SECRET
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
    // BEGIN SECRET
    x := crypt(x, 0);
    y := crypt(y, 1);
    // END SECRET
    if (result[0] <> x) or (result[1] <> y) then
    begin
      qc[t] := -1;
    end;
  end;
  // BEGIN SECRET
  writeln(output_secret);
  writeln('OK');
  // END SECRET
  for t := 0 to tests - 1 do
  begin
    writeln(qc[t]);
  end;
end;

begin
	run;
end.
