## kknife 0.1.1

### Shortcuts for the chef knife command

`k n e somenode    = knife node edit somenode`
`k c u somebook    = knife cookbook upload somebook`
`k e u ff somefile = knife cookbook from_file somefile`

`k -l` lists all your commands

`k -d` might tell you what's going wrong.

Lookups for shortcuts and ambiguous commands are currently statically defined in `lib/kknife/lookup.rb`. These will be user configurable/overridable. Some form of json/yml blob in ~/.chef/ should do. 

  Shortcuts
```
    'ff' => [ 'from', 'file' ],
    'db' => [ 'data', 'bag' ],
    'cs' => [ 'cookbook', 'site' ],
    'bd' => [ 'bulk', 'delete' ],
    'ne' => [ 'node', 'edit' ],
    'ns' => [ 'node', 'show' ],
    'rl' => [ 'run', 'list' ],
```
  Ambiguities
```
    'd' => ['download'],
    'e' => ['environment'],
    'r' => ['role'],
    'c' => ['cookbook'],
```