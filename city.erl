-module(city).

-export([populate_streets/0, send/1, start/1, simulate/1]).

start(City) ->
    spawn(fun() ->
                  {Pid, Ref} = spawn_monitor(city, simulate, [City]),
                  register(citysim, Pid),
                  receive
                      {'DOWN', Ref, process, Pid, Why} ->
                          io:format("Restarting simulation ~p which failed due to ~s reasons~n", [Pid, Why]),
                          start(City)
                  end
          end).

send(Message) ->
    send(whereis(citysim), Message).
send(Pid, Message) ->
    Pid ! {self(), Message},
    receive
        {Pid, Response} -> Response
    after 5000 ->
            "No response received :("
    end.

populate_streets() ->
    [street:start(Street) || Street <- street:list_streets(), string:slice(Street, 0, 2) == "AD"].

simulate(City) ->
    Start = erlang:time(),
    io:format("City simulation for ~s (~p) started at ~p~n", [City, self(), Start]),
    loop(City).

loop(City) ->
    receive
        {From, hey} ->
            From ! {self(), io:format("Hey, man, from ~s~n", [City])};
        {From, "what's up"} ->
            From ! {self(), "Not much. Chilling"};
        {From, "What's this river that I'm in?"} ->
            From ! {self(), "New Orleans is sinking, man, and I don't want to swim"};
        {From, "Goodnight"} ->
            From ! {self(), "Goodnight Goodnight"};
        {From, list_streets} ->
            From ! {self(), string:join(street:list_streets(City), "\n")};
        {From, _} ->
            From ! {self(), "I don't understand..."};
        Any ->
            io:format("Unknown message received: ~s~n", [Any])
    end,
    loop(City).
