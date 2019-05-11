%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. kwi 2019 16:04
%%%-------------------------------------------------------------------
-module(pollution).
-author("Emilia").

%% API
-export([createMonitor/0, addStation/3, addValue/5, removeValue/4, getOneValue/4, getStationMean/3,
  getDailyMean/3, getMaximumVariationStation/2]).

-record(station, {name, coordinates}).
-record(coordinates, {longitude, latitude}).
-record(measurement, {datetime, type}).
-record(date, {year, month, day}).
-record(time, {hour, minute, second}).
-record(datetime, {date, time}).

%%tworzy i zwraca nowy monitor zanieczyszczeń
createMonitor()-> #{}.

%% dodaje do monitora wpis o nowej stacji pomiarowej (nazwa i współrzędne geograficzne), zwraca zaktualizowany monitor;
addStation(Name, {Longitude, Latitude}, Monitor) ->
  case isStation(Monitor, Name) or isStation(Monitor,#coordinates{longitude = Longitude, latitude = Latitude}) of
    true -> {error, "Ta stacja jest juz zarejestrowana"};
    false -> Monitor#{#station{name = Name, coordinates = #coordinates{longitude = Longitude, latitude = Latitude}}=>#{}}
  end.

isStation(Monitor, Attribute) ->
  Station = findKey(maps:keys(Monitor),Attribute),
  case Station of
    {error, _} -> false;
    _ -> true
  end.

findKey([], _) -> {error, "Station does not exist"};
findKey([#station{name = Name, coordinates = Coordinates}|T], Attribute) ->
  case (Attribute == Name) or (Attribute == Coordinates) of
    true -> #station{name = Name, coordinates = Coordinates};
    false -> findKey(T, Attribute)
  end.

packToDatetime({{Y, Mth, D}, {H, Min, S}}) ->
  Datetime = #datetime{date = #date{year = Y, month = Mth, day = D}, time = #time{hour = H, minute = Min, second = S}},
  Datetime.

getAttribute(Attribute) ->
  case Attribute of
    {X,Y} -> #coordinates{longitude = X, latitude = Y};
    _ -> Attribute
  end.

%%dodaje odczyt ze stacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru, wartość), zwraca zaktualizowany monitor;
addValue(Attribute, Givendate, Type, Value, Monitor) ->
  Att = getAttribute(Attribute),
  case isStation(Monitor, Att) of
    true ->
      Station = findKey(maps:keys(Monitor), Att),
      Measurements = maps:get(Station, Monitor),
      Measurement = #measurement{datetime = packToDatetime(Givendate), type = Type},
      case maps:is_key(Measurement, Measurements) of
        false -> Monitor#{Station => Measurements#{Measurement=>Value}};
        true -> {error, "Measure already exists"}
      end;
    false -> {error, "Station does not exist"}
  end.

%%usuwa odczyt ze stacji (współrzędne geograficzne lub nazwa stacji, data, typ pomiaru), zwraca zaktualizowany monitor;
removeValue(Attribute, Givendate, Type, Monitor) ->
  Att = getAttribute(Attribute),
  case isStation(Monitor, Att) of
    true ->
      Station = findKey(maps:keys(Monitor), Att),
      Measurements = maps:get(Station, Monitor),
      Measurement = #measurement{datetime = packToDatetime(Givendate), type = Type},
      case maps:is_key(Measurement, Measurements) of
        true -> Monitor#{Station => maps:remove(Measurement,Measurements)};
        false -> {error, "Measure does not exist"}
      end;
    false -> {error, "Trying to delete measurement from not existing station"}
  end.

%%zwraca wartość pomiaru o zadanym typie, z zadanej daty i stacji;
getOneValue(Type, Givendate, Attribute, Monitor) ->
  Att = getAttribute(Attribute),
  case isStation(Monitor, Att) of
    true ->
      Station = findKey(maps:keys(Monitor),Att),
      Measurements = maps:get(Station, Monitor),
      Measurement = #measurement{datetime = packToDatetime(Givendate), type = Type},
      case maps:is_key(Measurement, Measurements) of
        false -> {error, "Measurement does not exist"};
        true -> maps:get(Measurement,Measurements)
      end;
    false -> {error, "Trying to get a value from not existing station"}
  end.

%%zwraca średnią wartość parametru danego typu z zadanej stacji;
getStationMean(Type, Attribute, Monitor) ->
  Att = getAttribute(Attribute),
  case isStation(Monitor, Att) of
    true ->
      Station = findKey(maps:keys(Monitor),Att),
      Measurements = maps:get(Station, Monitor),
      Pred = fun(K,_) -> K#measurement.type == Type end,
      Search = maps:filter(Pred, Measurements),
      case mean(maps:values(Search)) of
        {error, _} -> "No measurements for this station";
        _ -> mean(maps:values(Search))
      end;
    false -> {error, "Trying to get value from not existing station"}
  end.

getMeanFromAllStations([], _, _, _, 0) -> {error, "Wrong type or date"};
getMeanFromAllStations([], _, _, Sum, Count) -> Sum/Count;
getMeanFromAllStations([H|T], Date, Type, Sum, Count) ->
  Pred = fun(K,_) -> (K#measurement.type == Type) and (K#measurement.datetime#datetime.date == Date) end,
  Search = maps:filter(Pred, H),
  getMeanFromAllStations(T, Date, Type, Sum+lists:sum(maps:values(Search)), Count+length(maps:values(Search))).

%%zwraca średnią wartość parametru danego typu, danego dnia na wszystkich stacjach;
getDailyMean(Type, {Y, Mth, D}, Monitor) ->
  Allmeasurements = maps:values(Monitor),
  getMeanFromAllStations(Allmeasurements, #date{year = Y, month = Mth, day = D}, Type, 0, 0).

getVariation([], _, Max, Min) -> Max-Min;
getVariation([{#measurement{datetime = #datetime{date= _, time = _}, type = Type}, Value}|T], Giventype, Max, Min)->
  case Giventype == Type of
    true -> getVariation(T, Giventype, max(Value, Max), min(Value, Min));
    false -> getVariation(T, Giventype, Max, Min)
  end.

generateListTuplesStationVariation([], _, List) -> List;
generateListTuplesStationVariation([{Hs,Hm}|T], Type, List) ->
  {Station, Variation} = {Hs, getVariation(maps:to_list(Hm), Type, 0, 100000)},
  generateListTuplesStationVariation(T, Type, [{Station, Variation}] ++List).

findMaxVariation([], Station, Max) -> {Station, Max};
findMaxVariation([{Stat, Val} |T], Station, Max) ->
  case Val >= Max of
    true -> findMaxVariation(T, Stat, Val);
    false -> findMaxVariation(T, Station, Max)
  end.

%%zwraca stację z największymi notowanymi różnicami zanieczyszczeń danego typu
getMaximumVariationStation(Type, Monitor) ->
  List = generateListTuplesStationVariation(maps:to_list(Monitor), Type, []),
  Startstation = #station{name = "", coordinates = #coordinates{longitude = 0,latitude = 0}},
  Var = findMaxVariation(List, Startstation, 0),
  case Var of
    {Startstation, _} -> {error, "Wrong type"};
    _ -> Var
  end.

mean([]) -> {error, "No readings for given arguments"};
mean(L) -> lists:sum(L) / length(L).