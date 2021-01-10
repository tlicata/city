%%%-------------------------------------------------------------------
%% @doc city public API
%% @end
%%%-------------------------------------------------------------------

-module(city_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    city_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
