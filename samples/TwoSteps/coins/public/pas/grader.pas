uses coins;

type
    TIntArray = array of longint;

function run_test(): string;
var
    c, coin, i, j: longint;
    b, flips: TIntArray;
    s: string;
begin
    readln(c);
    setLength(b, 64);
    for i := 0 to 7 do
    begin
        readln(s);
        for j := 0 to 7 do
        begin
            b[i * 8 + j] := ord(s[j + 1]) - ord('0');
        end;
    end;
    flips := coin_flips(b, c);
    if length(flips) = 0 then
    begin
        run_test := '0 turn overs';
        exit;
    end;
    for i := 0 to length(flips) - 1 do
    begin
        if (flips[i] < 0) or (flips[i] > 63) then
        begin
            run_test := 'cell number out of range';
            exit;
        end;
        b[flips[i]] := 1 - b[flips[i]];
    end;
    coin := find_coin(b);
    if coin <> c then
    begin
        run_test := 'wrong coin';
        exit;
    end;
    run_test := 'ok';
end;

var
    t, tests: longint;
    result: string;
begin
    readln(tests);
    for t := 1 to tests do
    begin
        result := run_test();
        writeln('test #', t, ': ', result);
    end;
end.
