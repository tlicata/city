-module(address).

-export([start/1, init/1]).

start(Address) ->
    spawn(address, init, [Address]).

init(Address) ->
    {Addr, _Url, Sbl, _LotSize, _PropType, _BuildingStyle, YearBuilt, _Sqft, _BedsBathsFire} = Address,
    io:format("  My address is '~s', my Sbl is ~s, and I was built in ~p. (~p)~n", [Addr, Sbl, parse_year(YearBuilt), self()]).

parse_year([]) -> 0;
parse_year(Year) -> list_to_integer(Year).
