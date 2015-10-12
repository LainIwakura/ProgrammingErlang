-module(try_read).
-export([read/1]).

read(FileName) ->
	case file:read_file(FileName) of
		{ok, Bin} -> Bin;
		{error, Why} -> throw({error, Why})
	end.
