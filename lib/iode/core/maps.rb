# iode: core/maps.rb
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
    module Maps
      def hashmap(*args)
        Hash[args]
      end

      def get(map, key)
        map[key]
      end

      def keys(map)
        map.keys
      end

      def values(map)
        map.values
      end

      def assoc(map, key, val)
        map.merge(key => val)
      end

      def merge(*maps)
        maps.reduce(:merge)
      end

      def dissoc(map, key)
        map.reject{|k,_| k == key}
      end
    end
  end
end

Iode::Core.register Iode::Core::Maps
