-module(info).

-export([init/2]).

init(Req0, Opts) ->
    Headers = #{<<"content-type">> => <<"text/html">>},
    Body = <<"<h1>Hello, Info!</h1>">>,
    Req = cowboy_req:reply(200, Headers, Body, Req0),
    {ok, Req, Opts}.
