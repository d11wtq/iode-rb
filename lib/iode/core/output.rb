# iode: core/output.rb
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

require "iode/core"
require "pp"

module Iode
  module Core
    module Output
      def puts(*args, &block)
        Kernel.puts(*args, &block)
      end

      def p(*args, &block)
        Kernel.p(*args, &block)
      end

      def pp(*args, &block)
        Kernel.pp(*args, &block)
      end
    end
  end
end

Iode::Core.register Iode::Core::Output
