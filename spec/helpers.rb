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

module Helpers

  # path current executing ruby bin
  RUBY = File.join( 
      RbConfig::CONFIG['bindir'], 
      RbConfig::CONFIG['ruby_install_name']
  ).sub(/.*\s.*/m, '"\&"')


  def self.runner( command )
      i,o,e,t = Open3.popen3( "#{command}" )
      i.close
      out = o.read
      err = e.read
      return [out,err,t]
  end

  def self.krunner( commands )
      lib = File.expand_path( '../lib', File.dirname(__FILE__) )
      bin = File.expand_path( '../bin/k', File.dirname(__FILE__) )
      arg = commands.join(' ')
      runner "#{RUBY} -I#{lib} #{bin} #{arg}"
  end


  require 'rest_client'
  require 'chef_zero/server'

  def self.create_chef_server( host = 'localhost', port = 80, env = 'test', node = 'nodeo'  )

    server = ChefZero::Server.new( host: 'localhost', port: 4000 )
    scheme = 'http'
    uri    = "#{scheme}://#{host}:#{port}"
    server.start_background

    env_obj = {
      :name                => env,
      :description         => "descenv",
      :cookbook_versions   => {},
      :json_class          => "Chef::Environment",
      :chef_type           => "environment",
      :default_attributes  => {},
      :override_attributes => {},
    }

    er = RestClient.post "#{uri}/environments", 
      env_obj.to_json, :content_type => :json, :accept => :json
    puts er.code unless er.code == 200 or er.code == 201

    node_obj = {
      :chef_type  => "node",
      :json_class => "Chef::Node",
      :name       => node,
      :chef_environment => env,
      :run_list   => []
    }
    #printf "%s %s\n", r.code, r.to_str

    nr = RestClient.post "#{uri}/nodes", 
      node_obj.to_json, :content_type => :json, :accept => :json
    puts nr.code unless nr.code == 200 or nr.code == 201

    return server
  end

end