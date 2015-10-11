-module(mylists).
-export([sum/1, map/2, filter/2]).

sum([H|T]) -> H + sum(T);
sum([])    -> 0.

map(_, []) 	  -> [];
map(F, [H|T]) -> [F(H)|map(F, T)].

filter(P, [H|T]) ->
	case P(H) of
		true  -> [H|filter(P, T)];
		false -> filter(P, T)
	end;
filter(P, []) ->
	[].
