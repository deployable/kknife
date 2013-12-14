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
require 'kknife/lookup'
require 'chef/knife'
require 'chef/application/knife'

### Knifecmd 
# Used as the base for the knife command. 
# Stories information about the run and the 
# Command tree

class Knifecmd

  include Dbg

  attr_accessor :shortcuts, :ambiguities, :commands, :cmd_found, :cmd_left, :knife_commands

  def initialize( argopts = {} )

    # Root command is k.. or knife
    @root = 'knife'

    opts = {
      :commands     => ARGV.dup.freeze,
      :cmd_found    => [],
      :cmd_left     => ARGV.dup,
      :shortcuts    => {},
      :ambiguities  => {},
      :config_build => '~/.chef/.kknife.built.config',
      :config_user  => '~/.chef/.kknife.user.config',
    }.merge argopts

    @commands     = opts[:commands]
    @cmd_found    = opts[:cmd_found]
    @cmd_left     = opts[:cmd_left]
    @shortcuts    = opts[:shortcuts]
    @ambiguities  = opts[:ambiguities]
    @config_build = File.expand_path opts[:config_build]
    @config_user  = File.expand_path opts[:config_user]

    @cmd_root = Command.new( @root, :controller => self )
    
    # Instead of trawling for chef files each time we can load a previous config
    lookup_files unless lookup_config

    # Now process the knife commands into a tree of Command
    load_commands

    # Then setup to find commands
    reset_found
  end


  # Look up the knife commands from a prebuilt kknife config
  def lookup_config
    # pull in a config if it exists
    return false unless File.exists? @config_build

    @knife_commands = JSON.parse File.open( @config_build, 'r' ){|f| f.read }
  end


  # Look up the knife commands from knife library files
  def lookup_files
    # pull in the standard knife files
    Chef::Knife.load_commands
    @knife_commands = Chef::Knife.subcommands_by_category
  end


  # Write out a built config file
  def write_config
    raise "No directory [#{File.dirname( @config_build )}]" unless Dir.exists? File.dirname( @config_build )
    File.open( @config_build, 'w' ){|f| f.write @knife_commands.to_json }
  end


  # Remove a built config file
  def clear_config
    FileUtils.rm @config_build if File.exists? @config_build
  end


  # Turn the knife command arrays into a Command tree
  def load_commands
    # loop over the commands, put them into Command
    @knife_commands.each do |category,command_arr|
      dbg 'category', category
      command_arr.each do |command|
        dbg 'command', command
        commands = command.split( /_/ )
        @cmd_root.add_command commands
      end
    end
  end


  # Start with out root Command and print the command tree
  def print_tree
    @cmd_root.pp
  end
  def print
    @cmd_root.pp_single
  end

  # Start at the root command and go down the tree
  # looking for each command
  def lookup( commands = @commands )
    dbg 'lookup', commands
    reset_found commands 

    begin
      @cmd_root.process_lookup commands

    rescue Command::AmbiguousCommand => e
      raise "error [#{commands.to_s}] #{e}"
      
    rescue Command::NotFoundCommand => e
      raise "error [#{commands.to_s}] #{e}"

    rescue Command::NoMoreSubCommands
      dbg "end of knife lookups", @cmd_found.join(','), @cmd_left.join(',')

    rescue Command::NoMoreSuppliedCommands
      dbg "end of argv lookups", @cmd_found.join(','), @cmd_left.join(',')

    end

    @cmd_found
  end

  
  # if the Command lookup needs to split a command
  # remove the command from what's left and split it 
  # into the componenets
  def cmd_split( split_command_array )
    # first remove the previous entry with _
    @cmd_left.shift

    # then prefix the new split entires
    @cmd_left.unshift *split_command_array
  end


  # if the Command lookup find a command, add it to found
  # and take it away from whats left 
  def found_cmd( command )
    dbg 'found_cmd b4 ', command, @cmd_found.join(','), '|', @cmd_left.join(',')
    @cmd_found.push command
    @cmd_left.shift
    dbg 'found_cmd aft', command, @cmd_found.join(','), '|', @cmd_left.join(',')
  end


  # if the Command lookup hits a shortcut, adjust local 
  # variables to match
  def found_shortcut( shortcut )
    dbg 'found_shortcut b4 ', shortcut.join(','), '|', @cmd_left.join(',')
    @cmd_left.shift
    @cmd_left.unshift *shortcut
    dbg 'found_shortcut aft', shortcut.join(','), '|', @cmd_left.join(',')
  end


  # reset the command found instance variables
  def reset_found( commands = [] )
    @cmd_found = []
    @cmd_left  = commands.dup
  end


  # return the found command as a space seperated string
  def found_string
    ([ @root ] + @cmd_found ).join(' ')
  end


  # resolve a list of commands into real commands
  def resolve( commands )
    lookup commands
    @cmd_found + @cmd_left
  end

  # Run the knife command
  def run( commands = ARGV )

    # mess with argv
    ARGV.replace resolve( commands )

    # Run knife directly 
    Chef::Application::Knife.new.run

  end

end
