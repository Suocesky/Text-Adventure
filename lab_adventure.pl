/* Lucid Dreams, by (Redacted). */

:- dynamic i_am_at/1, at/2, holding/1, counter/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)).

/* Starting location and counter*/
i_am_at(bedroom_start).
counter(50).

/* Room connections */
/* Start point to dream is one way, some areas are locked unless you have an item */
/* Make sure that items aren't dropped in areas that you cant get back to without that item */

/* Prevent starting the game without taking the first object. */
path(bedroom_start, d, bedroom_dream) :- at(sedative, in_hand).
path(bedroom_start, d, bedroom_dream) :-
        write('I should take that sedative now.'), nl,
        !, fail.

path(bedroom_dream, s, room_madness).
path(bedroom_dream, d, basement_dream) :- at(flashlight, in_hand).
path(bedroom_dream, d, basement_dream) :-
        write('It is too dark to see down there.'), nl,
        !, fail.
path(bedroom_dream, n, fire_escape).

path(room_madness, n, bedroom_dream).

/* First softlock protection */
path(basement_dream, u, bedroom_dream) :- at(flashlight, in_hand).
path(basement_dream, u, bedroom_dream) :- 
        write('If I leave the flashlight here, I won''t be able to return.'), nl,
        !, fail.

path(fire_escape, s, bedroom_dream).
path(fire_escape, d, outside_ground) :- at(rope, in_hand).
path(fire_escape, d, outside_ground) :-
        write('I can''t go down there because the ladder is broken.'), nl,
        !, fail.

/* Second softlock protection */
path(outside_ground, u, fire_escape) :- at(rope, in_hand).
path(outside_ground, u, fire_escape) :-
        write('Why would I leave the rope down here?'), nl,
        !, fail.


at(sedative, bedroom_start).
at(rope, basement_dream).
/* at(crystal, outside_ground). Hidden in dumpster */ 
at(flashlight, bedroom_dream).

/* These rules describe how to pick up an object. */

take(X) :-
        at(X, in_hand),
        write('You''re already holding it!'),
        !, nl.

take(X) :-
        i_am_at(Place),
        at(X, Place),
        retract(at(X, Place)),
        assert(at(X, in_hand)),
        write('OK.'),
        !, nl.

take(_) :-
        write('I don''t see it here.'),
        nl.


/* These rules describe how to put down an object. */

drop(X) :-
        at(X, in_hand),
        i_am_at(Place),
        retract(at(X, in_hand)),
        assert(at(X, Place)),
        write('OK.'),
        nl, !.

drop(_) :-
        write('You aren''t holding it!'),
        nl.


/* These rules define the direction letters as calls to go/1. */

n :- go(n).

s :- go(s).

e :- go(e).

w :- go(w).

u :- go(u).

d :- go(d).


/* This rule tells how to move in a given direction. */

go(Direction) :-
        i_am_at(Here),
        path(Here, Direction, There),
        retract(i_am_at(Here)),
        assert(i_am_at(There)),
        retract(counter(C)),
        Cn is C - 1,
        assert(counter(Cn)),
        !, look.

go(_) :- counter(X), X =< 0, nl,
        die, !, fail.

go(_) :-
        write('You can''t go that way.').


/* This rule tells how to look about you. */

look :-
        i_am_at(Place),
        describe(Place),
        nl,
        notice_objects_at(Place),
        nl.


/* These rules set up a loop to mention all the objects
   in your vicinity. */

notice_objects_at(Place) :-
        at(X, Place),
        write('There is a '), write(X), write(' here.'), nl,
        fail.

notice_objects_at(_).

/* search the dumpster, machine, and others */

search(dumpster) :-
    i_am_at(outside_ground),
    assert(at(crystal, outside_ground)),
    write('I found a small glowing crystal at the bottom!'), nl,
    !.

search(machine) :-
    i_am_at(room_madness),
    write('There is nothing of use in this machine.'), nl,
    !.

search(_) :-
    write('There is nothing there.'), nl,
    fail.

/* use machine, others*/

use(machine) :-
    at(crystal, in_hand),
    i_am_at(room_madness),
    write('You slot the crystal into the hole in the machine, and it seems to power up.'), nl,
    write('Just as the spectres come through the door behind you, there is a bright flash of light!'), nl,
    write('You wake up back in your own room, safe from the nightmare.'), nl,
    finish, !.

