require_relative '../ghrl'

# Defining variables
exe_name = 'ac_client.exe'
name_offset = 0x225
static_player = 0x10F4F4
new_name = 'spooky_was_here'

# Creating the game object
ac_client = GHRL::Game.new(exe_name)

# Should return 0x400000
module_base = ac_client.get_module_base_address(exe_name)

# Player object
local_player = ac_client.read_memory(module_base + static_player, GHRL::INT)

# Writing the new name to memory
ac_client.write_memory(local_player + name_offset, new_name, GHRL::STR)