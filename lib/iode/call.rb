# iode: tail_call.rb
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
  class Call
    def initialize(func, *args)
      @func = func
      @args = args
    end

    # Return a final value from the function application.
    #
    # Internally this function uses a trampoline to eliminate tail calls.
    #
    # @return [Object]
    #   the final return value
    def return
      # FIXME: This doesn't work and blows the stack for reasons unclear to me.
      #
      # It is probably due to #apply always coming here and starting a *new*
      # trampoline.
      #
      # Another idea is:
      #
      #   - 1. Change #apply to just return a Call object without invoking it.
      #   - 2. Change #progn to invoke #bounce on any Call that is the old acc.
      #   - 3. Capture return value of #progn in the block of #func/#macro.
      #   - 4. If return value is a Call, bounce it.
      #   - 5. But then what about calls inside conditionals?
      trampoline = self
      trampoline = trampoline.bounce while trampoline.kind_of?(Call)
      trampoline
    end

    def bounce
      @func[*@args]
    end
  end
end
