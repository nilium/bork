module Bork

  class Hub

    @@default_hub = nil

    def initialize
      @commands = {}
    end

    def add_command_class clas
      raise "Class for #{command} is nil." if clas.nil?

      @commands[clas.command] = clas
    end

    def commands
      # just do a shallow copy to prevent direct access to the ivar's value
      @commands.clone
    end

    def class_for_command cmd
      raise "No such module for command '#{cmd}'." unless @commands.include? cmd

      @commands[cmd]
    end

    def run cmd, args, options = {}
      class_for_command(cmd).new.run args, options
    end

    def help_string cmd
      class_for_command(cmd).new.help_string
    end

    def self.default_hub
      if @@default_hub.nil?
        @@default_hub = self.new
      end
      @@default_hub
    end

    def self.default_hub= hub
      @@default_hub = hub
    end

  end # Hub

end # Bork
