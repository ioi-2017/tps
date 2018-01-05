unit coins;

interface
type
    TIntArray = array of longint;

function coin_flips(b: TIntArray; c: longint): TIntArray;
function find_coin(b: TIntArray): longint;

implementation

function coin_flips(b: TIntArray; c: longint): TIntArray;
var
    flips: TIntArray;
begin
    setLength(flips, 1);
    if b[c] = 1 then
        flips[0] := 0
    else
        flips[0] := 4;
	coin_flips := flips;
end;

function find_coin(b: TIntArray): longint;
begin
    if b[0] = 0 then
    begin
        find_coin := 0;
        exit;
    end;
    find_coin := 7;
end;

end.
