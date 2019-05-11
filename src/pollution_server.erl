%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. kwi 2019 15:48
%%%-------------------------------------------------------------------
-module(pollution_server).
-author("Emilia").

%% API
-export([init/0, start/0, stop/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2,
  getDailyMean/2, getMaximumVariationStation/1, crashServer/0]).
-import(pollution, [createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3,
 getDailyMean/3, getMaximumVariationStation/2]).

start() -> register(server, spawn_link(?MODULE, init, [])).

stop() -> call(stop).

init() -> loop(createMonitor()).

getMonitor(Result, Monitor, Pid) ->
  case Result of
    {error, Error} -> Pid ! {reply, {error, Error}},
      loop(Monitor);
    _ -> Pid ! {reply, ok},
      loop(Result)
  end.

loop(Monitor) ->
  receive
    {request, Pid, {addStation, Name, Coords}} ->
      getMonitor(addStation(Name, Coords, Monitor), Monitor, Pid);
    {request, Pid, {addValue, Att, Date, Type, Value}} ->
      getMonitor(addValue(Att, Date, Type, Value, Monitor), Monitor, Pid);
    {request, Pid, {removeValue, Att, Date, Type}} ->
      getMonitor(removeValue(Att, Date, Type, Monitor), Monitor, Pid);
    {request, Pid, {getOneValue, Type, Date, Att}} ->
      Pid ! {reply, getOneValue(Type, Date, Att, Monitor)},
      loop(Monitor);
    {request, Pid, {getStationMean, Type, Att}} ->
      Pid ! {reply, getStationMean(Type, Att, Monitor)},
      loop(Monitor);
    {request, Pid, {getDailyMean, Type, Date}} ->
      Pid ! {reply, getDailyMean(Type, Date, Monitor)},
      loop(Monitor);
    {request, Pid, {getMaximumVariationStation, Type}} ->
      Pid ! {reply, getMaximumVariationStation(Type, Monitor)},
      loop(Monitor);
    {request, Pid, stop} ->
      Pid ! {reply, ok};
    crash -> 1/0
end.

%% client
call(Message) ->
  server ! {request, self(), Message},
  receive
    {reply, Reply} -> Reply
  end.

addStation(Name, Att) -> call({addStation, Name, Att}).
addValue(Att, Date, Type, Value) -> call({addValue, Att, Date, Type, Value}).
removeValue(Att, Date, Type) -> call({removeValue, Att, Date, Type}).
getOneValue(Type, Date, Att) -> call({getOneValue, Type, Date, Att}).
getStationMean(Type, Att) -> call({getStationMean, Type, Att}).
getDailyMean(Type, Date) -> call({getDailyMean, Type, Date}).
getMaximumVariationStation(Type) -> call({getMaximumVariationStation, Type}).
crashServer() -> server ! crash.