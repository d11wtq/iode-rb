# Iode RB

An experimental lisp-family language hosted on Ruby.

## Installation

```
gem install iode
```

## Usage 

This project is really a playground for language exploration while I build a
real language on the LLVM. Nothing here is intended to be fast. I'm just going
for expressiveness. If you try iode, please understand it will be slow and
somewhat lacking in features.

### Command Line

Program source files end in ".io". You can run them like so:

```
iode-rb path/to/file.io
```

Or you can send the source code to STDIN:

```
iode-rb < path/to/file.io
```

The basic hello world looks like so.

``` lisp
;; this is a comment
(puts "Hello World!")
```

Some built-in data types (e.g. fractions) are enriched with literals in iode.

``` lisp
(+ 1/2 2/3) ; 7/6
```

Functions are defined in terms of `func`.

``` lisp
((func (x y) (* x y)) 6 3) ; 18
```

As you'd expect, functions are first-class objects in Iode.

Of course, functions can be defined recursively too.

``` lisp
(def loop
 (func (n)
   (if (= n 0)
     'done
     (progn
       (puts n)
       (loop (- n 1))))))

(loop 20)
```

Similarly, closures can be returned from functions.

``` lisp
(def dec
 (func (n)
   (- n 1)))

(def expt
 (func (n x)
   (if (= x 0)
      1
      (* n (expt n (dec x))))))

(def make-expt-fn
 (func (x)
   (func (n) (expt n x))))

(def square
 (make-expt-fn 2))

(def cube
 (make-expt-fn 3))

(puts (square 4))
(puts (cube 4))
```

Or something that updates some internal state.

``` lisp
(def make-counter
 (func (n)
   (func () (set! n (inc n)))))

(def counter
 (make-counter 0))

(puts (counter)) ; 1
(puts (counter)) ; 2
(puts (counter)) ; 3
(puts (counter)) ; 4
```

#### Data types

Iode has a rich set of supported data types.

Integers

``` lisp
(def x 42)
```

Floats

``` lisp
(def x 42.5)
```

Fractions

``` lisp
(def x 1/2)
```

Symbols

``` lisp
(def x 'foo)
```

Strings

``` lisp
(def x "this is a string")
```

Lists

``` lisp
(def x (list 1 2 3))
(def y '(1 2 3)) ; same thing

(head x) ; 1
(tail x) ; '(2 3)
(empty? (tail (tail (tail x)))) ; true
(nth x 1) ; 2
(x 1) ; 2 (same thing)
```

Maps (Hashes)

``` lisp
(def x {'a 42, 'b 7})

(get x 'b) ; 7
(x 'b) ; 7 (same thing)
(assoc x 'b 9) ; {'a 42, 'b 9}
(dissoc x 'b) ; {'a 42}
```

Regular expressions

``` lisp
(def re /[a-z]*_class/)
```

#### Modules

> **Note:** This is a big work in progress and is feature incomplete.

Source files (a.k.a. modules) may be loaded from a path using `require`.

``` lisp
;; foo.io

(puts "Foo loaded")

(def test
  (func () "Can't be reached"))
```

``` lisp
;; bar.io

(require "foo.io") ; Foo loaded
(test) ; Error, no such function!
```

By design, definitions are kept local to individual modules. This means when
you require another module, you don't gain its definitions, nor can it see your
definitions.

In order to share definitions between modules, iode provides the symmetric
functions `export` and `import`.

``` lisp
;; foo.io

(def one
  (func () "Called one"))

(def two
  (func () "Called two"))

(export '(one two))
```

Any module needing access to `one` and `two` may not `import` the foo module.

``` lisp
;; bar.io

(import "foo.io")

(one) ; Called one
(two) ; Called two
```

This is definitely going to change, since the current implementation is only a
step towards the end goal of loading modules by naming convention, and
namespacing within modules. Since `one` and `two` were not explicitly referred
to the current scope, the above example would be better written as:


``` lisp
;; bar.io

(import 'foo)

(foo/one) ; Called one
(foo/two) ; Called two
```

#### Macros

Yes, iode has macros. In fact, very powerful macros. You can think of macros in
the same way you think about funcs. They are 100% first-class to iode and
have values that can be assigned to variables, passed into functions etc. Like
funcs, they also provide a lexical closure over their environment. The
difference between a macro and a func is that a macro receives unevaluated
*code* as input and produces *code* as output.

The syntax for returning code is a little cumbersome at this point, since I
haven't yet added quasiquoting to provide that magical "templating" that lisps
offer. Lots of `list` and `quote` for now. Quasiquoting is coming, however.

Since iode doesn't yet have a `let` form, let's make our own with a macro.

``` lisp
(def second
 (func (v) (head (tail v))))

(def let
 (macro (bindings body)
   (list
    'apply
    (list 'func
          (map head bindings)
          body)
     (map second bindings))))

(let ((x 7)
      (y 8))
  (puts (* x y)))
```

Note that the body of the macro in this version must be a single s-expression,
since variadic arguments are not yet implemented in the language. You may use
a `progn`, however.

``` lisp
(let ((x 7)
      (y 8))
  (progn
    (puts (str "x = " x))
    (puts (str "y = " y))
    (puts (str "x * y = " (* x y)))))
```

Macros as values are a powerful feature of iode.

### In Ruby Code

Using Iode from inside Ruby code can be interesting, as it will interoperate
with Ruby.

``` ruby
require "iode"

result = Iode.run <<-PROG
(if ((func (x) x) false)
  "x = true"
  "x = false")
PROG

puts result
```

This returns the string "x = false" to Ruby. Hopefully you can see what the
code does.

Here's another example showing how you can pass values from Ruby into Iode.

``` ruby
require "iode"

prog = Iode.run <<-PROG
(func (x)
  (if x
    (puts 42)
    (puts 7)))
PROG

prog.call(false) #=> 7
prog.call(true)  #=> 42
```

This works because internally, iode funcs are represented as Procs.

Incidentally, that means you can even pass higher-order functions from Ruby
to iode.

``` ruby
require "iode"

prog = Iode.run <<-PROG
(func (f)
  (f 42))
PROG

prog.call(->(x){ x * 2 }) #=> 84
prog.call(->(x){ x + 4 }) #=> 46
```

### Extending iode

If you want to add a native Ruby function to be applied like an iode function,
put it in a Module and register it into `Iode::Core`:

``` ruby
require "iode"

module MyFunctions
  def example(a, b)
    a + b
  end
end

Iode::Core.register MyFunctions

Iode.run('(example 7 5)') #=> 12
```

Of course, you can always use the built-in module support to write iode source
code to be imported too.

## Development

If you feel inclined to poke around in the source, start with the
`Interpreter#eval` method. You'll see it's a simple recursive algorithm that
operates on native Ruby data. The native Ruby data is equivalent to native iode
data. This is how all lisps work.

The `Reader` class converts source code to this data format.

Native ruby functions (things that can't be written in iode itself) are all
found under lib/iode/core/. Built-in functions and macros written in iode
itself are found under lib/iode/src/. The `Iode::Core` module handles loading
these definitions into a Hash.

The class `Iode::Scope` is the basis for all lexical scoping. It loads the core
definitions into the root scope by default, then new scopes are chained from
there.

## Copyright & Licensing

Licensed under the Apache License, Version 2.0. See the LICENSE.txt file for
full details.
