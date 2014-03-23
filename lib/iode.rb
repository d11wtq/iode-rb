# iode: iode.rb
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

require "iode/version"
require "iode/type"
require "iode/types/map"
require "iode/core/comparisons"
require "iode/core/lists"
require "iode/core/math"
require "iode/core/strings"
require "iode/core/output"
require "iode/core/maps"
require "iode/scope"
require "iode/interpreter"
require "iode/reader"
require "iode/function"
require "iode/macro"

module Iode
  class << self
    # Run a string of iode source code and return a value to Ruby.
    #
    # @param [String] source
    #   iode source code
    #
    # @return [Object]
    #   the return value of the program
    def run(source)
      Interpreter.new.eval(Reader.new.read(source))
    end
  end
end
