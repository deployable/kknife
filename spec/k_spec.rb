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

require 'spec_helper'
require './spec/helpers'

RSpec.configure do |c|
  c.include Helpers
end


describe "k command" do
 


  ListString = 'knife user show'
  Helpers.create_chef_server( 'localhost', 4000 )


  it "outputs debug with -d" do
    ARGV.replace %w( -d list )
  
    Chef::Application::Knife.any_instance.stub(:run).and_return( true )

    # replace the debug STDERR logger with our testable
    output = StringIO.new
    Dbg.replace output
    
    expect { Kknife.new.run }.to match_stdout( ListString )
    expect( output.string ).to match( /end of knife lookups \[list\] \[\]/ )

  end


  it "lists command with -l" do
    ARGV.replace %w( -l )

    expect { Kknife.new.run }.to match_stdout( ListString )
  end


  it "only dumps command when using test option" do
    ARGV.replace %w( -t node list )

    expect { Kknife.new.run }.to stdout( "node list\n" )
  end


  it "display the options in help" do
    ARGV.replace %w( -h )
    
    expect{ 
      begin
        Kknife.new.run   
      rescue SystemExit
      end
    }.to match_stdout( /-t.*-d.*-l/m )

  end


  it "display correct version with -v " do

    ARGV.replace %w( -v )

    expect{ 
      begin
        Kknife.new.run   
      rescue SystemExit
      end
    }.to stdout( "kknife 0.1.1 (c) 2013 Matt Hoyle. Deployable Ltd.\n" )

  end


  it "runs a knife command correctly" do

    o,e,t = Helpers.krunner %w( environment show test )

    expect( o ).to match( /^name:\s+test$/ )

  end


  it "passes options onto knife correctly" do

    o,e,t = Helpers.krunner %w( environment show test -F json )

    expect( o ).to match( /"name": "test"/ )

  end


  it "runs a knife command search correctly" do

    o,e,t = Helpers.krunner %w( n s nodeo )

    expect( o ).to match( /Node Name:   nodeo/ )
    expect( o ).to match( /Environment: test/ )
  end


end
