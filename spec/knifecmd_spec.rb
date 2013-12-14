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
 
describe Knifecmd do
 
  before :each do
    @k = Knifecmd.new
  end


  it "resolves commands correctly" do

    tests = [
      %w( download something ),
      %w( node edit nodename -s http://someserver ),
      %w( environment list ),
      %w( environment edit production ),
      %w( data bag from file /path/to/somefile ),
      %w( cookbook upload ),
      %w( client bulk delete ),
    ]

    tests.each do |test| 
      expect( @k.resolve( test ) ).to eq( test )
    end
  end


  it "resolves command with _'s" do

    tests = [
      [ %w( node run_list add recipe[something] ), %w( node run list add recipe[something] ) ],
    ]

    tests.each do |test,result| 
      expect( @k.resolve( test ) ).to eq( result )
    end
  end



  tests = [
    [ %w( d something ),        %w( download something ) ],
    [ %w( n e nodename ),       %w( node edit nodename ) ],
    [ %w( e l ),                %w( environment list )],
    [ %w( en l ),               %w( environment list )],
    [ %w( en e production ),    %w( environment edit production )],
    [ %w( da b f f /to/file ),  %w( data bag from file /to/file )],
    [ %w( coo u ),              %w( cookbook upload )],
    [ %w( cl b d ),             %w( client bulk delete )],
    [ %w( re l ),               %w( recipe list )],
    [ %w( ro l ),               %w( role list )],
  ]

  tests.each do |test,result| 
    it "resolves shortened command [#{test}]" do
      expect( @k.resolve( test ) ).to eq( result )
    end
  end



  tests = [
    [ %w( ne nodename ),    %w( node edit nodename) ],
    [ %w( ns nodename ),    %w( node show nodename) ],
    [ %w( client bd ),      %w( client bulk delete) ],
    [ %w( client bd ),      %w( client bulk delete) ],
    [ %w( cs download ),    %w( cookbook site download) ],
    [ %w( db ff /path/file ),  %w( data bag from file /path/file ) ],
    [ %w( node rl remove role[something] ),  %w( node run list remove role[something] ) ],
  ]

  tests.each do |test,result| 
    it "resolve shortcuts" do
      expect( @k.resolve( test ) ).to eq( result )
    end
  end



  tests = [
    [ %w( c u ),          %w( cookbook upload ) ],
    [ %w( c b d ),        %w( cookbook bulk delete ) ],
    [ %w( e show dev ),   %w( environment show dev ) ],
    [ %w( d ),            %w( download ) ],
    [ %w( r list ),       %w( role list ) ],
  ]

  tests.each do |test,result| 
    it "resolve ambiguous commands" do
      expect( @k.resolve( test ) ).to eq( result )
    end
  end

end

