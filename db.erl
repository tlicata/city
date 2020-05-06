-module(db).

-export([open/1, close/1, get_streets/1, set_streets/2]).

open(City) ->
    Filename = io_lib:format("~s.dets", [City]),
    case dets:open_file(City, [{file, Filename}]) of
        {ok, City} ->
            io:format("opened ~s file~n", [Filename]),
            true;
        {error, Reason} ->
            io:format("error opening ~s file: ~p~n", [Filename, Reason]),
            exit({eDetsOpen, Filename, Reason})
        end.

close(City) ->
    io:format("closing dets file for ~s~n", [City]),
    dets:close(City).

get_streets(City) ->
    case dets:lookup(City, streets) of
        [] -> missing;
        [{streets, Streets}] -> Streets
    end.

set_streets(City, Streets) ->
    dets:insert(City, {streets, Streets}).
