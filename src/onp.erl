%%%-------------------------------------------------------------------
%%% @author Emilia
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. mar 2019 14:35
%%%-------------------------------------------------------------------
-module(onp).
-author("Emilia").

%% API
-export([onp/1]).


onp(S) ->
  [Tokens] = solve(string:tokens(S, " "),[]),
  Tokens.

solve([],List) -> List;
solve(["+"| Tail], [A,B|T]) -> solve(Tail,[B+A | T]);
solve(["-"| Tail], [A,B|T]) -> solve(Tail,[B-A | T]);
solve(["*"| Tail], [A,B|T]) -> solve(Tail,[B*A | T]);
solve(["/"| Tail], [A,B|T]) -> solve(Tail,[B/A | T]);
solve(["pow"| Tail], [A,B|T]) -> solve(Tail,[math:pow(B,A) | T]);
solve(["sqrt"| Tail], [A|T]) -> solve(Tail,[math:sqrt(A) | T]);
solve(["sin"| Tail], [A|T]) -> solve(Tail,[math:sin(A) | T]);
solve(["cos"| Tail], [A|T]) -> solve(Tail,[math:cos(A) | T]);
solve(["tan"| Tail], [A|T]) -> solve(Tail,[math:tan(A) | T]);
solve(["ctan"| Tail], [A|T]) -> solve(Tail,[1/math:tan(A) | T]);
solve([X|Tail],List) -> solve(Tail, [listToRightFormat(X)| List]).

listToRightFormat(X)->
  case string:to_float(X) of
    {error, no_float} -> list_to_integer(X);
    {A, _} -> A
  end.




