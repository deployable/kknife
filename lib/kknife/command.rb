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

require 'kknife/dbg'

### Command 
#
# This is used to store a tree of Commands by name
# Like a hash, but with a few extra features
#
#   knife
#     node
#       list
#       edit
#     environment
#       list
#       edit
#
# Allows you to navigate up and down the tree.

class Command

  include Dbg
  
  # For the end of the tree
  class NoMoreSubCommands < StandardError; end

  # For the end of the user commands
  class NoMoreSuppliedCommands < StandardError; end

  # When more than one Command is looked up
  class AmbiguousCommand < StandardError; end

  # When no Command's can be found
  class NotFoundCommand < StandardError; end

  attr_accessor :cmd, :cmd_short, :sub_commands, :source, :level, :parent, :root, :controller
  
  def initialize( command, argopts = {} )
    @cmd = command
    
    opts = {
      :cmd_short    => nil,
      :source       => nil,
      :level        => 0,
      :sub_commands => {},
      :parent       => nil,
      :root         => self,
      :controller   => nil
    }.merge argopts

    @cmd_short    = opts[:cmd_short]
    @source       = opts[:source]
    @parent       = opts[:parent]
    @level        = opts[:level]
    @sub_commands = opts[:sub_commands]
    @root         = opts[:root]
    @controller   = opts[:controller]

    # this could just return the root's controller. 
    @controller   = @root.controller if not @root.nil? and @controller.nil?
    raise "require controller" if @controller.nil?
    
    @level        = @parent.level + 1 unless @parent.nil?

    dbg 'test'
    debug_logger.debug( 'Command init' )
  end
  
  # return the command string
  def to_s 
    @cmd
  end


  # Add a sub Command to this Command
  def add_subcmd( command )
    unless has_sub_command? command 
      dbg 'add_subcmd', command, cmd
      @sub_commands[command] = Command.new( command, :parent => self, :root => @root )
    end
    @sub_commands[command]
  end


  # Print current command as a tree, recurse through sub commands
  def pp
    printf "%s%s\n", '  ' * level, cmd
    @sub_commands.each_key do |key|
      @sub_commands[key].pp
    end
  end
  
  # Print the current command on a single line if it's the last 
  # in the tree, otherwise move down.
  def pp_single
    printf "%s\n", command_lookup.reverse.join(' ') if has_no_sub_commands?
    @sub_commands.each_key do |key|
      @sub_commands[key].pp_single
    end
  end

  # Recurse back down the Command tree and return the full command
  def command_lookup
    return [ @cmd ] + @parent.command_lookup unless @parent.nil?
    [ @cmd ]
  end

  # Test for existence of a sub Command
  def has_no_sub_commands?
    @sub_commands.empty?
  end

  # Test for existence of a sub Command
  def has_sub_command?( command )
    @sub_commands.has_key? command
  end

  # Find a sub Comamnd via substr
  def sub_command_find( command )
    @sub_commands.keys.grep( Regexp.new( '^' + Regexp.escape(command) + '.*' ) )
  end

  # Return a sub Comamnd by name
  def sub_command( command )
    @sub_commands[command] if has_sub_command? command
  end


  # Add a list of commands, recursing down the tree
  def add_command( commands )
    first = commands.shift
    
    dbg "first", first
    if has_sub_command? first
      dbg "first exists", first
    end

    sub_cmd = add_subcmd first
    sub_cmd.add_command( commands ) unless commands.empty?
  end


  # Recursively lookup a list of commands
  def process_lookup( commands )

    raise NoMoreSuppliedCommands, "end of args" if commands.empty?

    commands_local   = commands.dup
    first_command    = commands_local.shift
    sub_command_list = sub_command_find first_command
    rest_commands    = commands_local

    dbg 'first', first_command
    dbg 'list',  sub_command_list
    dbg 'rest',  rest_commands

    # If we have a command or can look one up, all is good
    if has_sub_command? first_command or sub_command_list.length == 1

      cmd   = sub_command first_command
      cmd ||= sub_command sub_command_list.first

      dbg 'cmd', cmd.cmd
      @controller.found_cmd cmd.cmd
      raise NoMoreSubCommands, "end of lookup commands" if cmd.sub_commands.empty?
      
      return cmd.process_lookup rest_commands


    # If there was more than one match, check the ambiguity config
    # or error
    elsif sub_command_list.length > 1

      if Lookup.ambiguity( first_command )
        process_lookup Lookup.ambiguity( first_command ) + rest_commands

      else
        raise AmbiguousCommand, "ambiguous [#{first_command}] [#{sub_command_list.join(',')}]"
      end


    # If there's an underscore, split it out
    elsif first_command.index(/_/)
      
      cmdsplit = first_command.split( /_/ )

      # notify the controller of the command changes
      @controller.cmd_split cmdsplit

      # rebuild the local commands
      first_command = cmdsplit.shift
      rest_commands = cmdsplit + rest_commands

      # now start again with the new values
      process_lookup [ first_command ] + rest_commands
      

    # Otherwise the command wasn't found, 
    # Look up shortcuts before giving up
    else

      shortcut = Lookup.shortcut( first_command )

      if shortcut
        @controller.found_shortcut shortcut
        process_lookup shortcut + rest_commands
      else
        raise NotFoundCommand, "sub command not found: [#{first_command}*]"
      end
      
    end

  end

end

