-module(parser).

-export([clean/1, no_spaces/1]).

no_breaks(Html) -> re:replace(Html, "<br />", "", [global, {return, list}]).
no_newlines(Html) -> re:replace(Html, "\r\n", "", [global, {return, list}]).
no_spaces(Html) -> re:replace(Html, " ", "", [global, {return, list}]).

clean(Html) -> no_breaks(no_newlines(Html)).
