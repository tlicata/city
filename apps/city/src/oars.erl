-module(oars).

-behavior(gen_server).

-export([base_url/1, address_url/2, street_list_url/1, street_url/2, street_url/3, from_url/1, encode_street/1]).

-export([start_link/0]).
%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-ifdef(online_flag).
-define(http_request(Url), httpc:request(Url)).
-else.
-define(http_request(Url), io:format("Offline mode. Not making request to: ~s~n", [Url])).
-endif.

base_url(City) ->
    io_lib:format("https://~s.oarsystem.com", [City]).

street_list_url(City) ->
    io_lib:format("~s/assessment/main.asp?swis=290900", [base_url(City)]).

street_url(City, Street) ->
    Params = io_lib:format("swis=290900&debug=bdebug&streetlookup=yes&address2=~s", [encode_street(Street)]),
    io_lib:format("~s/assessment/pcllist.asp?~s", [base_url(City), Params]).
street_url(City, Street, Page) ->
    Params = io_lib:format("swis=290900&address2=~s&page=~p", [encode_street(Street), Page]),
    io_lib:format("~s/assessment/pcllist.asp?~s", [base_url(City), Params]).
address_url(City, PropertyUrl) ->
    base_url(City) ++ "/assessment/" ++ PropertyUrl.

from_url(Url) ->
    Response = gen_server:call(?MODULE, {request, Url}),
    {{_Version, 200, _ReasonPhrase}, _Headers, Body} = Response,
    Body.

encode_street(Street) ->
    re:replace(Street, " ", "+", [global, {return, list}]).

%% gen_server behavior

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init([]) ->
    process_flag(trap_exit, true),
    io:format("~p starting~n", [?MODULE]),
    {ok, {}}.

handle_call({request, Url}, _From, State) ->
    {ok, Response} = ?http_request(Url),
    io:format("ONLINE MODE! Request made to: ~s~n", [Url]),
    {reply, Response, State}.

handle_cast(_Msg, State) -> {noreply, State}.
handle_info(_Info, State) -> {noreply, State}.

terminate(_Reason, _State) ->
    io:format("~p stopping~n", [?MODULE]),
    ok.

code_change(_OldVsn, State, _Extra) ->
    io:format("~p code_change~n", [?MODULE]),
    {ok, State}.
