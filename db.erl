-module(db).

-export([open/0, close/0, get_streets/1, set_streets/2]).

open() ->
    case dets:open_file(?MODULE, [{file, "database.dets"}]) of
        {ok, ?MODULE} ->
            io:format("opened dets file~n"),
            true;
        {error, Reason} ->
            io:format("error opening dets file: ~p~n", [Reason]),
            exit({eDetsOpen, "database.dets", Reason})
        end.

close() ->
    io:format("closing dets file~n"),
    dets:close(?MODULE).

get_streets(City) ->
    case dets:lookup(?MODULE, City) of
        [] -> missing;
        [{City, Streets}] -> Streets
    end.

set_streets(City, Streets) ->
    dets:insert(?MODULE, {City, Streets}).
