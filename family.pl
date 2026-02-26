% =========================
% OnlineGDB Multi-Query Runner (SWI-Prolog)
% Paste queries in the INPUT box, one per line, ending with a period.
% Commands:
%   one.   -> print only first solution for subsequent queries
%   all.   -> print all solutions for subsequent queries (default)
%   halt.  -> stop program
% =========================

:- discontiguous male/1.
:- discontiguous female/1.

:- initialization(main).

% =========================
% FACTS
% =========================

% parent(Parent, Child).
parent(john, mary).
parent(susan, mary).

parent(john, mike).
parent(susan, mike).

parent(mary, lisa).
parent(david, lisa).

parent(mary, tom).
parent(david, tom).

parent(mike, anna).
parent(emma, anna).

% gender facts (grouped is cleaner, discontiguous just avoids warnings)
male(john).
male(mike).
male(david).
male(tom).

female(susan).
female(mary).
female(emma).
female(lisa).
female(anna).

% =========================
% RULES
% =========================

father(F, C) :- parent(F, C), male(F).
mother(M, C) :- parent(M, C), female(M).

child(C, P) :- parent(P, C).

grandparent(G, C) :-
    parent(G, P),
    parent(P, C).

sibling(X, Y) :-
    parent(P, X),
    parent(P, Y),
    X \= Y.

cousin(X, Y) :-
    parent(P1, X),
    parent(P2, Y),
    sibling(P1, P2),
    X \= Y.

% recursion
descendant(D, A) :-
    parent(A, D).
descendant(D, A) :-
    parent(A, X),
    descendant(D, X).

ancestor(A, D) :-
    descendant(D, A).

% =========================
% MULTI-QUERY RUNNER
% =========================

main :-
    writeln('--- Family Tree Loaded (OnlineGDB Runner) ---'),
    writeln('Enter queries in INPUT, one per line, each ending with a period.'),
    writeln('Commands: all. | one. | halt.'),
    writeln('Example: child(C, john).'),
    writeln('-------------------------------------------'),
    loop(all).

loop(Mode) :-
    read_term(Term, [variable_names(Vars)]),
    handle_term(Term, Vars, Mode).

handle_term(end_of_file, _Vars, _Mode) :-
    writeln('--- End of input ---'),
    halt(0).

handle_term(halt, _Vars, _Mode) :-
    writeln('--- Stopped ---'),
    halt(0).

handle_term(all, _Vars, _Mode) :-
    writeln('Mode set to ALL solutions.'),
    loop(all).

handle_term(one, _Vars, _Mode) :-
    writeln('Mode set to ONE solution.'),
    loop(one).

handle_term(Term, Vars, Mode) :-
    format('~n?- ~q.~n', [Term]),
    ( Mode = all ->
        run_all(Term, Vars)
    ; Mode = one ->
        run_one(Term, Vars)
    ),
    loop(Mode).

% Print all solutions
run_all(Term, Vars) :-
    (   call(Term),
        print_bindings(Vars),
        fail
    ;   writeln('false.')
    ).

% Print only first solution
run_one(Term, Vars) :-
    (   call(Term)
    ->  print_bindings(Vars)
    ;   writeln('false.')
    ).

% Print variable bindings like: C = mary, S = mike
print_bindings([]) :-
    writeln('true.').

print_bindings(Vars) :-
    Vars \= [],
    bindings_to_string(Vars, Str),
    ( Str = "" -> writeln('true.')
    ; format('~w~n', [Str])
    ).

bindings_to_string(Vars, Str) :-
    include(is_named_var, Vars, Named),
    pairs_to_text(Named, Str).

is_named_var(Name=_Value) :-
    Name \= '_'.

pairs_to_text([], "").
pairs_to_text([N=V], Str) :-
    format(string(Str), '~w = ~w.', [N, V]).
pairs_to_text([N=V|Rest], Str) :-
    pairs_to_text(Rest, Str2),
    format(string(Str), '~w = ~w, ~w', [N, V, Str2]).
