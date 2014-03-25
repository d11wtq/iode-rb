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

#### Variadic functions

A function may accept a variable number of arguments by using the `&` symbol
before the parameter name.

``` lisp
(def sprintf
  (func (str &values)
    (apply format (cons str values))))

(sprintf "It is %.2f degrees today in %s"
         23.7
         "Melbourne")
```

Whitespace after the `&` symbol is permitted and has no effect.

The variadic parameter may not necessarily be the last parameter of the func.
If any parameters are specified after the variadic parameter, they will
increase the minimum arity of the func and will cause the variadic parameter
to receive fewer arguments.

Only one variadic parameter is permitted per func definition.

Support for passing arguments to functions using variadic style is also
planned (like the splat in Ruby).

#### Tail call optimization

If the last thing a function returns is a call to another function (or itself),
iode will replace the current stack frame with the new call, giving limitless
recursion. This is practically essential for any functional language.

The following will loop forever and make the script "hang":

``` lisp
(let ((forever (func ()
                 (forever))))
  (forever))
```

This works for mutual recursion too.

``` lisp
(let ((odd? (func (n)
              (if (= n 0)
                false
                (even? (- n 1)))))
      (even? (func (n)
               (if (= n 0)
                 true
                 (odd? (- n 1))))))
  (even? 200000))
; true
```

Of course, the above routine is not efficient, but it demonstrates the ability
to recurse without blowing the stack.

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

Macros in iode are first class and have some powerful features. They are
objects and can therefore be assigned to variables and passed as arguments etc.

In many ways, macros are just like funcs, except that they receive unevaluated
iode data as input and return unevaluated iode data as output. This
transformation is done at runtime, which is what gives iode's macros the
quality of being handled as objects.

The syntax for returning code is a little cumbersome at this point, since I
haven't yet added quasiquoting. That is very soon on my list of things to do.

Since iode doesn't yet have the boolean operators `and` and `or`, let's define
them with macros.

``` lisp
(def and
  (macro (a b)
    (list (quote if) a
            b a)))

(def or
  (macro (a b)
    (list (quote if) a
            a b)))

(p (and false 42)) ; false
(p (and nil 1000)) ; nil
(p (and 1000 nil)) ; nil
(p (and 1000 888)) ; 888
(p (and 888 1000)) ; 1000

(p (or false 42)) ; 42
(p (or nil 1000)) ; 1000
(p (or 1000 nil)) ; 1000
(p (or 1000 888)) ; 1000
(p (or 888 1000)) ; 888
```

Ok, so the above macros assume their components are side-effect free, since
they evaluate the condition twice. It is left as an exercise to the reader to
find a way to correct this issue.

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
