-module(street).

-export([fetch_addresses/2, fetch_streets/1, list_addresses/2, list_streets/1, parse_addresses/3, parse_streets/1, init/2, start/2]).

start(City, Street) ->
    spawn(street, init, [City, Street]).

init(City, Street) ->
    io:format("Street init: ~s (~p).~n", [Street, self()]),
    Addresses = list_addresses(City, Street),
    AddressPids = [address:start(City, Address) || Address <- Addresses],
    loop(City, Street, AddressPids).

loop(City, Street, AddressPids) ->
    receive
        {From, find, Addr} ->
            case string:find(string:to_lower(Addr), string:to_lower(Street)) of
                nomatch -> nil;
                _Match  ->
                    [Pid ! {From, find, Addr} || Pid <- AddressPids],
                    receive
                        {found, AddressPid} -> From ! {found, AddressPid}
                    after
                        500 -> nil
                    end
            end;
        Any ->
            io:format("~s received request it didn't understand: ~s~n", [Street, Any])
    end,
    loop(City, Street, AddressPids).

list_addresses(City, Street) ->
    case db:get_addresses(City, Street) of
        missing ->
            Addresses = parse_addresses(City, Street, fetch_addresses(City, Street)),
            db:set_addresses(City, Street, Addresses),
            Addresses;
        Addresses -> Addresses
    end.

list_streets(City) ->
    case db:get_streets(City) of
        missing ->
            Streets = parse_streets(fetch_streets(City)),
            db:set_streets(City, Streets),
            Streets;
        Streets -> Streets
    end.

parse_streets(Html) ->
    {match, Captured} = re:run(Html, "<option value=\"([^\"]+)", [global, {capture, all_but_first, list}]),
    [Street || [Street] <- lists:usort(Captured)].

fetch_streets(City) ->
    Url = oars:street_list_url(City),
    oars:from_url(Url).

parse_addresses(City, Street, Html) ->
    {match, Captured} = re:run(Html, "<tr>(.*)</tr>", [global, dotall, ungreedy, {capture, all_but_first, list}]),
    [_PageRow,_HeadingsRow|AddressRows] = Captured,
    lists:reverse(parse_addresses(City, Street, AddressRows, [])).

parse_addresses(City, Street, [PageRow|[]], List) ->
    {match, [CurrentPage,TotalPages]} = re:run(PageRow, "Page ([0-9]+) of ([0-9]+)", [{capture, all_but_first, list}]),
    if
        CurrentPage == TotalPages -> List;
        true -> lists:append(parse_addresses(City, Street, fetch_addresses(City, Street, list_to_integer(CurrentPage) + 1)), List)
    end;
parse_addresses(City, Street, [Row|Rest], List) ->
    parse_addresses(City, Street, Rest, [parse_address(Row)|List]).

parse_address(AddressRow) ->
    {match, [Addr]} = re:run(AddressRow, "<span[^>]*>([^<]*)</span>", [{capture, all_but_first, list}]),
    {match, [Url]}  = re:run(AddressRow, "window\.location\.href=\"([^\"]*)", [{capture, all_but_first, list}]),
    {match, Rest}   = re:run(AddressRow, "<td>([^<]*)</td>", [global, {capture, all_but_first, list}]),
    [[Sbl],[LotSize],[PropertyType],[BuildingStyle],[YearBuilt],[Sqft],[BedsBathsFire]] = Rest,
    {Addr, Url, Sbl, LotSize, PropertyType, BuildingStyle, YearBuilt, Sqft, BedsBathsFire}.

fetch_addresses(City, Street) ->
    Url = oars:street_url(City, Street),
    oars:from_url(Url).

fetch_addresses(City, Street, Page) ->
    Url = oars:street_url(City, Street, Page),
    oars:from_url(Url).
