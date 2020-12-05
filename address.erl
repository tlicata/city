-module(address).

-export([start/2, init/2, url/2]).

start(City, Address) ->
    spawn(address, init, [City, Address]).

init(City, Address) ->
    {Addr, _Url, Sbl, _LotSize, _PropType, _BuildingStyle, YearBuilt, _Sqft, _BedsBathsFire} = Address,
    io:format("  My address is '~s', my Sbl is ~s, and I was built in ~p. (~p)~n", [Addr, Sbl, parse_year(YearBuilt), self()]).

url(City, Address) ->
    oars:address_url(City, get_property_url(Address)).

get_property_url(Address) -> element(2, Address).

parse_year([]) -> 0;
parse_year(Year) -> list_to_integer(Year).
