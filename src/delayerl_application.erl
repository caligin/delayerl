-module(delayerl_application).

-behaviour(application).
-behaviour(supervisor).
-export([
    start/2,
    stop/1
    ]).
-export([
    init/1
    ]).

%% application cbs
start(_StartType, _StartArgs) ->
    register(delayerl_application, self()),
    Protocol = application:get_env(delayerl, protocol, https),
    Port = application:get_env(delayerl, port, 8090),
    Acceptors = application:get_env(delayerl, acceptors, 100),

    Dispatcher = cowboy_router:compile([
        {'_', [
            {'_', handler, []}
        ]}
    ]),
    {ok, _} = start_cowboy(Protocol, Port, Acceptors, Dispatcher),
    SupervisorRef = start_link_supervisor(),

    SupervisorRef.

stop(_State) ->
    ok.

%% supervisor cbs
init([]) ->
    {ok, {
        { one_for_one, 5, 100 },
        []
    }}.

%% private
start_cowboy(http, Port, Acceptors, Dispatcher) ->
    cowboy:start_http(cowboy_ref, Acceptors, [{port, Port}], [ {env, [{dispatch, Dispatcher}]} ]);

start_cowboy(https, Port, Acceptors, Dispatcher) ->
    {ok, CaCertFile} = application:get_env(cacertfile),
    {ok, CertFile} = application:get_env(certfile),
    {ok, KeyFile} = application:get_env(keyfile),
    cowboy:start_https(cowboy_ref, Acceptors, [{port, Port},{cacertfile, CaCertFile},{certfile, CertFile},{keyfile, KeyFile}], [ {env, [{dispatch, Dispatcher}]} ]);

start_cowboy(UnsupportedProtocol, _, _, _) ->
    throw({unsupported_protocol, UnsupportedProtocol}).

start_link_supervisor() ->
    supervisor:start_link({local, delayerl_supervisor}, ?MODULE, []).