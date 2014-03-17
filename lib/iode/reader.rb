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

    # comments
    rule(/;.*/).skip!

    # syntax
    rule("(")
    rule(")")

    # scalars
    {
      float:  /[0-9]*\.[0-9]+/,
      int:    /[0-9]+/,
      string: /"(\\.|[^"])*"/,
      regexp: /\/(\\.|[^\/])*\//
    }.each do |name, pattern|
      rule(name => pattern).as(&method(:eval))
    end

    # variables/symbols
    rule(symbol: /[^\(\)\s;]+/).as do |v|
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
      r[:string]
      r[:symbol]
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
  end
end
