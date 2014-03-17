# Iode RB

An experimental lisp-family language hosted on Ruby.

## Installation

Add this line to your application's Gemfile:

    gem 'iode'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iode

## Usage

Firstly, please don't think that this project is a serious attempt to build
some shiny new language that runs in Ruby. It is possible it may become that
one day, but right now it exists purely for my own experimentation purposes.

I am building a real language on the LLVM (currently in a private git repo),
however I wanted a "quick and dirty" environment to hack together ideas for
what the syntax and language features may include. Ruby is perfect for that.
Once I have good ideas put down as working examples in this project, they will
be ported upstream to the native JIT interpreter for LLVM.

Currently this project just implements the guts of a functional lisp-family of
languages. It will change considerably from the current implementation.

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

Functions are (currently) defined in terms of `lambda`.

``` lisp
((lambda (x y) (* x y)) 6 3) ; 18
```

As you'd expect, functions are first-class objects in Iode.

Of course, functions can be defined recursively too.

``` lisp
;; Recursive function example.
(def loop
     (lambda (n)
       (if (= n 0)
         (quote done)
         (progn
           (puts n)
           (loop (- n 1))))))

(loop 20)
```

The above code will print 20 through 1 to the screen and finally return the
Symbol `:done` to Ruby (quoted Iode Symbols are also Ruby Symbols). Note that
I haven't yet done tail call elimination.

Similarly, closures can be returned from functions.

``` lisp
;; Provides partial application of a function
(def curry
     (lambda (fn a)
       (lambda (b) (fn a b))))

((curry + 2) 3) ; 5
```


### In Ruby Code

Using Iode from inside Ruby code can be interesting, as it will interoperate
with Ruby.

``` ruby
require "iode"

result = Iode.run <<-PROG
(if ((lambda (x) x) false)
  "x = true"
  "x = false")
PROG

puts result
```

The above code creates a lambda function that simply acts like the identity
function (i.e. it returns its input). That lambda is then immediately applied
with the input `false`, thereby returning `false`.

The `if` form evaluates false and therefore evaluates the else part of the
`if`, returning the string "x = false".

Here's another example showing how you can pass values from Ruby into Iode.

``` ruby
require "iode"

prog = Iode.run <<-PROG
(lambda (x)
  (if x
    (puts 42)
    (puts 7)))
PROG

prog.call(false) #=> 7
prog.call(true)  #=> 42
```

This works because internally, Iode lambdas as represented as Ruby Procs.

Incidentally, that means you can even pass higher-order functions from Ruby
to Iode.

``` ruby
require "iode"

prog = Iode.run <<-PROG
(lambda (f)
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

    String(source) -> Reader(data) -> Interpreter(data) -> Core(data) -> Result

The source string is parsed by the Reader into native lisp data (using Ruby
data types, like Array and Symbol). The data representation is then given to
the Interpreter's eval method, which is a simple recursive algorithm mapping
the elements in the data to executable types (e.g. `[:lambda, [], 42]` becomes
a Proc). Variables are held in the Scope class, which is able to chain Scopes
together to create lexical closures. Core functions are registered as mixins
in the Core module.

If you want to add a native Ruby function to be applied like an Iode function,
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

Once I have namespacing done, you'll be able to write actual Iode code in
separate files and have them loaded under a namespace.

## Copyright & Licensing

Licensed under the Apache License, Version 2.0. See the LICENSE.txt file for
full details.
