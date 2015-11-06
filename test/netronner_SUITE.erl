-module(delayerl_SUITE).
-compile(export_all).

all() ->
    [can_start].

groups() ->
    [].

init_per_test(_, Config) ->
    Config.
end_per_test(_, Config) ->
    Config.

init_per_group(_, Config) ->
    ok = start_test_delayerl(),
    Config.
end_per_group(_, Config) ->
    ok = application:stop(delayerl),
    Config.

%% helpers

start_test_delayerl() ->
    ok = application:set_env(delayerl, protocol, http),
    {ok, _Apps} = application:ensure_all_started(delayerl),
    ok.

get(Path) ->
    {ok, Response} = httpc:request(get,
                  {"http://localhost:8080" ++ Path, []},
                  [{timeout, 500},
                   {autoredirect, false}],
                  []),
    Response.

%% tests

can_start(_Config) ->
    ok = start_test_delayerl().
