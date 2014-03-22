# iode: core/lists.rb
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

module Iode
  module Core
    module Lists
      def list(*args)
        args
      end

      def cons(v, list)
        [v, *Array(list)]
      end

      def head(list)
        v, *_ = Array(list)
        v
      end

      def tail(list)
        _, *v = Array(list)
        v
      end

      def nth(list, n)
        list[n]
      end

      def map(fn, list)
        list.map(&fn)
      end

      def empty?(list)
        list.empty?
      end
    end
  end
end

Iode::Core.register Iode::Core::Lists
