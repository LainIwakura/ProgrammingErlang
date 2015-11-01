-module(lib_misc).
-export([ls/1]).
-export([dump/2]).
-export([file_size_and_type/1]).

-import(lists, [map/2, sort/1]).

%% For the file_info record definition
-include_lib("kernel/include/file.hrl").

dump(File, Term) ->
	Out = File ++ ".tmp",
	io:format("** dumping to ~s~n", [Out]),
	{ok, S} = file:open(Out, [write]),
	io:format(S, "~p~n", [Term]),
	file:close(S).

file_size_and_type(File) ->
	case file:read_file_info(File) of
		{ok, Facts} ->
			{Facts#file_info.type, Facts#file_info.size};
		_ ->
			error
	end.

ls(Dir) ->
	{ok, L} = file:list_dir(Dir),
	map(fun(I) -> {I, file_size_and_type(Dir ++ "/" ++ I)} end, sort(L)). 
