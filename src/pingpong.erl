%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 10. kwi 2019 13:01
%%%-------------------------------------------------------------------
-module(pingpong).
-author("Emilia").

%% API
-export([start/0, ping_loop/0, pong_loop/0, play/1]).

start() ->
  register(ping, spawn(pingpong, ping_loop, [])),
  register(pong, spawn(pingpong, pong_loop, [])).


ping_loop()->
  receive
    0 -> ok;
    N ->
      io:format("Ping: ~w~n", [N]),
      timer:sleep(200),
      pong ! N-1,
      ping_loop()
  after
    20000 -> ok
  end.

pong_loop() ->
  receive
    0 -> ok;
    N ->
      io:format("Pong: ~w~n", [N]),
      timer:sleep(200),
      ping ! N-1,
      pong_loop()
  after
    20000 -> ok
  end.

play(N) ->
  ping ! N.

%stop() ->
