-module(street).

-export([get_street_data/1, list_streets/0, run_services/0, init/1, start/1]).

start(Street) ->
    spawn(street, init, [Street]).

init(Street) ->
    io:format("Hello, my name is ~s.~n", [Street]),
    io:format(" -> Calling API...~n"),
    {ok, Response} = get_street_data(Street),
    io:format(" -> Response is ~s~n", [Response]).

list_streets() ->
    {ok, Binary} = file:read_file("streets.txt"),
    string:split(binary:bin_to_list(Binary), "\n", all).

get_street_data(Street) ->
    EncodedStreet = re:replace(Street, " ", "+", [global, {return, list}]),
    Params = io_lib:format("swis=290900&debug=bdebug&streetlookup=yes&address2=~s", [EncodedStreet]),
    Url = io_lib:format("https://cityoflockport.oarsystem.com/assessment/pcllist.asp?~s", [Params]),
    httpc:request(Url).

%% Might need to run:
run_services() ->
    inets:start(),
    ssl:start().
