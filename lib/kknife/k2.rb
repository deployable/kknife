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

require 'chef/knife'

Debug = true
$cmd = {}

def dbg( str, *vars )
  printf "%s [%s]\n", str, vars.join("] [") if Debug
end

def add( h, cmds )
  dbg 'cmds', cmds.to_s
  first = cmds.shift
  if cmds.empty?
    h[first] = nil
  else
    h[first] = {} unless h.has_key? first and !h[first].nil?
    add h[first], cmds
  end
end

Chef::Knife.load_commands
Chef::Knife.subcommands_by_category.each do |category,command_arr|
  dbg 'category', category
  #$cmd[category] = {} unless $cmd.has_key? category
  command_arr.each do |command|
    dbg 'command', command
    commands = command.split( /_/ )
    add $cmd, commands
  end
end

pp $cmd

commands = ARGV.dup
cmd_extra = ARGV.dup
h = $cmd
cmd_knife = []

commands.each do |command|
  dbg 'command', command

  if h.nil?
    # Last knife command possible
    dbg 'final'
    break

  elsif h.has_key? command
    # Direct lookup
    dbg 'found cmd', command
    h = h[command]
    cmd_knife.push command
    cmd_extra.shift

  elsif command.index(/_/)
    # Split into spaces
    cmdsplit = command.split( /_/ )
    cmdsplit.each do |cmd|
      if h.has_key? cmd
        h = h[cmd]
        cmd_knife.push cmd
      else
        raise "command not found [#{cmd}] [#{command}]"
      end
    end
    cmd_extra.shift

  else
    # Search for ^command.*
    re = Regexp.new( '^' + Regexp.escape(command) + '.*$')
    search = h.keys.grep re
    case search.length
    when 0
      raise "command not found [#{re}]"
    when 1
      dbg 'srch cmd', command, search[0]
      cmd_knife.push command
      cmd_extra.shift
    else
      dbg 'srch cmds', command, search.to_s
    end
  end
end
dbg cmd_knife, '|', cmd_extra