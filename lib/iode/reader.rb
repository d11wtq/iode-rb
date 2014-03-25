# iode: reader.rb
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

require "whittle"

module Iode
  # Lisp reader, converting strings to lisp data structures.
  class Reader < Whittle::Parser
    # whitespace
    rule(/\s+/).skip!

    # commas are ignored
    rule(",").skip!

    # comments
    rule(/;.*/).skip!

    # syntax
    rule("'")
    rule("(")
    rule(")")
    rule("{")
    rule("}")

    # fractions as literals
    rule(:rational => /[0-9]+\/[0-9]+/).as{|n| Rational(n)}

    # key-value pair in a map
    rule(:map_pair) do |r|
      r[:sexp, :sexp].as {|a, b| [a, b]}
    end

    # list of key-value pairs in a mpa
    rule(:map_pair_list) do |r|
      r[].as                          {[]}
      r[:map_pair_list, :map_pair].as {|list, pair| list << pair}
    end

    # maps
    rule(:map) do |r|
      r["{", :map_pair_list, "}"].as{|_, pairs, _| Types::Map.new(pairs)}
    end

    # scalars
    {
      float:  /[0-9]+\.[0-9]+/,
      int:    /[0-9]+/,
      string: /"(\\.|[^"])*"/,
      regexp: /\/(\\.|[^\/])*\//
    }.each do |name, pattern|
      rule(name => pattern).as(&method(:eval))
    end

    # variables/symbols
    rule(symbol: /&|[^\(\)\s,;'"`\{\}]+/).as do |v|
      case v
      when "nil"
        nil
      when "false"
        false
      when "true"
        true
      else
        v.intern
      end
    end

    # atoms
    rule(:atom) do |r|
      r[:int]
      r[:float]
      r[:rational]
      r[:string]
      r[:symbol]
      r[:map]
    end

    # lists of s-exps
    rule(:sexp_list) do |r|
      r[].as                 {[]}
      r[:sexp].as            {|sexp| [sexp]}
      r[:sexp_list, :sexp].as{|list, sexp| list << sexp}
    end

    # s-exprs
    rule(:sexp) do |r|
      r[:atom]
      r["'", :sexp].as           {|_, sexp| [:quote, sexp]}
      r["(", :sexp_list, ")"].as {|_, list, _| list}
    end

    # a valid program is a list of s-exprs
    start(:sexp_list)

    # Read a string in as lisp data.
    #
    # @param [String] source
    #  iode source code to read in as lisp
    #
    # @return [Array]
    #   the source code as data for execution
    def read(source)
      progn = parse(source)
      if progn.length > 1
        [:progn, *progn]
      else
        progn.first
      end
    end

    # Read in a file as lisp data.
    #
    # @param [String] source
    #   iode source file path to read in as lisp
    #
    # @return [Array]
    #   the source code as data for execution
    def read_file(path)
      read(File.read(path))
    end
  end
end
