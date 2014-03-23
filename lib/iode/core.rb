# iode: core.rb
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
  # Iode Core language definitions.
  #
  # This is simply a module that exposes all its instance methods as functions.
  #
  # The actual functions are mixed in by other modules.
  module Core
    # Require an iode source file, retuning the last evaluated expression.
    #
    # @param [String] file
    #   the filename to load, relative to the caller
    #
    # @return [Object]
    #   the last thing evaluated in the file
    def require(file)
      Interpreter.new.eval(Reader.new.read_file(file))
    end

    class << self
      include Core

      # Register a new library of functions into the global definitions.
      #
      # @param [Module] base
      #   the module to register
      def register(base)
        include(base).tap{@definitions = nil}
      end

      # Load all core definitions.
      #
      # @return [Hash]
      #   core functions and variables
      def definitions
        unless @definitions
          (@definitions = native_definitions).tap do |defs|
            defs.merge!(hosted_definitions)
          end
        end

        @definitions
      end

      private

      def native_names
        instance_methods
      end

      def native_definitions
        Hash[
          native_names.zip(
            native_names.map(&method(:instance_method)).map{|m| m.bind(self)}
          )
        ]
      end

      def hosted_definitions
        %w[let module].inject({}) do |acc, basename|
          file = File.expand_path("../src/#{basename}.io", __FILE__)
          acc.merge(self.require(file))
        end
      end
    end
  end
end
