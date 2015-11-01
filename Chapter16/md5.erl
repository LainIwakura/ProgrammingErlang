%%% For chapter 16 exercise 2, and 3, 4
-module(md5).
-export([checksum/1, file_checksum/1, lfile_checksum/1, get_images/1, get_duplicates/1]).
-import(lists, [map/2, flatten/1, zip/2, unzip/1, member/2, append/1]).
-import(proplists, [get_all_values/2, lookup_all/2]).
-import(lib_find, [files/3]).

-define(PIC_DIR, "/Users/lain/Pictures/").

checksum(String) ->
	flatten(list_to_hex(binary_to_list(erlang:md5(String)))).

file_checksum(File) ->
	case file:read_file(File) of
		{ok, Contents} ->
			checksum(Contents);
		{error, Reason} ->
			case Reason of
				enoent ->
					io:format("Error: file not found.~n");
				_ ->
					io:format("Unknown error.~n")
			end
	end.

%% Calculate the checksum of a large file
lfile_checksum(File) ->
	MContext = erlang:md5_init(),
	case file:read_file(File) of
		{ok, Contents} ->
			<<Front:1024/bitstring, Rest/bitstring>> = Contents,
			Hash = get_hash(MContext, Front, Rest),
			%% Enable below to print the line, otherwise we are just returning the result.
			%% io:format("~p~n", [flatten(list_to_hex(binary_to_list(Hash)))])
			flatten(list_to_hex(binary_to_list(Hash)))
	end.

get_hash(Context, Header, Tail) when erlang:bit_size(Tail) >= 1024 ->
	<<Front:1024/bitstring, Rest/bitstring>> = Tail,
	get_hash(erlang:md5_update(Context, Header), Front, Rest);

get_hash(Context, Header, Tail) when erlang:bit_size(Tail) < 1024 ->
	erlang:md5_final(erlang:md5_update(erlang:md5_update(Context, Header), Tail)).

get_duplicates(Flag) when Flag =:= "jpg"; Flag =:= "png" ->
	case report_duplicates(get_images(Flag), []) of
		[] ->
			io:format("No duplicates for that file type!~n");
		Dups -> pretty_print_dups(Dups)
	end.

pretty_print_dups([]) ->
	ok;
pretty_print_dups([H|Tail]) ->
	io:format("The following images are all duplicates:~n~p~n", [H]),
	pretty_print_dups(Tail).

%% Get a list of tuples containing a picture and it's corresponding md5 hash.
get_images(Flag) when Flag =:= "jpg"; Flag =:= "png" ->
	Files = files(?PIC_DIR, "*." ++ Flag, true),
	Hashes = map(fun(X) -> lfile_checksum(X) end, Files),
	zip(Hashes, Files);
get_images(Flag) when Flag =/= "jpg", Flag =/= "png" ->
	io:format("We were unable to recognize that file type.~nOnly working with jpg and png.~n"). 

report_duplicates([], Duplicates) ->
	Duplicates;
report_duplicates([H|Tail], Duplicates) ->
	{Hash, File} = H,
	{Hashes, _} = unzip(Tail),
	case count(Hash, Hashes) of
		{ok, Num} when Num > 0 ->
			Dups = get_all_values(Hash, lookup_all(Hash, [H|Tail])),
			case member(File, append(Duplicates)) of
				true ->
					report_duplicates(Tail, Duplicates);
				false ->
					report_duplicates(Tail, [Dups|Duplicates])
			end;
		_ -> 
			report_duplicates(Tail, Duplicates)
	end.

count(Needle, Haystack) ->
	count(Needle, Haystack, 0).
count(_, [], Count) -> {ok, Count};
count(X, [X|Rest], Count) -> count(X, Rest, Count+1);
count(X, [_|Rest], Count) -> count(X, Rest, Count).

list_to_hex(L) ->
	map(fun(X) -> int_to_hex(X) end, L).

%% compute the hex value of the int
int_to_hex(N) when N < 256 ->
	[hex(N div 16), hex(N rem 16)].

%% Get the hex representation of a single byte. 0x00 - 0xFF
hex(N) when N < 10 ->
	$0+N;
hex(N) when N >= 10, N < 16 ->
	$a + (N - 10).
