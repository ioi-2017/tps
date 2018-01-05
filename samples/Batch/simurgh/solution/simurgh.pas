unit simurgh;

interface
uses graderlib;

function find_roads(n: longint; u, v: TIntArray): TIntArray;

implementation

type
	pair = record
		first, second: longint;
	end;

const
	maxn = 512;
	maxm = 131072;

var
	highest: array[0..maxn] of pair;
	mark: array[0..maxn] of boolean;
	mat: array[0..maxn,0..maxn] of boolean;
	ind: array[0..maxn,0..maxn] of longint;
	h, state, par, deg: array[0..maxn] of longint;
	last_num, _last_id: array[0..maxm] of longint;
	right__edges_vec, __edges_vec, ans, tree, answer: TIntArray;
	__edges_vec_size: longint = 0;
	answer_size: longint = 0;
	edges: array[0..maxm] of pair;
	bit: array[0..maxm] of boolean;
	_next_: longint = 1;
	_n, m: longint;

procedure _renew();
var
	__edges_new: TIntArray;
	index, size, i, pt: longint;
begin
	size := 0;
	for index := 0 to __edges_vec_size - 1 do
	begin
		i := __edges_vec[index];
		if bit[i] and (_last_id[i] <> _next_) then
			inc(size);
	end;
	setlength(__edges_new, size);
	pt := 0;
	for index := 0 to __edges_vec_size - 1 do
	begin
		i := __edges_vec[index];
		if bit[i] and (_last_id[i] <> _next_) then
		begin
			__edges_new[pt] := i;
			inc(pt);
			_last_id[i] := _next_;
		end;
	end;
	inc(_next_);
	__edges_vec_size := size;
	for i := 0 to __edges_vec_size - 1 do
		__edges_vec[i] := __edges_new[i];
end;

function query(): longint;
var
	res, i: longint;
begin
	_renew();
	for i := 0 to _n - 2 do
	begin
		right__edges_vec[i] := __edges_vec[i];
	end;
	res := count_common_roads(right__edges_vec);
	if res = _n - 1 then
		ans := right__edges_vec;
	query := res;
end;

procedure toggle(i: longint);
begin
	if not bit[i] then
	begin
		bit[i] := true;
		__edges_vec[__edges_vec_size] := i;
		inc(__edges_vec_size);
	end
	else
		bit[i] := false;
end;

procedure _reset();
var
	e: longint;
begin
	while __edges_vec_size > 0 do
	begin
		e := __edges_vec[__edges_vec_size - 1];
		dec(__edges_vec_size);
		bit[e] := false;
	end;
end;
procedure dfs(v, p: longint);
var
	e, u: longint;
begin
	par[v] := p;
	mark[v] := true;
	highest[v].first := h[v];
	highest[v].second := -1;
	for u := 0 to _n - 1 do
		if mat[v][u] then
		begin
			e := ind[v][u];
			if not mark[u] then
			begin
				h[u] := h[v] + 1;
				dfs(u, v);
				if highest[v].first > highest[u].first then
				begin
					highest[v].first := highest[u].first;
					highest[v].second := highest[u].second;
				end;
			end
			else
				if (highest[v].first > h[u]) and (u <> p) then
				begin
					highest[v].first := h[u];
					highest[v].second := e;
				end;
		end;
	if p <> -1 then
		toggle(ind[v][p]);
end;
procedure dfs2(v: longint);
var
	p, back_edge, u, x, y, cur_edge, back_edge_num, mn, mx, cur, for_a_one, tmp: longint;
begin
	p := par[v];
	for u := 0 to _n - 1 do
		if mat[v][u] and (par[u] = v) then
			dfs2(u);
	if (p <> -1) and (state[v] = -1) then
	begin
		if highest[v].first > h[p] then
		begin
			state[v] := 1;
			exit;
		end;
		back_edge := highest[v].second;
		x := edges[back_edge].first;
		y := edges[back_edge].second;
		if h[x] > h[y] then
		begin
			tmp := x;
			x := y;
			y := tmp;
		end;
		back_edge_num := query();
		mn := back_edge_num;
		mx := mn;
		cur := y;
		for_a_one := -1;
		toggle(back_edge);
		while cur <> x do
		begin
			if (state[cur] = -1) or (for_a_one = -1) then
			begin
				cur_edge := ind[cur][par[cur]];
				toggle(cur_edge);
				last_num[cur_edge] := query();
				if mn > last_num[cur_edge] then
					mn := last_num[cur_edge];
				if mx < last_num[cur_edge] then
					mx := last_num[cur_edge];
				if state[cur] <> -1 then
				begin
					for_a_one := last_num[cur_edge];
					if state[cur] = 0 then
						dec(for_a_one);
				end;
				toggle(cur_edge);
			end;
			cur := par[cur];
		end;
		toggle(back_edge);
		cur := y;
		while cur <> x do
		begin
			if state[cur] = -1 then
			begin
				cur_edge := ind[cur][par[cur]];
				if for_a_one <> -1 then
				begin
					state[cur] := 0;
					if last_num[cur_edge] = for_a_one then
						state[cur] := 1;
				end
				else
					if mn = mx then
						state[cur] := 0
					else
					begin
						state[cur] := 0;
						if last_num[cur_edge] = mn then
							state[cur] := 1;
					end;
			end;
			cur := par[cur];
		end;
	end;
