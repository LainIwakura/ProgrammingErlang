-module(mydatetime).
-export([my_time_func/1, my_date_string/0, my_date_string/2]).

my_time_func(F) ->
	Start = erlang:now(),
	F(),
	End = erlang:now(),
	Diff = timer:now_diff(End, Start),
	io:format("Took ~p microseconds.~n", [Diff]).

my_date_string() ->
	{Year, Month, Day} = date(),
	{Hr, Min, _} = time(),
	io:format("It is ~s ~w~s, ~w at ~w:~2..0B~s~n", 
		[element(Month, month_names()), Day, get_suffix(Day),
			Year, reg_time(Hr), Min, am_or_pm(Hr)]).

my_date_string(YMD, HMS) ->
	{Year, Month, Day} = YMD,
	{Hr, Min, _} = HMS,
	io:format("It is ~s ~w~s, ~w at ~w:~2..0B~s~n", 
		[element(Month, month_names()), Day, get_suffix(Day),
			Year, reg_time(Hr), Min, am_or_pm(Hr)]).

month_names() ->
	{"January", "February", "March", "April", "May", "June", "July",
		"August", "September", "October", "November", "December"}.

get_suffix(X) ->
	if
		(X =:= 1) orelse (X =:= 21) orelse (X =:= 31) -> "st";
		(X =:= 2) orelse (X =:= 22) -> "nd";
		(X =:= 3) orelse (X =:= 23) -> "rd";
		true -> "th"
	end.

am_or_pm(X) ->
	if
		(X >= 12) -> "pm";
		true -> "am"
	end.

reg_time(X) ->
	if
		(X >= 12) -> X - 12;
		true -> X
	end.
