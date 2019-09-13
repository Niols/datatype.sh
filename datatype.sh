#!/bin/sh

dtsh_fail () {
    printf >&2 'datatype.sh: '
    printf >&2 "$@"
    printf >&2 '\n'
    exit 77
}

## We first need to initialise `datatype.sh`. This goes by creating a
## temporary directory in which all the definitions will be
## written. We also need to initialise a counter that will allow us to
## have unique ids for all items here.

readonly DTSH_DIR=/tmp/datatype.sh-$RANDOM
if ! mkdir "$DTSH_DIR"; then
    dtsh_fail 'initialisation failed'
fi
mkdir "$DTSH_DIR"/.datatype
mkdir "$DTSH_DIR"/.constructor

echo 0 > "$DTSH_DIR"/.next_uid
dtsh_next_uid () {
    _dtsh_next_uid=$(cat "$DTSH_DIR"/.next_uid)
    eval "$1=$_dtsh_next_uid"
    echo $((_dtsh_next_uid + 1)) >| "$DTSH_DIR"/.next_uid
}

dtsh_datatype () {
    ## The `datatype` function defines a new datatype by registering
    ## it in the `.datatype` folder. It also defines that datatype as
    ## the current one, so that following `constructor` definitions
    ## know to which type they are linked.

    if [ $# -ne 1 ]; then
	dtsh_fail '`datatype` expects exactly one argument'
    fi
    mkdir "$DTSH_DIR"/.datatype/"$1"
    echo "$1" > "$DTSH_DIR"/.datatype/"$1"/.name
    mkdir "$DTSH_DIR"/.datatype/"$1"/.constructor
    ln -sf "$DTSH_DIR"/.datatype/"$1" "$DTSH_DIR"/.datatype/.current
}

dtsh_constructor () {
    ## The `constructor` function defines a new constructor in the
    ## current datatype, by registering it both in the `.constructor`
    ## folder but also in the type's `.constructor`'s. We also need to
    ## define the constructor function.

    if [ $# -eq 0 ]; then
	dtsh_fail '`constructor` expects at least one argument'
    fi

    _dtsh_constr=$1; shift

    mkdir "$DTSH_DIR"/.constructor/"$_dtsh_constr"
    ln -sf "$(cd "$DTSH_DIR"/.datatype/.current && pwd)" "$DTSH_DIR"/.constructor/"$_dtsh_constr"/.datatype
    ln -sf "$DTSH_DIR"/.constructor/"$_dtsh_constr" "$DTSH_DIR"/.datatype/.current/.constructor/"$_dtsh_constr"

    ## FIXME: for now, we only remember the number of arguments of the
    ## constructor. Later, we want to add some typing information
    ## here.
    echo $# > "$DTSH_DIR"/.constructor/"$_dtsh_constr"/.nbargs

    eval "$_dtsh_constr () { dtsh_construct $_dtsh_constr \"\$@\"; }"
}

dtsh_construct () {
    ## The `construct` function constructs a value of a constructor
    ## from its arguments by registering everything in the DTSH
    ## directory. The result is a pointer (of the form
    ## `type:constr:uid`).

    _dtsh_constr=$1; shift

    _dtsh_nbargs=$(cat "$DTSH_DIR"/.constructor/"$_dtsh_constr"/.nbargs)
    if [ $# -ne $_dtsh_nbargs ]; then
	dtsh_fail '`construct %s` has %d arguments (%d expected)' "$_dtsh_constr" $# "$_dtsh_nbargs"
    fi

    dtsh_next_uid _dtsh_uid
    _dtsh_type=$(cat "$DTSH_DIR"/.constructor/"$_dtsh_constr"/.datatype/.name)
    _dtsh_uid=$_dtsh_type:$_dtsh_constr:$_dtsh_uid

    mkdir "$DTSH_DIR"/"$_dtsh_uid"

    _dtsh_i=0
    while [ $# -gt 0 ]; do
	echo "$1" > "$DTSH_DIR"/"$_dtsh_uid"/$_dtsh_i
	shift
	_dtsh_i=$((_dtsh_i + 1))
    done

    echo "$_dtsh_uid"
}

dtsh_match () {
    echo "$1" | cut -d : -f 2
}

dtsh_destruct () {
    _dtsh_uid=$1; shift

    ## FIXME: use second argument to check that it is indeed the right
    ## constructor.
    _dtsh_constr=$(echo "$_dtsh_uid" | cut -d : -f 2)
    shift

    _dtsh_nbargs=$(cat "$DTSH_DIR"/.constructor/"$_dtsh_constr"/.nbargs)
    if [ $# != $_dtsh_nbargs ]; then
	dtsh_fail '`destruct %s` has %d arguments (%d expected)' "$_dtsh_constr" $# "$_dtsh_nbargs"
    fi

    _dtsh_i=0
    while [ $# -gt 0 ]; do
	_dtsh_val=$(cat "$DTSH_DIR"/"$_dtsh_uid"/$_dtsh_i | sed "s|'|'\\\\''|")
	eval "$1='$_dtsh_val'"
	shift
	_dtsh_i=$((_dtsh_i + 1))
    done
}

## Export some of these functions.

datatype () { dtsh_datatype "$@"; }
constructor () { dtsh_constructor "$@"; }
match () { dtsh_match "$@"; }
destruct () { dtsh_destruct "$@"; }
