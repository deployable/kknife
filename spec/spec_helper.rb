# Author: Matt Hoyle (<matt@deployable.co>)
# Copyright: Copyright (c) 2015 Deployable Ltd.
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

require_relative '../lib/kknife'
 

require 'stringio'


RSpec::Matchers.define :match_stdout do |check|

  @capture = nil

  match do |block|

    begin
      stdout_saved = $stdout
      $stdout      = StringIO.new
      block.call
    ensure
      @capture     = $stdout
      $stdout      = stdout_saved
    end

    @capture.string.match check
  end

  failure_message_for_should do
    "expected to #{description}"
  end
  failure_message_for_should_not do
    "expected not to #{description}"
  end
  description do
    "match [#{check}] \non stdout [#{@capture.string}]"
  end

end


RSpec::Matchers.define :stdout do |check|

  @capture = nil

  match do |block|

    begin
      stdout_saved = $stdout
      $stdout      = StringIO.new
      block.call
    ensure
      @capture     = $stdout
      $stdout      = stdout_saved
    end

    @capture.string == check
  end

  failure_message_for_should do
    "expected stdout to be #{description}"
  end
  failure_message_for_should_not do
    "expected stdout not to be #{description}"
  end
  description do
    "[#{check}] \nbut got [#{@capture.string}]"
  end

end


RSpec::Matchers.define :stderr do |check|

  @capture = nil

  match do |block|

    begin
      stdout_saved = $stderr
      $stderr      = StringIO.new
      block.call
    ensure
      @capture     = $stderr
      $stderr      = stdout_saved
    end

    @capture.string == check
  end

  failure_message_for_should do
    "expected stderr to be #{description}"
  end
  failure_message_for_should_not do
    "expected stderr not to be #{description}"
  end
  description do
    "[#{check}] \nbut got [#{@capture.string}]"
  end

end


RSpec::Matchers.define :match_stderr do |check|

  @capture = nil

  match do |block|

    begin
      stdout_saved = $stderr
      $stderr      = StringIO.new
      block.call
    ensure
      @capture     = $stderr
      $stderr      = stdout_saved
    end

    @capture.string.match check
  end

  failure_message_for_should do
    "expected stderr to be #{description}"
  end
  failure_message_for_should_not do
    "expected stderr not to be #{description}"
  end
  description do
    "[#{check}] \nbut got [#{@capture.string}]"
  end

end
