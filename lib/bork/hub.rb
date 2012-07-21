# bork is copyright (c) 2012 Noel R. Cower.
#
# This file is part of bork.
#
# bork is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# bork is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with bork.  If not, see <http://www.gnu.org/licenses/>.

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

    def run cmd, args = [], options = {}
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
