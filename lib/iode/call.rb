# iode: call.rb
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
  # Represents a tail optimized function application.
  #
  # Internally this class uses a trampoline to eliminate the stack for a tail
  # call.
  class Call
    attr_reader :func, :args

    # Initialize a new Call with the given func and args.
    #
    # @param [Callable] func
    #   any callable object (using #[])
    #
    # @param [Object...] args
    #   arguments to invoke the function with
    def initialize(func, *args)
      @func = func
      @args = args
    end

    # Complete the tail call using a trampoline routine.
    #
    # @return [Object]
    #   the final return value from the call
    def trampoline
      f = self
      f = f.call while f.kind_of?(Call)
      f
    end

    # Invoke this function and return a result.
    #
    # This may return a new Call, intended for use in #trampoline.
    #
    # @return [Object]
    #   the result of this function call
    def call
      @func[*@args]
    end
  end
end
