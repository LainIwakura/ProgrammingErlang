-module(ch13).
-export([my_spawn/3, my_spawn/4, test/0, keep_running/0, runner/0]).

%% This works but in a weird way.
%% If you compile it and do ch13:my_spawn(ch13, test, []).
%% the shell will hang but you can kill the process and see
%% the monitor print the exit msg / time lived.
my_spawn(Mod, Func, Args) ->
	spawn_monitor(Mod, Func, Args),
	Start = erlang:now(),
	receive
		{'DOWN', _Ref, process, Pid, Why} ->
			End = erlang:now(),
			Diff = timer:now_diff(End, Start),
			io:format("Process ~p was running for ~p microseconds. Died with: ~p~n", [Pid, Diff, Why])
	end.

my_spawn(Mod, Func, Args, Time) ->
	{Pid, _UnusedRef} = spawn_monitor(Mod, Func, Args),
	receive
		{'DOWN', _Ref, process, Pid, Why} ->
			io:format("Process ~p died with: ~p~n", [Pid, Why])
	after Time ->
		io:format("~p ran too long. Killing.~n", [Pid]),
		exit(Pid, exit)
	end.

test() ->
	receive
		{Sender, exit} -> 
			exit(string:concat("Received exit from", Sender));
		{Sender, Var} -> 
			io:format("~p sent us ~p! Isn't that nice?~n", [Sender, Var])
	end.

runner() ->
	io:format("I'm still running!~n"),
	receive
		_Any -> true
	after 5000 ->
		runner()
	end.

keep_running() ->
	register(to_keep_alive, Pid = spawn(ch13, runner, [])),
	_Ref = monitor(process, Pid),
	receive
		{'DOWN', _Ref, process, _Pid, _Why} ->
			keep_running()
	end.
