uses coins;

type
	TIntArray = array of longint;

const
	input_secret = '8ad886d6-2d9e-4cab-aaed-47175facae96';
	pipe_secret = '3f900aa0-f7c9-4935-ac07-3f34523a67ab';
	output_secret = 'aa118b2a-086a-420f-811f-e3648ef86a25';
	board_width = 8;
	board_height = 8;
	board_size = board_width * board_height;

procedure shuffle(var v: TIntArray);
var
	i, j, tmp: longint;
begin
	randseed := 850928;
	for i := length(v) - 1 downto 0 do
	begin
		j := random(i+1);
		tmp := v[i];
		v[i] := v[j];
		v[j] := tmp;
	end;
end;

var
	pipe1: textfile;

procedure error1(msg, reason: string);
begin
	writeln(pipe1, pipe_secret);
	writeln(pipe1, msg);
	writeln(pipe1, reason);
	close(pipe1);
	halt(0);
end;

procedure error1(msg: string);
begin
	error1(msg, '');
end;

procedure error1();
begin
	error1('WA');
end;

procedure pass1(pipe_path: string);
var
	secret: string;
	tests, k : longint;
	t, i, j, flen: longint;
	cs: TIntArray;
	bs: array of TIntArray;
	row: string;
	flips, board_copy: TIntArray;
begin
	close(output);

	assign(pipe1, pipe_path);
	rewrite(pipe1);

	readln(secret);
	if secret <> input_secret then
	begin
		error1('SV');
	end;

	readln(tests, k);

	setlength(cs, tests);
	setlength(bs, tests);

	for t := 0 to tests - 1 do
	begin
		readln(cs[t]);
		setlength(bs[t], board_size);
		for i := 0 to board_height-1 do
		begin
			readln(row);
			for j := 0 to board_width-1 do
			begin
				bs[t][i * board_width + j] := ord(row[j + 1]) - ord('0');
			end;
		end;
	end;

	close(input);

	for t := 0 to tests - 1 do
	begin
		board_copy := bs[t];
		flips := coin_flips(board_copy, cs[t]);
		flen := length(flips);

		if (flen = 0) or (flen > k) then
		begin
			error1('WA', 'invalid flips length');
		end;

		for i := 0 to flen - 1 do
		begin
			if (flips[i] < 0) or (flips[i] >= board_size) then
			begin
				error1('WA', 'invalid coin index in flips');
			end;
		end;

		for i := 0 to flen - 1 do
		begin
			j := flips[i];
			bs[t][j] := 1 - bs[t][j];
		end;
	end;

	writeln(pipe1, pipe_secret);
	writeln(pipe1, 'OK');
	writeln(pipe1, tests);
	for t := 0 to tests - 1 do
	begin
		for i := 0 to length(bs[t]) do
		begin
			write(pipe1, bs[t][i]);
		end;
		writeln(pipe1);
	end;
	close(pipe1);
end;

procedure error2(msg, reason: string);
begin
	writeln(output_secret);
	writeln(msg);
	writeln(reason);
	close(output);
	halt(0);
end;

procedure error2(msg: string);
begin
	error2(msg, '');
end;


procedure pass2(pipe_path: string);
var
	pipe2: textfile;
	secret, status, reason: string;
	bs: array of TIntArray;
	t, _t, i, tests: longint;
	row: string;
	p, coin: TIntArray;
begin
	// readln(secret);
	// if secret <> input_secret then
	// begin
	// 	error2('SV');
	// end;
	// close(input);

	assign(pipe2, pipe_path);
	reset(pipe2);
	readln(pipe2, secret);
	if secret <> pipe_secret then
	begin
		error2('SV');
	end;

	readln(pipe2, status);
	if status <> 'OK' then
	begin
		readln(pipe2, reason);
		error2(status, reason);
	end;

	readln(pipe2, tests);

	setlength(bs, tests);
	for t := 0 to tests - 1 do 
	begin
		setlength(bs[t], board_size);
		readln(pipe2, row);
		for i := 0 to board_size-1 do
		begin
			bs[t][i] := ord(row[i + 1]) - ord('0');
		end;
	end;
	close(pipe2);

	setlength(p, tests);
	for t := 0 to tests - 1 do
	begin
		p[t] := t;
	end;
	shuffle(p);

	setlength(coin, tests);
	for _t := 0 to tests - 1 do
	begin
		t := p[_t];
		coin[t] := find_coin(bs[t]);
	end;

	writeln(output_secret);
	writeln('OK');
	for t := 0 to tests - 1 do
	begin
		writeln(coin[t]);
	end;
end;

var
	pass_type, code: longint;
begin
	if paramcount < 2 then
	begin
		writeln('invalid arguments');
		halt();
	end;

	val(paramstr(1), pass_type, code);

	if code <> 0 then
	begin
		writeln('invalid arguments');
		halt();
	end;

	if pass_type = 0 then
	begin
		pass1(paramstr(2))
	end
	else begin
		pass2(paramstr(2));
	end;
end.



