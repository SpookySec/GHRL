# frozen_string_literal: true

require 'fiddle'
require 'colorize'

module GHRL
  module_function

  # USEFUL CONSTANTS
  STR = 0
  NULL = 0
  CHAR = 1
  INT = 4
  PROCESS_ALL_ACCESS = 2_097_151
  KERNEL32 = Fiddle.dlopen('kernel32.dll')
  GHRL_DLL = Fiddle.dlopen("#{Dir.pwd}/ghrl.dll")

  # DLL FUNCTIONS USING FIDDLE
  def functions
    {
      OpenProcess: Fiddle::Function.new(KERNEL32['OpenProcess'],
                                        [Fiddle::TYPE_INT, Fiddle::TYPE_CHAR, Fiddle::TYPE_INT], Fiddle::TYPE_INT),
      TerminateProcess: Fiddle::Function.new(KERNEL32['TerminateProcess'], [Fiddle::TYPE_INT, Fiddle::TYPE_INT],
                                             Fiddle::TYPE_CHAR),
      GetProcessID: Fiddle::Function.new(GHRL_DLL['GetProcessID'], [Fiddle::TYPE_VOIDP], Fiddle::TYPE_VOIDP),
      GetModuleBaseAddress: Fiddle::Function.new(GHRL_DLL['GetModuleBaseAddress'],
                                                 [Fiddle::TYPE_INT, Fiddle::TYPE_VOIDP], Fiddle::TYPE_UINTPTR_T),
      RPMChar: Fiddle::Function.new(GHRL_DLL['RPMChar'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP],
                                    Fiddle::TYPE_CHAR),
      RPMInt: Fiddle::Function.new(GHRL_DLL['RPMInt'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP],
                                   Fiddle::TYPE_VOIDP),
      RPMBuf: Fiddle::Function.new(GHRL_DLL['RPMBuf'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP],
                                   Fiddle::TYPE_VOIDP),
      WPMChar: Fiddle::Function.new(GHRL_DLL['WPMChar'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_CHAR],
                                    Fiddle::TYPE_SIZE_T),
      WPMInt: Fiddle::Function.new(GHRL_DLL['WPMInt'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT],
                                   Fiddle::TYPE_SIZE_T),
      WPMBuf: Fiddle::Function.new(GHRL_DLL['WPMBuf'], [Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_VOIDP, Fiddle::TYPE_INT],
                                    Fiddle::TYPE_SIZE_T)

    }
  end

  # MAIN GAME CLASS
  class Game
    attr_reader :pid, :handle

    def initialize(process)
      attach_process(process)
    end

    # MAIN PROC ATTACH METHOD
    def attach_process(process)
      case process
      when String
        @pid = GHRL.functions[:GetProcessID].call(process).to_i
      when Integer
        @pid = process
      else
        Logger.error('Please pass either a String or Integer')
        exit!
      end

      @handle = GHRL.functions[:OpenProcess].call(GHRL::PROCESS_ALL_ACCESS, GHRL::NULL, @pid)

      # OpenProcess RETURNS 0 ON ERROR
      if @handle.zero?
        return unless @handle.zero?

        Logger.error("Couldn't find PID")
        exit!
      end
    end

    # ACTUAL HACKING METHODS
    def murder!
      GHRL.functions[:TerminateProcess].call(@handle, 0)
      true
    end

    def get_module_base_address(module_name)
      GHRL.functions[:GetModuleBaseAddress].call(@pid, module_name)
    end

    def read_memory(address, type)
      case type
      when GHRL::CHAR
        GHRL.functions[:RPMChar].call(@handle, address).to_s
      when GHRL::INT
        GHRL.functions[:RPMInt].call(@handle, address).to_i
      when GHRL::STR
        GHRL.functions[:RPMBuf].call(@handle, address)
      else
        Logger.error("Unknown type: #{type}")
        nil
      end
    end

    def write_memory(address, data, type)
      case type
      when GHRL::CHAR
        if data.instance_of?(String)
          if data.length == 1
            GHRL.functions[:WPMChar].call(@handle, address, data.ord).to_i
          end
        else
          Logger.error('GHRL::CHAR accepts one character')
          nil
        end

      when GHRL::INT
        if data.instance_of?(Integer)
          GHRL.functions[:WPMInt].call(@handle, address, data).to_i
        end
      when GHRL::STR
        if data.instance_of?(String)
          if data.length == 1
            Logger.error('Use GHRL::CHAR instead')
            return
          end

          GHRL.functions[:WPMBuf].call(@handle, address, data, data.length)
        end
      else
        Logger.error("Unknown type: #{type}")
        nil
      end
    end
  end

  # SMALL CUSTOM LOGGER CLASS WITH STATIC METHODS
  class Logger
    def self.error(msg)
      puts("[!] #{msg}".colorize(:red))
    end

    def self.success(msg)
      puts("[+] #{msg}".colorize(:green))
    end

    def self.int2hex(n)
      return unless n.instance_of?(Integer)

      "0x#{n.to_s(16)}"
    end
  end
end
