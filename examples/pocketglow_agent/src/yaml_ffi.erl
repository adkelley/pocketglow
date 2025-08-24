-module(yaml_ffi).
-export([yamerl_constr_string/1]).

yamerl_constr_string(Yaml) ->
  application:start(yamerl),
  yamerl_constr:string(Yaml).

