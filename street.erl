-module(street).

-export([fetch_streets/1, fetch_street/2, parse_streets/1, list_streets/1, init/2, start/2]).

start(City, Street) ->
    spawn(street, init, [City, Street]).

init(City, Street) ->
    io:format("Hello, my name is ~s, ~s.~n", [Street, City]),
    io:format(" -> Calling API...~n"),
    StreetData = fetch_street(City, Street),
    io:format(" -> StreetData is ~s~n", [StreetData]).

list_streets(City) ->
    case db:get_streets(City) of
        missing ->
            Streets = parse_streets(fetch_streets(City)),
            db:set_streets(City, Streets),
            Streets;
        Streets ->
            Streets
    end.

parse_streets(Html) ->
    {match, Captured} = re:run(Html, "<option value=\"([^\"]+)", [global, {capture, all_but_first, list}]),
    [Street || [Street] <- lists:usort(Captured)].

fetch_streets(City) ->
    Url = oars:street_list_url(City),
    oars:from_url(Url).

fetch_street(City, Street) ->
    Url = oars:street_url(City, Street),
    oars:from_url(Url).

