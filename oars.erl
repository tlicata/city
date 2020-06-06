-module(oars).

-export([street_list_url/1, street_url/2, street_url/3, fetcher/1, fetcher_supervisor/0, from_url/1, run_services/0, encode_street/1]).

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

from_url(Url) ->
    Pid = whereis(oars),
    Pid ! {self(), request, Url},
    receive
        {Pid, ok, Response} ->
            {{_Version, 200, _ReasonPhrase}, _Headers, Body} = Response,
            Body
    end.

encode_street(Street) ->
    re:replace(Street, " ", "+", [global, {return, list}]).

fetcher_supervisor() ->
    {Pid, Ref} = spawn_monitor(oars, fetcher, [self()]),
    receive
        {From, request, Url} ->
            Pid ! {self(), request, Url},
            receive
                {Pid, ok, Response} ->
                    From ! {self(), ok, Response};
                {'DOWN', Ref, process, Pid, Why} ->
                    io:format("Fetching process died due to ~p.~nRestarting.~n", [Why])
            end
    end,
    fetcher_supervisor().

fetcher(SuperPid) ->
    receive
        {SuperPid, request, Url} ->
            {ok, Response} = ?http_request(Url),
            io:format("ONLINE MODE! Request made to: ~s~n", [Url]),
            SuperPid ! {self(), ok, Response}
    end.

run_services() ->
    register(oars, spawn(oars, fetcher_supervisor, [])),
    inets:start(),
    ssl:start().