use(swingset) :-
    i_am_at(outside_ground),
    write('The swing creaks eerily, best to not make too much noise.'), nl,
    !.

use(_) :-
    write('I can''t use that.'), nl,
    !.

/* tells what you are holding */

i :- at(X, in_hand), write(X), nl, fail.

/* This rule tells how to die. */

die :-
        write('You have been caught by the spectres, and are cursed to wander the nightmare for eternity.'), nl,
        !, finish.


/* Under UNIX, the "halt." command quits Prolog but does not
   remove the output window. On a PC, however, the window
   disappears before the final output can be seen. Hence this
   routine requests the user to perform the final "halt." */

finish :-
        nl,
        write('The game is over. Please enter the "halt." command.'),
        nl.


/* This rule just writes out game instructions. */

instructions :-
        nl,
        write('Enter commands using standard Prolog syntax.'), nl,
        write('Available commands are:'), nl,
        write('start.             -- to start the game.'), nl,
        write('n. s. e. w. u. d.  -- to go in that direction.'), nl,
        write('take(Object).      -- to pick up an object.'), nl,
        write('drop(Object).      -- to put down an object.'), nl,
        write('search(Object).    -- to search an object.'), nl,
        write('use(Object).       -- to interact with an object.'), nl,
        write('look.              -- to look around you again.'), nl,
        write('i                  -- to check what you are holding.'), nl,
        write('instructions.      -- to see this message again.'), nl,
        write('halt.              -- to end the game and quit.'), nl,
        nl.


/* This rule prints out instructions and tells where you are. */

start :-
        write('You have trying to find a way to lucid dream for several months now,'), nl,
        write('and have finally found a way to do so. All you need now is to take the'), nl,
        write('special sedatives on your table.'), nl,
        instructions,
        look.


/* These rules describe the various rooms.  Depending on
   circumstances, a room may have more than one description. */

describe(bedroom_start) :- 
    write('You are in your own bedroom.'), nl.

describe(bedroom_dream):-
    at(crystal, in_hand),
    write('You run back into the bedroom you started this nightmare in'), nl,
    write('as you hear the spectres come up to the fire escape behind you. '), nl.

describe(bedroom_dream) :- 
    write('This looks like your bedroom, but something is different.'), nl,
    write('Colors are faded, and you get the feeling like you are being watched.'), nl,
    write('There is a door to the south which you can hear a faint humming from.'), nl,
    write('Through a door to the north, you can smell and hear the sea. In the floor of the room'), nl,
    write('is a hatch that seems to lead downwards.'), nl.

/* Do I want to move to a bedroom_end and enable a 2nd description where the game ends? */
describe(room_madness) :-
    at(crystal, in_hand),
    write('As you run into this room, the spectres are right behind you, chilling you.'), nl,
    write('You hope this crystal is the power source the note mentioned'), nl.

describe(room_madness) :-
    write('There seem to have been people here before. There are multiple different styles of'), nl,
    write('writing on the walls, all talking about dreams. In the corner is a machine that hums softly'), nl,
    write('with a note which reads "I just need a power source, and then I''m free."'), nl.

describe(basement_dream) :-
    at(crystal, in_hand),
    write('You entered the basement with the horde of spectres behind you, and instantly regretted it.'), nl,
    write('There is no way out other than the hatch you shut behind you. You are trapped'), nl,
    write('with no way out, doomed to die in this nightmare.'), nl,
    die.

describe(basement_dream) :-
    write('You don''t recall having a basement, considering you live in a third floor apartment.'), nl,
    write('There is a mostly empty rack on the wall, only a coil of rope is left.'), nl.

describe(fire_escape) :-
    at(crystal, in_hand),
    write('The spectres come out of nowhere and swarm at the bottom of the building, right at the spot '), nl,
    write('you had just vacated. They seem agitated, and are after you. You better get out of here quickly.'), nl.

describe(fire_escape) :-
    write('From here, you can see the ocean, but the world seems different. Colors are faded,'), nl,
    write('and an oppressive gloom hangs in the air. Below you is a small fenced in area.'), nl,
    write('the fire escape leading downwards seems to be broken though, and its too high to drop down.'), nl.

describe(outside_ground) :-
    write('There is not much down here other than a rusted swingset that creaks in the breeze,'), nl,
    write('and a dumpster. You can get back up to the fire escape the same way you came down.'), nl.