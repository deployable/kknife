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

### Lookup

# Provides some lookups commands not based on knife commands
# Ambiguities are helpers in the case of an ambiguous "find"
# Shortcuts will be used if all other command lookups fail

module Lookup

  Shortcuts = {
    'ff' => [ 'from', 'file' ],
    'db' => [ 'data', 'bag' ],
    'cs' => [ 'cookbook', 'site' ],
    'bd' => [ 'bulk', 'delete' ],
    'ne' => [ 'node', 'edit' ],
    'ns' => [ 'node', 'show' ],
    'rl' => [ 'run', 'list' ],
  }

  Ambiguities = {
    'd' => ['download'],
    'e' => ['environment'],
    'r' => ['role'],
    'c' => ['cookbook'],
  }

  def self.shortcut( key )
    Shortcuts[key] if Shortcuts.has_key? key
  end

  def self.ambiguity( key )
    Ambiguities[key] if Ambiguities.has_key? key
  end

end