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

require 'kknife/command'
require 'kknife/knifecmd'
require 'kknife/dbg'
require 'trollop'


class Kknife

  include Dbg

  def run( commands = ARGV )

    # Trollop argv parsing
    opts = Trollop::options do
      version "kknife 0.1.1 (c) 2013 Matt Hoyle. Deployable Ltd."
      banner <<-EOS
    kknife - chef knife command shortcuts

    Usage:  k [options] <knife sub commands>

    Where [options] are:
    EOS
      #opt :config, "User command shortcuts and ambiguities"
      opt :test,     "Test lookup, don't execute knife"
      opt :debug,    "Turn on debug output"
      opt :list,     "List commands"
      stop_on_unknown()
    end

    debug_logger.level = Logger::DEBUG if opts[:debug]

    # Create the knife controller
    k = Knifecmd.new( :argv => ARGV )

    # Do the optional bits
    #k.user_config if opts[:config]
    k.print if opts[:debug]

    # Then run what we've been asked to
    if opts[:list]
      # Print the list of commands
      k.print unless opts[:debug]

    elsif opts[:test]
      # Don't run knife, just print what would have been run
      printf "%s\n", k.resolve( ARGV ).join(' ')

    else
      # Otherwise run knife directly with the lookedup ARGV
      k.run
    end

  end

end