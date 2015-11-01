%%% Exercise 1 of Chapter 16
%%% Purpose is to determine if
%%% an erl file needs recompilation
%%% by comparing the last modified date
%%% of the erl file and the beam file.
-module(fcomp).
-export([check/1]).
-import(calendar, [datetime_to_gregorian_seconds/1]).

-include_lib("kernel/include/file.hrl").

%% Meant to be called as check("somefile"). Omit the extension
%% 
%% If the .beam file was changed later than the .erl file then
%% we do not need to recompile. We check with subtraction / some
%% time conversion methods.
check(File) ->
	ErlF = File ++ ".erl",
	BeamF = File ++ ".beam",
	ErlTime = grab_mod_time(ErlF),
	BeamTime = grab_mod_time(BeamF),
	case get_time_diff(ErlTime, BeamTime) of
		X when X < 0 ->
			io:format("The file ~p probably needs to be recompiled.~n", [ErlF]);
		X when X >= 0 ->
			io:format(".beam file for ~p looks up to date!~n", [ErlF])
	end.

%% ctime is of the form {date(), time()}
%% where date() is {Year, Month, Day}
%% and time() is {Hour, Minute, Second}
grab_mod_time(File) ->
	case file:read_file_info(File) of
		{ok, Info} ->
			Info#file_info.ctime;
		{error, Reason} ->
			throw({error, Reason})
	end.

get_time_diff(X, Y) ->
	datetime_to_gregorian_seconds(Y) - datetime_to_gregorian_seconds(X).
