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

### Log - a global logger instance for classes 
#
# Allows you to call a single logger instance easily from your classes
#
#     class Yours
#       include Log
#       def method
#         log.info 'something'
#       end
#     end

module Log

  DefaultIO = STDOUT

  # returns the singleton
  def log
    Logging.log
  end

  # replace the logger with a new target
  def self.replace( io )
    l = Logger.new io
    l.level = @log.level
    @log = l
  end

  # create a new logger
  def self.create
    l = Logger.new DefaultIO
    l.level = Logger::INFO
    l
  end

  # return the singleton or create it
  def self.log
    @log ||= create
  end

end