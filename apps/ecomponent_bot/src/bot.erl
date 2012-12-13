-module(bot).

-behaviour(gen_server).

-include_lib("exmpp/include/exmpp.hrl").
-include_lib("ecomponent/include/ecomponent.hrl").

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3, process_message/1]).

-define(SERVER, {local, ?MODULE}).

-record(state, {}).

start_link() ->
    gen_server:start_link(?SERVER, ?MODULE, [], []).

init([]) ->
    {ok, #state{}}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(#message{}=Message, State) ->
    lager:debug("Message : ~p~n", [Message]),
    spawn(?MODULE, process_message, [Message]),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

process_message(#message{xmlel=Xmlel}) ->
    C = exmpp_message:chat(exmpp_message:get_body(Xmlel)),
    Ch = exmpp_message:set_type(C, exmpp_message:get_type(Xmlel)),
    To = exmpp_stanza:get_sender(Xmlel), 
    From = exmpp_stanza:get_recipient(Xmlel), 
    Chat = exmpp_stanza:set_jids(Ch, From, To),
    ecomponent:send_message(Chat).