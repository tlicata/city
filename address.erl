-module(address).

-export([start/1, init/1]).

start(Address) ->
    spawn(address, init, [Address]).

init(Address) ->
    {Addr, _Url, Sbl, _LotSize, _PropType, _BuildingStyle, YearBuilt, _Sqft, _BedsBathsFire} = Address,
    io:format("  My address is '~s', my Sbl is ~s, and I was built in ~p. (~p)~n", [Addr, Sbl, YearBuilt, self()]).
