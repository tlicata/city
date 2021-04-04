-module(address).

-export([start/2, init/2, url/2]).

start(City, Address) ->
    spawn(address, init, [City, Address]).

init(City, Address) ->
    io:format("Address init: ~s Looping: (~p)~n", [info(City, Address), self()]),
    loop(City, Address).

loop(City, Address) ->
    receive
        url ->
            io:format("I am an Address. My URL is ~s~n", [url(City, Address)]);
        info ->
            io:format("I am an Address: ~s~n", [info(City, Address)]);
        {From, find, Addr} ->
            MyAddr = addr(City, Address),
            case string:find(string:to_lower(MyAddr), string:to_lower(Addr)) of
                nomatch -> nil;
                _Match  -> From ! {found, self()}
            end;
        _Any ->
            io:format("I am an Address. I don't understand that message~n")
    end,
    loop(City, Address).

url(City, Address) ->
    oars:address_url(City, get_property_url(Address)).

addr(_City, Address) ->
    {Addr, _Url, _Sbl, _LotSize, _PropType, _BuildingStyle, _YearBuilt, _Sqft, _BedsBathsFire} = Address,
    Addr.

info(_City, Address) ->
    {Addr, _Url, Sbl, LotSize, PropType, BuildingStyle, YearBuilt, Sqft, BedsBathsFire} = Address,
    io_lib:format("~s - ~s - ~p - ~s - ~s - ~s ~s.", [Addr, Sbl, parse_year(YearBuilt), BedsBathsFire, Sqft, LotSize, BuildingStyle]).

get_property_url(Address) -> element(2, Address).

parse_year([]) -> 0;
parse_year(Year) -> list_to_integer(Year).
