-module(live).

-export([init/2, websocket_init/1, websocket_handle/2, websocket_info/2]).

init(Req0, State) ->
    Opts = #{idle_timeout => 60000, max_frame_size => 8000000},
    {cowboy_websocket, Req0, State, Opts}.

websocket_init(State) ->
    {reply, {text, <<"Hello!">>}, State}.

%% whenever a text, binary, ping or pong frame arrives from the client.
websocket_handle(Frame = {text, _}, State) ->
    {reply, Frame, State};
websocket_handle(_Frame, State) ->
    {ok, State}.

%% whenever an erlang message arrives...
websocket_info({log, Text}, State) ->
    {reply, {text, Text}, State};
websocket_info(_Info, State) ->
    {ok, State}.
