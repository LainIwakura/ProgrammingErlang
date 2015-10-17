-module(registered).
-export([start/2, test/0]).

start(AnAtom, Fun) when is_atom(AnAtom) ->
	register(AnAtom, spawn(Fun)).

test() ->
	spawn(registered, start, [cat, fun() -> io:format("Hi! I'm lain~~~n", []) end]),
	spawn(registered, start, [cat, fun() -> io:format("Hi! I'm lain~~~n", []) end]).
