%%%-------------------------------------------------------------------
%% @doc city public API
%% @end
%%%-------------------------------------------------------------------

-module(city_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Routes = [{'_', [{"/", cowboy_static, {file, "www/index.html"}},
                     {"/assets/[...]", cowboy_static, {dir, "www"}},
                     {"/info", info, []},
                     {"/live", live, []}]}],
    Dispatch = cowboy_router:compile(Routes),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{env => #{dispatch => Dispatch}}),
    city_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http).

%% internal functions
