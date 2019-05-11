%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. maj 2019 14:10
%%%-------------------------------------------------------------------
-module(pollution_gen_server).
-behaviour(gen_server).
-author("Emilia").

%% API
-export([init/1, handle_call/3, handle_cast/2, stop/0, terminate/2, start_link/0]).
-export([addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2,
  getMaximumVariationStation/1, crashServer/0]).

start_link() ->
  gen_server:start_link({local, pollution_gen_server}, ?MODULE, [], []).

init(_Monitor) ->
  {ok, pollution:createMonitor()}.

stop() ->
  gen_server:cast(?MODULE, stop).

getMonitor(Result, Monitor) ->
  case Result of
    {error, _} -> Monitor;
    _ -> Result
  end.

addStation(Name, Att) -> gen_server:cast(?MODULE, {addStation, Name, Att}).
addValue(Att, Date, Type, Value) -> gen_server:cast(?MODULE, {addValue, Att, Date, Type, Value}).
removeValue(Att, Date, Type) -> gen_server:cast(?MODULE, {removeValue, Att, Date, Type}).
getOneValue(Type, Date, Att) -> gen_server:call(?MODULE, {getOneValue, Type, Date, Att}).
getStationMean(Type, Att) -> gen_server:call(?MODULE, {getStationMean, Type, Att}).
getDailyMean(Type, Date) -> gen_server:call(?MODULE, {getDailyMean, Type, Date}).
getMaximumVariationStation(Type) -> gen_server:call(?MODULE, {getMaximumVariationStation, Type}).
crashServer() -> gen_server:cast(?MODULE, crash).

handle_call({getOneValue, Type, Date, Att}, _From, Monitor) ->
  {reply, pollution:getOneValue(Type, Date, Att, Monitor), Monitor};
handle_call({getStationMean, Type, Att}, _From, Monitor) ->
  {reply, pollution:getStationMean(Type, Att, Monitor), Monitor};
handle_call({getDailyMean, Type, Date}, _From, Monitor) ->
  {reply, pollution:getDailyMean(Type, Date, Monitor), Monitor};
handle_call({getMaximumVariationStation, Type}, _From, Monitor) ->
  {reply, pollution:getMaximumVariationStation(Type, Monitor), Monitor}.

handle_cast({addStation, Name, Coords}, Monitor) ->
  {noreply, getMonitor(pollution:addStation(Name, Coords, Monitor), Monitor)};
handle_cast({addValue, Att, Date, Type, Value}, Monitor) ->
  {noreply, getMonitor(pollution:addValue(Att, Date, Type, Value, Monitor), Monitor)};
handle_cast({removeValue, Att, Date, Type}, Monitor) ->
  {noreply, getMonitor(pollution:removeValue(Att, Date, Type, Monitor), Monitor)};
handle_cast(stop, Value) ->
  {stop, normal, Value};
handle_cast(crash, _Val) ->
  1/0.

terminate(Reason, Value) ->
  io:format("Server: exit with value ~p~n", [Value]),
  Reason.