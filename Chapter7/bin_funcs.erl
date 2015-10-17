-module(bin_funcs).
-export([bin_reverse/1, byte_reverse/1, term_to_packet/1, packet_to_term/1]).

bin_reverse(Bin) ->
	erlang:list_to_binary(lists:reverse(binary:bin_to_list(Bin))).

%% Not sure if I need to specify 8 bits since it's a binary not a bitstring...
byte_reverse(Bin) ->
	[X || <<X:8>> <= bin_reverse(Bin)].

term_to_packet(Term) ->
	Bin = term_to_binary(Term),
	Size = byte_size(Bin),
	Packet = <<Size:32/unsigned-integer, Bin/binary>>,
	Packet.

packet_to_term(Packet) ->
	<<Header:32/unsigned-integer, Data:Header/binary>> = Packet,
	binary_to_term(Data).
