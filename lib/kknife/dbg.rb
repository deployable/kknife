# Author: Matt Hoyle (<matt@deployable.co>)
# Copyright: Copyright (c) 2013 Deployable Ltd.
# License: Apache License, Version 2.0
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

require 'logger'

### Dbg 
# a quick debug logger 
# classes can run `dbg`

# ```
# class Yours
#   include Dbg
#   def method
#     dbg 'some', values, logged
#   end
# end
# ```

module Dbg

  DefaultIO = STDERR
  DefaultLevel = Logger::INFO

  def debug_logger
    Dbg.debug_logger
  end

  def self.replace( io = DefaultIO, llevel = DefaultLevel )
    llevel = @debug_logger.level if @debug_logger
    @debug_logger = create( io, llevel )
  end

  def self.create( io = DefaultIO, llevel = DefaultLevel )
    l = Logger.new io
    l.level = llevel
    l
  end

  def self.debug_logger
    @debug_logger ||= create
  end

  def dbg( str, *vars )
    Dbg.debug_logger.debug sprintf( "%s [%s]", str, vars.join("] [") )  # if Debug
  end

end


