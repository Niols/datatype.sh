datatype.sh
=============

Datatypes in Shell; because even the best language in the world lacks features sometimes.

Getting Started
------------------

One can define new datatypes and their constructors using the following syntax:

```sh
datatype list
constructor nil
constructor cons . list
```

- The first line defines a new datatype `list`.
- The second line adds one constructor to this datatype, `nil` that
  takes no arguments.
- The third line adds an other constructor to this datatype, `cons`
  that takes two arguments. The first one can be of any type (`.`) and
  the second must be of type `list`.

This datatype definition defines two new functions, `nil` and `cons`,
that one can use to create elements of type `list`. For instance:

```sh
l=$(cons 1 $(cons 2 $(cons 3 $(cons 4 $(nil)))))
```

After that, all one needs is some pattern matching. Here is an example
function, `length`, that returns the length of a list recursively:

```sh
length () {
  case $(match $1) in
    nil)
	  echo 0
	;;
	cons) destruct $1 cons _ l
	  echo $((1 + $(length $l)))
	;;
  esac
}
```

The `match` function takes an element and return the constructor
name. It is mainly useful in the idiom `case $(match ...) in`. The
`destruct` function takes an element, a constructor name and as many
variable names (or `_`) as required by the constructor and fills these
variables with the contents of the constructor.

In this piece of code, since we know from the matching that `$1` is a
`cons`, we can destruct it, ignore the first argument with `_` and put
the second argument in `$l`, that we can then use to compute the
length.

Note that, unless you use the `local` keyword, all variables are
global. In particular, that means that here, using `length` would
modify the variable `l`.

Benchmarks
------------

Ha. Ha. It is slow, very slow.
