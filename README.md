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
```

Maps (Hashes)

``` lisp
(def x {'a 42, 'b 7})

(get x 'b) ; 7
(assoc x 'b 9) ; {'a 42, 'b 9}
(dissoc x 'b) ; {'a 42}
```

Regular expressions

``` lisp
(def re /[a-z]*_class/)
```

#### Loading other files

This is a work in progress. The end goal is to have modules (source files)
loaded based on naming conventions and load path configuration. I am fairly
opposed to global definitions, so when you include a source file, none of the
definitions that it provides will be seen by the current file. This is a good
thing, trust me. Instead, what happens is the last expression in the required
source file gets returned to the including file. The intention here is to
expressly export any definitions that may be made public. Anybody who has used
Node.js' require.js will be familiar with how this works. It minimizes coupling
and allows for much less painful dependency management (different files may
load different versions of the same dependency).

Currently the only supported mechanism for loading a source file is `require`.

``` lisp
;; foo.io

(def foo
  (func () (puts "I am foo!")))
```

``` lisp
;; bar.io

(require "foo.io")

(foo) ; error!

(def foo (require "foo.io"))

(foo) ; => "I am foo!"
```

Eventually I'm aiming for this:

``` lisp
;; lib/example.io

(def foo () 42)
(def baz () 99)

(export '(foo baz))
```

``` lisp
;; bar.io

(import 'example.*) ; loads exported definitions into current scope

(* (foo) (bar)) ; whatever 42 * 99 would be
```

Of course, there would be a suitable mechanism for renaming definitions
(internally `export` would probably just return a Map, and `import` would
enumerate that Map).

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
(def cadr
 (func (v) (car (cdr v))))

(def let
 (macro (bindings body)
   (list
    'apply
    (list 'func
          (map car bindings)
          body)
     (map cadr bindings))))

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

## Development

Iode (in this Ruby incarnation) is literally a few hours old at the time I
write this. Much is still not yet developed. However, you may poke around in
the internals and find some interesting this. A string of source code takes
this path to being executed as code.

    Input -> Reader<data> -> Interpreter<data> -> Core<data> -> Output

The source string is parsed by the Reader into native lisp data (using Ruby
data types, like Array and Symbol). The data representation is then given to
the Interpreter's eval method, which is a simple recursive algorithm mapping
the elements in the data to executable types (e.g. `[:func, [], 42]` becomes
a Proc). Variables are held in the Scope class, which is able to chain Scopes
together to create lexical closures. Core functions are registered as mixins
in the Core module.

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

Once I have namespacing done, you'll be able to write actual iode code in
separate files and have them loaded under a namespace.

## Copyright & Licensing

Licensed under the Apache License, Version 2.0. See the LICENSE.txt file for
full details.
