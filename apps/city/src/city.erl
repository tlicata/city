-module(city).

-export([populate_streets/1, send/1, start/1, simulate/1]).

start(City) ->
    spawn(fun() ->
                  oars:run_services(),
                  db:open(City),
                  {Pid, Ref} = spawn_monitor(city, simulate, [City]),
                  register(citysim, Pid),
                  receive
                      {'DOWN', Ref, process, Pid, Why} ->
                          io:format("Exiting simulation ~p which failed due to ~s reasons~n", [Pid, Why]),
                          db:close(City)
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

populate_streets(City) ->
    [street:start(City, Street) || Street <- street:list_streets(City)].

simulate(City) ->
    Start = erlang:time(),
    io:format("City simulation for ~s (~p) started at ~p~n", [City, self(), Start]),
    loop(City).

loop(City) ->
    receive
        {From, hey} ->
            From ! {self(), io:format("Hey, from ~s~n", [City])};
        {From, list_streets} ->
            From ! {self(), string:join(street:list_streets(City), "\n")};
        {From, populate_streets} ->
            populate_streets(City),
            From ! {self(), streets_populated};
        {From, _} ->
            From ! {self(), "I don't understand..."};
        Any ->
            io:format("Unknown message received: ~s~n", [Any])
    end,
    loop(City).
