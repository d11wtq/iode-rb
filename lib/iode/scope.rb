# iode: scope.rb
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
  # Lexical scope environment for iode.
  #
  # Maintains a stack of execution contexts.
  class Scope
    # Create a new Scope with +values+ as available variables.
    #
    # @param [Hash] values
    #   key-values pairs of Symbol => Object
    #
    # @param [Scope] parent
    #   the parent scope, if any
    def initialize(values = {}, parent = nil)
      @values = values
      @parent = parent
    end

    # Reference a variable in this Scope or any parent Scopes.
    #
    # Raises a RuntimeError if the variable does not exist.
    #
    # @param [Symbol] k
    #   the variable name to lookup
    #
    # @return [Object]
    #   the object stored in this variable
    def [](k)
      if @values.key?(k)
        @values[k]
      elsif @parent
        @parent[k]
      else
        raise "Reference to undefined variable `#{k}`"
      end
    end

    # Re-assign a variable in this Scope, or any parent Scope.
    #
    # Raises a RuntimeError if the variable does not exist.
    #
    # @param [Symbol] k
    #   the variable name to assign
    #
    # @param [Object] v
    #   the value to assign
    #
    # @return [Object]
    #   the assigned object
    def []=(k, v)
      if @values.key?(k)
        @values[k] = v
      elsif @parent
        @parent[k] = v
      else
        raise "Reference to undefined variable `#{k}`"
      end
    end

    # Create a new Scope with this Scope as its parent.
    #
    # The new Scope will have access to all variables in this Scope.
    #
    # @param [Hash] values
    #   variables to exist in the new Scope
    #
    # @return [Scope]
    #   a new Scope with this Scope as its parent
    def push_scope(values = {})
      Scope.new(values, self)
    end
  end
end
