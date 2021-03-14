-module(city).

-behavior(gen_server).

-export([find_address/1, list_streets/0, populate_streets/0, start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

start_link(City) ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [City], []).

list_streets() ->
    gen_server:call(?MODULE, list_streets).
populate_streets() ->
    gen_server:call(?MODULE, populate_streets).
find_address(Addr) ->
    gen_server:call(?MODULE, {find_address, Addr}).

init([City]) ->
    process_flag(trap_exit, true),
    io:format("~p starting~n", [?MODULE]),
    db:open(City),
    {ok, {City, []}}.

handle_call(list_streets, _From, {City, _} = State) ->
    {reply, string:join(street:list_streets(City), "\n"), State};
handle_call(populate_streets, _From, {City, []}) ->
    Pids = [street:start(City, Street) || Street <- street:list_streets(City)],
    {reply, streets_populated, {City, Pids}};
handle_call(populate_streets, _From, State) ->
    {reply, streets_populated, State};
handle_call({find_address, Addr}, _From, {_City, StreetPids} = State) ->
    [Pid ! {self(), find, Addr} || Pid <- StreetPids],
    receive
        {found, Pid} ->
            {reply, {address_found, Pid}, State}
    after 1000 ->
            {reply, {address_not_found}, State}
    end;
handle_call(_Any, _From, State) ->
    {reply, "I don't understand...", State}.

handle_cast(_Msg, N) -> {noreply, N}.
handle_info(_Info, N) -> {noreply, N}.

terminate(_Reason, {City, _}) ->
    io:format("~p module for ~s stopping~n", [?MODULE, City]),
    db:close(City),
    ok.

code_change(_OldVsn, N, _Extra) ->
    {ok, N}.
