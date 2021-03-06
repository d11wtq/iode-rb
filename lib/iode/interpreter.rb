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
  # Iode interpreter, providing the central #evaluate function.
  class Interpreter
    # Create a new Interpreter with a given Scope.
    #
    # @param [Scope] scope
    #   the initial environment
    def initialize(scope = Scope.new)
      @env = scope
    end

    # Get the head (car) of a list.
    #
    # @param [Array] list
    #   the list to return the car from
    #
    # @return [Object]
    #   the first element in list
    def car(list)
      v, *_ = list
      v
    end

    # Get the tail (cdr) of a list.
    #
    # @param [Array] list
    #   the list to return the cdr from
    #
    # @return [Array]
    #   all but the head of the list
    def cdr(list)
      _, *v = list
      v
    end

    # Create an explicit progn block.
    #
    # A progn encapsulates a list of S-Exprs to be evaluateuated in sequence.
    # The last evaluateuated S-Expression becomes the value of the progn.
    #
    # @param [Object...] *sexps
    #   a list of S-Expressions to wrap in a progn
    #
    # @return [Object]
    #   the value of the last S-Expression
    def progn(*sexps)
      tail_pos = (sexps.length - 1)
      curr_idx = 0

      sexps.inject(nil) do |prev, sexp|
        if curr_idx == tail_pos
          reduce(sexp)
        else
          curr_idx += 1
          eval(sexp)
        end
      end
    end

    # Create a new func.
    #
    # These funcs act as closures in their environment.
    #
    # @param [Array] argnames
    #   a list of argument names as function inputs
    #
    # @param [Object...] *sexps
    #   variadic list of S-Expressions for the body
    #
    # @return [Function]
    #   a callable function
    def func(argnames, *sexps)
      arg_binding = ArgBinding.new(argnames)
      Function.new do |*args|
        Interpreter.new(
          @env.push_scope(arg_binding.produce(args))
        ).progn(*sexps)
      end
    end

    # Create a new macro.
    #
    # Macros are acually just a special case of func and also close their
    # environment and can be passed as arguments.
    #
    # @param [Array] argnames
    #   a list of argument names as macro inputs
    #
    # @param [Object...] *sexps
    #   variadic list of S-Expressions for the body
    #
    # @return [Macro]
    #   a callable macro
    def macro(argnames, *sexps)
      arg_binding = ArgBinding.new(argnames)
      Macro.new do |*args|
        Interpreter.new(
          @env.push_scope(arg_binding.produce(args))
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
      if fn.respond_to?(:[])
        Call.new(fn, *args)
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
      result = reduce(sexp)

      if result.kind_of?(Call)
        result.trampoline
      else
        result
      end
    end

    private

    # Eval, but may leave a tail call to be trampolined
    def reduce(sexp)
      # FIXME: Refactor this to a strategy
      case sexp
      when Array
        case car(sexp)
        when nil
          nil
        when :quote
          car(cdr(sexp))
        when :if
          if eval(car(cdr(sexp)))
            reduce(car(cdr(cdr(sexp))))
          else
            reduce(car(cdr(cdr(cdr(sexp)))))
          end
        when :progn
          progn(*cdr(sexp))
        when :set!
          @env[car(cdr(sexp))] = eval(car(cdr(cdr(sexp))))
        when :def
          @env.define(car(cdr(sexp)), eval(car(cdr(cdr(sexp)))))
        when :func
          func(car(cdr(sexp)), *cdr(cdr(sexp)))
        when :macro
          macro(car(cdr(sexp)), *cdr(cdr(sexp)))
        when :apply
          sexp = cdr(sexp)
          callee = eval(car(sexp))
          case callee
          when Macro
            eval(apply(callee, car(cdr(sexp))))
          else
            apply(callee, eval(car(cdr(sexp))))
          end
        when :eval
          eval(eval(car(cdr(sexp))))
        else
          callee = eval(car(sexp))
          case callee
          when Macro
            eval(eval(apply(callee, cdr(sexp))))
          else
            apply(callee, cdr(sexp).map(&method(:eval)))
          end
        end
      when Symbol
        @env[sexp]
      when Type
        sexp.to_ruby(self)
      else
        sexp
      end
    end
  end
end
