%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. mar 2019 13:07
%%%-------------------------------------------------------------------
-module(qsort).
-author("Emilia").

%% API
-export([qs/1, randomElems/3, compareSpeeds/3]).

lessThan(List, Arg) -> [X || X<-List, X<Arg].

grtEqThan(List, Arg) -> [X || X<-List, X>=Arg].

qs([]) -> [];
qs([Pivot|Tail]) -> qs( lessThan(Tail,Pivot) ) ++ [Pivot] ++ qs( grtEqThan(Tail,Pivot) ).

randomElems(N,Min,Max)-> [rand:uniform(Max-Min+1)+Min-1 || _ <- lists:seq(1,N)].

compareSpeeds(List, Fun1, Fun2) ->
  {T1,_} = timer:tc(Fun1, [List]),
  {T2,_} = timer:tc(Fun2, [List]),
  {T1,T2}.

% qsort:compareSpeeds(qsort:randomElems(20000,0,1000), fun qsort:qs/1, fun lists:sort/1).
% pwd() cd(), c() <-kompilowanie
%atom error + opis dla "niemozliwe", case of: wzorzec błędu + zadziałanie
%wspolrzedne: krotka 2-elem 2 floaty
%addstation:
