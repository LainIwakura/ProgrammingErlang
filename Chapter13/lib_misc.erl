-module(lib_misc).
-export([on_exit/2, keep_alive/2, my_spawn/3]).

on_exit(Pid, Fun) ->
	spawn(fun() ->
				Ref = monitor(process, Pid),
				receive
					{'DOWN', Ref, process, Pid, Why} ->
						Fun(Why)
				end
			end).

keep_alive(Name, Fun) ->
	register(Name, Pid = spawn(Fun)),
	on_exit(Pid, fun(_Why) -> keep_alive(Name, Fun) end).

%% Note: for exercise 2 in chapter 13 this doesn't seem to work..
%% not sure how to do without modifying on_exit()
my_spawn(Mod, Func, Args) ->
	Pid = spawn(Mod, Func, Args),
	Start = erlang:now(),
	on_exit(Pid,
		fun(Why) ->
			End = erlang:now(),
			Diff = timer:now_diff(End, Start),
			io:format(" ~p lived for ~p microseconds and died with ~p~n", [Pid, Diff, Why])
		end).


