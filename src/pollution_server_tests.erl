%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. kwi 2019 19:33
%%%-------------------------------------------------------------------
-module(pollution_server_tests).
-author("Emilia").
-include_lib("eunit/include/eunit.hrl").

%% API
-compile(export_all).
-import(pollution_server, [start/0, stop/0, addStation/2, addValue/4, removeValue/3, getOneValue/3, getStationMean/2, getDailyMean/2,
  getMaximumVariationStation/1]).
-record(station, {name, coordinates}).
-record(coordinates, {longitude, latitude}).

prepareMonitor() ->
  start(),
  addStation("Aleja Słowackiego", {50.2345, 18.3445}),
  addValue({50.2345, 18.3445}, {{2019,4,28},{12,7,3}}, "PM10", 60.0),
  addValue("Aleja Słowackiego", {{2019,4,6},{19,40,36}}, "PM2,5", 112.0),
  addValue("Aleja Słowackiego", {{2019,4,6},{19,40,36}}, "PM10", 10.0),
  addStation("Klaj", {59, 17}),
  addValue("Klaj", {{2019,4,6},{21,40,36}}, "PM2,5", 113.0),
  addValue({59,17}, {{2019,4,6},{5,40,36}}, "PM2,5", 339.0).

get_one_value_test() ->
  prepareMonitor(),
  ?assertEqual(112.0, getOneValue("PM2,5",{{2019,4,6},{19,40,36}},{50.2345, 18.3445})),
  stop().

get_station_mean_test() ->
  prepareMonitor(),
  ?assertEqual(35.0, getStationMean("PM10", "Aleja Słowackiego")),
  stop().

get_daily_mean_test() ->
  prepareMonitor(),
  ?assertEqual(188.0, getDailyMean("PM2,5", {2019,4,6})),
  stop().

get_maximum_variation_station_test() ->
  prepareMonitor(),
  ?assertMatch({#station{name = "Klaj", coordinates = #coordinates{longitude = 59,latitude = 17}},_},
    getMaximumVariationStation("PM2,5")),
  stop().
