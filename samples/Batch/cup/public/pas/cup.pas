unit cup;

interface
uses graderlib;

function find_cup(): TIntArray;

implementation

function find_cup(): TIntArray;
var
  result: array of longint;
begin
    setLength(result, 2);
    if ask_shahrasb(0, 0) < ask_shahrasb(1, 2) then
    begin
        result[0] := 0;
        result[1] := 0;
    end
    else begin
        result[0] := 1;
        result[1] := 2;
    end;
    find_cup := result;
end;

end.
