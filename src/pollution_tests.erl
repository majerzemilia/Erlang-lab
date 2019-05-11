%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. kwi 2019 19:03
%%%-------------------------------------------------------------------
-module(pollution_tests).
-author("Emilia").
-include_lib("eunit/include/eunit.hrl").

%% API
-compile(export_all).
-import(pollution,[createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3, getDailyMean/3,
  getMaximumVariationStation/2]).
-record(station, {name, coordinates}).
-record(coordinates, {longitude, latitude}).

prepareMonitor() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Aleja Słowackiego", {50.2345, 18.3445}, P),
  P2 = pollution:addValue({50.2345, 18.3445}, {{2019,4,28},{12,7,3}}, "PM10", 60.0, P1),
  P3 = pollution:addValue("Aleja Słowackiego", {{2019,4,6},{19,40,36}}, "PM2,5", 112.0, P2),
  P4 = pollution:addValue("Aleja Słowackiego", {{2019,4,6},{19,40,36}}, "PM10", 10.0, P3),
  P5 = pollution:addStation("Klaj", {59, 17}, P4),
  P6 = pollution:addValue("Klaj", {{2019,4,6},{21,40,36}}, "PM2,5", 113.0, P5),
  P7 = pollution:addValue({59,17}, {{2019,4,6},{5,40,36}}, "PM2,5", 339.0, P6),
  P7.

get_one_value_test() ->
  ?assertEqual(112.0, getOneValue("PM2,5",{{2019,4,6},{19,40,36}},{50.2345, 18.3445}, prepareMonitor())).

get_station_mean_test() ->
  ?assertEqual(35.0, getStationMean("PM10", "Aleja Słowackiego", prepareMonitor())).

get_daily_mean_test() ->
  ?assertEqual(188.0, getDailyMean("PM2,5", {2019,4,6}, prepareMonitor())).

get_maximum_variation_station_test() ->
  ?assertMatch({#station{name = "Klaj", coordinates = #coordinates{longitude = 59,latitude = 17}},_},
    getMaximumVariationStation("PM2,5", prepareMonitor())).




