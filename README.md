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

### In Ruby Code

Using Iode from inside Ruby code can be interesting, as it will interoperate
with Ruby.

``` ruby
require "iode"

puts Iode.run <<-PROG
(if ((lambda (x) x) false)
  "x = true"
  "x = false")
PROG
```

The above code creates a lambda function that simply acts like the identity
function (i.e. it returns its input). That lambda is then immediately applied
with the input `false`, thereby returning `false`.

The `if` form evaluates false and therefore evaluates the else part of the
`if`, returning the string `"x = false"`.

Here's another example showing how you can pass values from Ruby into Iode.

``` ruby
require "iode"

prog = Iode.run <<-PROG
(lambda (x)
  (if x
    42
    7))
PROG

prog[false] #=> 7
prog[true]  #=> 42
```

This works because internally, Iode lambdas as represented as Ruby Procs.

Incidentally, that means you can even pass higher-order functions from Ruby
to Iode.

``` ruby
require "iode"

prog = Iode.run <<-PROG
(lambda (f)
  (if (f)
    42
    7))
PROG

prog.call(->(){ false }) #=> 7
prog.call(->(){ true })  #=> 42
```

I'd show a more complex example if the language were more than 3 hours old!
There are not even any mathematic operators or persistent definitions yet,
though all the wiring is there, I just need to define a core library.

## Copyright & Licensing

Licensed under the Apache License, Version 2.0. See the LICENSE.txt file for
full details.
