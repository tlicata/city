-module(db).

-export([open/1, close/1, get_addresses/2, get_streets/1, remove_addresses/2, set_addresses/3, set_streets/2]).

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

get_addresses(City, Street) ->
    case dets:lookup(City, Street) of
        [] -> missing;
        [{Street, Addresses}] -> Addresses
    end.

set_addresses(City, Street, Addresses) ->
    dets:insert(City, {Street, Addresses}).

remove_addresses(City, Street) ->
    dets:delete(City, Street).
