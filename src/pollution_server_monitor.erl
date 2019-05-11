%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. maj 2019 13:23
%%%-------------------------------------------------------------------
-module(pollution_server_monitor).
-author("Emilia").

%% API
-export([start/0, loop/0, stop/0]).

start() ->
  PID = spawn(pollution_server_monitor, loop, []),
  register(sup, PID).

loop() ->
  process_flag(trap_exit, true),
  pollution_server:start(),
  receive
    {'EXIT', _, _} -> loop()
  end.

stop() -> sup ! stop.

