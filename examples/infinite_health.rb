require_relative '../ghrl'

# Defining variables
exe_name = 'ac_client.exe'
health_offset = 0xF8
static_player = 0x10F4F4

# Creating the game object
ac_client = GHRL::Game.new(exe_name)

# Should return 0x400000
module_base = ac_client.get_module_base_address(exe_name)

# Player object
local_player = ac_client.read_memory(module_base + static_player, GHRL::INT)

# Main loop
loop do

    # Change health to 9999
    ac_client.write_memory(local_player + health_offset, 9999, GHRL::INT)
    sleep(1) # Sleep for one second
end