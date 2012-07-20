#!/usr/bin/env ruby -w -rbork
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

require 'fileutils'
require 'json'
require 'set'

require 'bork/aux'
require 'bork/hub'
require 'bork/station'

module Bork

  class StationCommand

    def self.command
      :station
    end

    def run args, options = {}
      search_path = options[:station]
      begin
        station = Bork::Station.new search_path
        puts station
      rescue
        puts "bork-station: No station found."
      end
    end

    def help_string
      ''
    end

    Bork::Hub.default_hub.add_command_class self

  end # StationCommand

end

if __FILE__ == $0
  Bork::StationCommand.new.run ARGV
end
