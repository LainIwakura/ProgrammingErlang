-module(math_functions).
-export([even/1, odd/1, filter/2, split_filter/1, split_acc/1]).

even(X) ->
	if
		(X rem 2) =:= 0 -> true;
		true -> false %% Meant as a catch-all case for when the number is not divisible by 2
	end.

odd(X) ->
	not even(X).

filter(F, L) ->
	[X || X <- L, F(X) =:= true].

split_filter(L) ->
	Evens = [X || X <- L, even(X)],
	Odds  = [X || X <- L, odd(X)],
	{Evens, Odds}.

split_acc(L) ->
	split_helper(L, [], []).

split_helper([H|T], Evens, Odds) ->
	case (H rem 2) of
		1 -> split_helper(T, Evens, [H|Odds]);
		0 -> split_helper(T, [H|Evens], Odds)
	end;
split_helper([], Evens, Odds) ->
	{lists:reverse(Evens), lists:reverse(Odds)}.
