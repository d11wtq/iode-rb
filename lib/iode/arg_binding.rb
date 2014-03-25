# iode: arg_binding.rb
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
  # Provides the support for binding function parameters will call arguments.
  class ArgBinding
    # Initialize the binding with the given argument names.
    #
    # @param [Array] argnames
    #   a list of symbols for the argument names
    #
    # If the argument names are invalid, an error is raised.
    def initialize(argnames)
      singles, variadic, *junk = argnames.slice_before(:&).to_a

      if junk.any?
        raise "Functions cannot declare more than one variadic parameter"
      end

      @singles, @variadic, @extra = Array(singles),
                                    Array(Array(variadic)[1]),
                                    Array(Array(variadic)[2..-1])
    end

    # Returns true if these parameters accept variable argument sizes.
    #
    # @return [Boolean]
    #   true if the function is variadic
    def variadic?
      @variadic.any?
    end

    # Returns the arity of the function as a Range.
    #
    # @return [Range]
    #   an inclusive range of allowed argument lengths
    def arity
      min = (@singles.length + @extra.length)

      if variadic?
        min..Float::INFINITY
      else
        min..min
      end
    end

    # Produce the mapping between the argument names and the call values.
    #
    # @param [Array] values
    #   values passed in a function call
    #
    # @return [Hash]
    #   the mapping with the values
    def produce(values)
      num_args = values.length

      unless arity === num_args
        raise "Artity mismatch: expected #{arity}, received #{num_args}"
      end

      num_variadic = num_args - arity.min

      singles  = Hash[@singles.zip(values[0, @singles.length])]
      extra    = Hash[@extra.zip(values[(@extra.length * -1)..-1])]
      variadic = Hash[@variadic.zip([values[@singles.length, num_variadic]])]

      singles.merge(variadic).merge(extra)
    end
  end
end
