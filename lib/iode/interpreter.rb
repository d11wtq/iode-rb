# iode: interpreter.rb
# 
# Copyright 2014 Chris Corbyn <chris@w3style.co.uk>
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Iode
  # Iode interpreter, providing the central #eval function.
  class Interpreter
    include BuiltIns # FIXME: Remove this coupling!

    # Create a new Interpreter with a given Scope.
    #
    # @param [Scope] scope
    #   the initial environment
    def initialize(scope = Scope.new)
      @env = scope
    end

    # Create an explicit progn block.
    #
    # A progn encapsulates a list of S-Expressions to be evaluated in sequence.
    # The last evaluated S-Expression becomes the value of the progn.
    #
    # @param [Object...] *sexps
    #   a list of S-Expressions to wrap in a progn
    #
    # @return [Object]
    #   the value of the last S-Expression
    def progn(*sexps)
      sexps.inject(nil){|_,s| eval(s)}
    end

    # Create a new lambda for Iode.
    #
    # These lambdas act as closures in their environment.
    #
    # @param [Array] argnames
    #   a list of argument names as function inputs
    #
    # @param [Object...] *sexps
    #   variadic list of S-Expressions for the body
    #
    # @return [Proc]
    #   a callable lambda
    def lambda(argnames, *sexps)
      Proc.new do |*args|
        Interpreter.new(
          @env.push_scope(Hash[argnames.zip(args)])
        ).progn(*sexps)
      end
    end

    # Apply a function to its arguments.
    #
    # @param [Callable] fn
    #   a Proc or a Lambda
    #
    # @param [Array] args
    #   a list of arguments to apply with
    #
    # @return [Object]
    #   the function return value
    def apply(fn, args)
      if fn.respond_to?(:call)
        fn.call(*args)
      else
        raise "Cannot apply non-function `#{fn}`"
      end
    end

    # Given an iode data structure, execute it.
    #
    # @param [Object] sexp
    #   any valid S-expression in iode
    #
    # @return [Object]
    #   whatever the expression evaluates to
    def eval(sexp)
      case sexp
      when Array
        case car(sexp)
        when nil
          nil
        when :quote
          cadr(sexp)
        when :if
          if eval(cadr(sexp))
            eval(caddr(sexp))
          else
            eval(cadddr(sexp))
          end
        when :progn
          progn(*cdr(sexp))
        when :set!
          @env[cadr(sexp)] = eval(caddr(sexp))
        when :lambda
          lambda(cadr(sexp), *cddr(sexp))
        else
          apply(eval(car(sexp)), cdr(sexp).map(&method(:eval)))
        end
      when Symbol
        @env[sexp]
      else
        sexp
      end
    end
  end
end