end;
function root(v: longint): longint;
begin
	if par[v] < 0 then
		root := v
	else
	begin
		par[v] := root(par[v]);
		root := par[v];
	end;
end;
function merge(ind: longint): boolean;
var
	x, y, tmp: longint;
begin
	x := edges[ind].first;
	y := edges[ind].second;
	x := root(x);
	y := root(y);
	if x = y then
	begin
		merge := false;
		exit;
	end;
	toggle(ind);
	if par[y] < par[x] then
	begin
		tmp := x;
		x := y;
		y := tmp;
	end;
	par[x] := par[x] + par[y];
	par[y] := x;
	merge := true;
end;
function edge_state(i: longint): longint;
var
	x, y, tmp: longint;
begin
	x := edges[i].first;
	y := edges[i].second;
	if h[x] > h[y] then
	begin
		tmp := x;
		x := y;
		y := tmp;
	end;
	edge_state := state[y];
end;
function query_for_forest(subset: TIntArray): longint;
var
	sum, i: longint;
begin
	_reset();
	sum := 0;
	for i := 0 to maxn do
		par[i] := -1;
	for i := 0 to length(subset) - 1 do
		merge(subset[i]);
	for i := 0 to length(tree) - 1 do
		if merge(tree[i]) then
			sum := sum + edge_state(tree[i]);
	query_for_forest := query() - sum;
end;
procedure calc_deg(v: longint);
var
	subset: TIntArray;
	size, u, i: longint;
begin
	size := 0;
	for u := 0 to _n - 1 do
		if mat[v][u] then
			inc(size);
	setlength(subset, size);
	i := 0;
	for u := 0 to _n - 1 do
		if mat[v][u] then
		begin
			subset[i] := ind[v][u];
			inc(i);
		end;
	deg[v] := query_for_forest(subset);
end;
procedure remove(v: longint);
var
	ed, subset: TIntArray;
	size, e, u, i, l, r, mid: longint;
begin
	if (deg[v] = 0) or mark[v] then
		exit;
	size := 0;
	for u := 0 to _n - 1 do
		if mat[v][u] and (not mark[u]) then
			inc(size);
	setlength(ed, size);
	i := 0;
	for u := 0 to _n - 1 do
		if mat[v][u] and (not mark[u]) then
		begin
			ed[i] := ind[v][u];
			inc(i);
		end;
	l := 0;
	r := size - 1;
	while r > l do
	begin
		mid := (l + r) div 2;
		setlength(subset, mid - l + 1);
		for i := l to mid do
			subset[i - l] := ed[i];
		if query_for_forest(subset) <> 0 then
			r := mid
		else
			l := mid + 1;
	end;
	e := ed[l];
	u := edges[e].first + edges[e].second - v;
	answer[answer_size] := e;
	inc(answer_size);
	dec(deg[u]);
	mark[v] := true;
	if deg[u] = 1 then
		remove(u);
end;

function find_roads(n: longint; u, v: TIntArray): TIntArray;
var
	i, j: longint;
begin
	_n := n;
	m := length(v);
	setlength(__edges_vec, maxm);
	setlength(right__edges_vec, n - 1);
	setlength(answer, n - 1);
	for i := 0 to maxn do
	begin
		highest[i].first := 0;
		highest[i].second := 0;
		state[i] := -1;
		h[i] := 0;
		par[i] := 0;
		deg[i] := 0;
		mark[i] := false;
		for j := 0 to maxn do
		begin
			ind[i][j] := -1;
			mat[i][j] := false;
		end;
	end;
	for i := 0 to maxm do
	begin
		last_num[i] := 0;
		_last_id[i] := 0;
		edges[i].first := 0;
		edges[i].second := 0;
		bit[i] := false;
	end;
	for i := 0 to m - 1 do
	begin
		edges[i].first := v[i];
		edges[i].second := u[i];
		ind[v[i]][u[i]] := i;
		ind[u[i]][v[i]] := i;
		mat[v[i]][u[i]] := true;
		mat[u[i]][v[i]] := true;
	end;
	dfs(0, -1);
	dfs2(0);
	for i := 0 to maxn do
		mark[i] := false;
	setlength(tree, n - 1);
	j := 0;
	for i := 0 to m - 1 do
		if bit[i] then
		begin
			tree[j] := i;
			inc(j);
		end;
	for i := 0 to n - 1 do
		calc_deg(i);
	for i := 0 to n - 1 do
		if deg[i] = 1 then
			remove(i);
	query_for_forest(answer);
	find_roads := ans;
end;

end.


