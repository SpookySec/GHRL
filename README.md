<h1 align="center">GHRL</h1><br>
<p align="center">
  <a>
    <img src="ghrl.jpg" width="450">
  </a>
</p>

<p align="center">
  Game Hacking Ruby Library
</p>

---

## Description

  GHRL (pronounced "girl") is a Ruby library for creating simple external game cheats.

## Prerequisites

* colorize
* fiddle

## Supported Platforms

* Windows 10 :]

## Installation

```sh
gem install fiddle colorize
```

## Synopsis

```ruby
require 'ghrl'

# Attach to a process
game = GHRL::Game.new('ac_client.exe') # PID / EXE FILE NAME
# => #<GHRL::Game:0x00000000065d29a0 @handle=408, @pid=7956>

# Output the pid of the process
game.pid
# => 7956

# Generated HANDLE
game.handle
# => 408
```

MEMORY READING

```ruby
# Get the address of a loaded module
client_module = game.get_module_base_address('ac_client.exe')
# => 4194304

# Reading from memory (int or ptr)   # ADDRESS (Static ptr)         # TYPE
local_player = game.read_memory(client_module + 0x10F4F4, GHRL::INT)
# => 42968192

# Reading char arrays
name = game.read_memory(
    local_player + 0x225, # Name offset
    GHRL::STR # Type
)
# => spooky
```

MEMORY WRITING

```ruby
# Writing an integer (health)
nwritten_bytes = game.write_memory(
    local_player + 0xF8, # Health offset
    1337, # Value to write
    GHRL::INT # Type
)
# => 4

# Writing a string
nwritten_bytes = game.write_memory(
    player + 0x225, # Name offset
    'spooky_sec', # String to write
    GHRL::STR # Type
)
# => 10
```

KILLING THE PROCESS
(just for fun)

```ruby
game.murder!
# => true
```

## Notes

This project was just me wasting time and having fun,
if you would like to upgrade and make it a real thing
please feel free to contact me so we could fix this
shit of a code and perhaps add more features.

## Future Plans

Nothing in mind at the moment, maybe if bugs start arising again, I'll have to take action

## Acknowledgements

Thanks to [@glitch_prog](https://instagram.com/glitch_prog) for the logo.
Also special thanks to [@cloasies](https://instagram.com/cloasies) for the mental support while dealing with C++

## Author

SpookySec

## Socials

[@spooky_sec](https://instagram.com/spooky_sec)

[@SpookySec](https://github.com/SpookySec)

[@sec_spooky](https://twitter.com/sec_spooky)
