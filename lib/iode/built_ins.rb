# iode: built_ins.rb
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
  module BuiltIns
    def car(list)
      v, *_ = list
      v
    end

    def cdr(list)
      _, *v = list
      v
    end

    def cadr(list)
      car(cdr(list))
    end

    def cddr(list)
      cdr(cdr(list))
    end

    def caddr(list)
      car(cddr(list))
    end

    def cdddr(list)
      cdr(cddr(list))
    end

    def cadddr(list)
      car(cdddr(list))
    end

    def cddddr(list)
      cdr(cdddr(list))
    end

    def caddddr(list)
      car(cdddr(list))
    end

    def cdddddr(list)
      cdr(cddddr(list))
    end
  end
end
