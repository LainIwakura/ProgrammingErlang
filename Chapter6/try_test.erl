-module(try_test).
-export([demo1/0, demo2/0, demo3/0]).

generate_exception(1) -> a;
generate_exception(2) -> throw(a);
generate_exception(3) -> exit(a);
generate_exception(4) -> {'EXIT', a};
generate_exception(5) -> error(a).

demo1() ->
	[catcher_user(I) || I <- [1,2,3,4,5]].

demo2() ->
	[{I, (catch generate_exception(I))} || I <- [1,2,3,4,5]].

demo3() ->
	try generate_exception(5)
	catch
		error:X ->
			{X, erlang:get_stacktrace()}
	end.

catcher_dev(N) ->
	try generate_exception(N) of
		Val -> {N, normal, Val}
	catch
		throw:X -> {N, caught, thrown, X};
		exit:X  -> {N, caught, exited, X};
		error:X -> {N, caught, error, X}
	end.

catcher_user(N) ->
	try generate_exception(N) of
		Val -> {N, normal, Val}
	catch
		_:_ -> io:format("Something went wrong. Contact your system administrator.~n", [])
	end.
