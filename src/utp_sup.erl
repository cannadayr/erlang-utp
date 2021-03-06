%%%-------------------------------------------------------------------
%%% @author Jesper Louis andersen <jesper.louis.andersen@gmail.com>
%%% @copyright (C) 2011, Jesper Louis andersen
%%% @doc Supervisor for the gen_utp framework
%%% @end
-module(utp_sup).

-behaviour(supervisor).

%% API
-export([start_link/1, start_link/2]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @spec start_link() -> {ok, Pid} | ignore | {error, Error}
%% @end
%%--------------------------------------------------------------------
start_link(Port, Opts) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, [Port, Opts]).

%% @equiv start_link(Port, [])
start_link(Port) ->
    start_link(Port, []).

%%%===================================================================

%% @private
init([Port, Opts]) ->
    RestartStrategy = one_for_all,
    MaxRestarts = 10,
    MaxSecondsBetweenRestarts = 3600,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    CountTracer = {utp_trace, {utp_trace, start_link, [Opts]},
                   permanent, 2000, worker, [utp_trace]},
    Tracer = {gen_utp_trace, {gen_utp_trace, start_link, []},
              permanent, 2000, worker, [gen_utp_trace]},
    GenUTP = {gen_utp, {gen_utp, start_link, [Port, Opts]},
	      permanent, 15000, worker, [gen_utp]},
    GenUTPDecoder = {gen_utp_decoder, {gen_utp_decoder, start_link, []},
	      permanent, 15000, worker, [gen_utp_decoder]},
    WorkerPool = {gen_utp_worker_pool, {gen_utp_worker_pool, start_link, []},
		  transient, infinity, supervisor, [gen_utp_worker_pool]},
    io:format("Starting up~n"),
    {ok, {SupFlags, [CountTracer, Tracer, WorkerPool, GenUTPDecoder, GenUTP]}}.











