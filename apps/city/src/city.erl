-module(city).

-behavior(gen_server).

-export([hey/0, list_streets/0, populate_streets/0, start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link(City) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [City], []).

hey() ->
    gen_server:call(?MODULE, hey).
list_streets() ->
    gen_server:call(?MODULE, list_streets).
populate_streets() ->
    gen_server:call(?MODULE, populate_streets).

init([City]) ->
    process_flag(trap_exit, true),
    io:format("~p starting~n", [?MODULE]),
    db:open(City),
    {ok, City}.

handle_call(hey, _From, City) ->
    {reply, io:format("Hey, from ~s~n", [City]), City};
handle_call(list_streets, _From, City) ->
    {reply, string:join(street:list_streets(City), "\n"), City};
handle_call(populate_streets, _From, City) ->
    [street:start(City, Street) || Street <- street:list_streets(City)],
    {reply, streets_populated, City};
handle_call(_Any, _From, City) ->
    {reply, "I don't understand...", City}.

handle_cast(_Msg, N) -> {noreply, N}.
handle_info(_Info, N) -> {noreply, N}.

terminate(_Reason, City) ->
    io:format("~p module for ~s stopping~n", [?MODULE, City]),
    db:close(City),
    ok.

code_change(_OldVsn, N, _Extra) ->
    {ok, N}.
