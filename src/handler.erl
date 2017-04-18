-module(handler).
-export([
    init/3,
    handle/2,
    terminate/3
    ]).

init(_Transport, Req, []) ->
    {ok, Req, []}.

handle(Req, State) ->    
    receive
    after 2000 ->
        {ok, Req2} = cowboy_req:reply(504, Req),
        {ok, Req2, State}
    end.

terminate(_Reason, _Req, _State) ->
    ok.
