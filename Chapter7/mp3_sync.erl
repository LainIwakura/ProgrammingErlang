%%% Note: This is all coming from chapter 7...the example in the chapter
%%% seems to be incomplete, however it's being kept due to important parts
%%% being there.
-module(mp3_sync).
-export([find_sync/2]).

find_sync(Bin, N) ->
	case is_header(N, Bin) of
		{ok, Len1, _} ->
			case is_header(N + Len1, Bin) of
				{ok, Len2, _} ->
					case is_header(N + Len1 + Len2, Bin) of
						{ok, _, _} ->
							{ok, N};
						error ->
							find_sync(Bin, N+1)
					end;
				error ->
					find_sync(Bin, N+1)
			end;
		error ->
			find_sync(Bin, N+1)
	end.

is_header(N, Bin) ->
	unpack_header(get_word(N, Bin)).

get_word(N, Bin) ->
	{_,<<C:4/binary,_/binary>>} = split_binary(Bin, N),
	C.

unpack_header(X) ->
	try decode_header(X)
	catch
		_:_ -> error
	end.

decode_header(<<2#11111111111:11,B:2,C:2,_D:1,E:4,F:2,G:1,Bits:9>>) ->
	Vsn = case B of
			0 -> {2,5};
			1 -> exit(bad_version);
			2 -> 2;
			3 -> 1
		  end,
	Layer = case C of
				0 -> exit(bad_layer);
				1 -> 3;
				2 -> 2;
				3 -> 1
			end,
	BitRate = bitrate(Vsn, Layer, E) * 1000,
	SampleRate = samplerate(Vsn, F),
	Padding = G,
	FrameLength = framelength(Layer, BitRate, SampleRate, Padding),
	if
		FrameLength < 21 ->
			exit(frame_size);
		true ->
			{ok, FrameLength, {Layer,BitRate,SampleRate,Vsn,Bits}}
	end;
decode_header(_) ->
	exit(bad_header).
