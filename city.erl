-module(city).

-export([send/1, start/0, simulate/0]).

start() ->
    spawn(fun() ->
                  {Pid, Ref} = spawn_monitor(city, simulate, []),
                  register(citysim, Pid),
                  receive
                      {'DOWN', Ref, process, Pid, Why} ->
                          io:format("Restarting simulation ~p which failed due to ~s reasons~n", [Pid, Why]),
                          start()
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

simulate() ->
    Start = erlang:time(),
    io:format("City simulation ~p started at ~p~n", [self(), Start]),
    loop().

loop() ->
    receive
        {From, hey} ->
            From ! {self(), "Hey, man"};
        {From, "what's up"} ->
            From ! {self(), "Not much. Chilling"};
        {From, "What's this river that I'm in?"} ->
            From ! {self(), "New Orleans is sinking, man, and I don't want to swim"};
        {From, "Goodnight"} ->
            From ! {self(), "Goodnight Goodnight"};
        {From, _} ->
            From ! {self(), "I don't understand..."};
        Any ->
            io:format("Unknown message received: ~s~n", [Any])
    end,
    loop().
