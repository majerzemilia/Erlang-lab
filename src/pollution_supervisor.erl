%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. maj 2019 18:43
%%%-------------------------------------------------------------------
-module(pollution_supervisor).
-behaviour(supervisor).
-author("Emilia").

%% API
-export([start_link/0, init/1]).

start_link() ->
  supervisor:start_link({local, sup}, ?MODULE, []).

init(_InitValue) ->
  {ok, {
    {one_for_all, 2, 3},
    [ {pollution_gen_server,
      {pollution_gen_server, start_link, []},
      permanent, brutal_kill, worker, [pollution_gen_server]}
    ]}
  }.

