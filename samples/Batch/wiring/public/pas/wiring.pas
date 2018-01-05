unit wiring;

interface

type
	TIntArray = array of longint;

function min_total_length(r, b: TIntArray): int64;

implementation

function min_total_length(r, b: TIntArray): int64;
begin
	min_total_length := 0;
end;

end.
