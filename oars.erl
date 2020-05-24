-module(oars).

-export([street_list_url/1, street_url/2, from_url/1, run_services/0]).

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

from_url(Url) ->
    {ok, Response} = ?http_request(Url),
    io:format("ONLINE MODE! Request made to: ~s~n", [Url]),
    {{_Version, 200, _ReasonPhrase}, _Headers, Body} = Response,
    Body.

encode_street(Street) ->
    re:replace(Street, " ", "+", [global, {return, list}]).

run_services() ->
    inets:start(),
    ssl:start().
