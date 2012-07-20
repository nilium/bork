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

require 'bork/hub'
require 'bork/station'

module Bork

  class HelpCommand

    def self.command
      :help
    end

    def run args, options = {}
      if args.empty?
        puts help_string
      else
        hub = Bork::Hub.default_hub

        args.each {
          |cmd|
          puts hub.help_string cmd.to_sym
        }
      end
      exit 0
    end

    def help_string
      bork_dir = Bork::Station.station_directory
      <<-EOS.gsub(/^ {6}/, '')
      bork [options] [command] [arguments]

      Options:
        --verbose, -v
            Produces verbose output for bork commands.
        --station [path], -s [path]
            Sets the search directory for a bork station or provides a path
            directly to a bork station (the #{bork_dir} directory).

      Available bork commands:
        init    - Create a new bork index in the current directory.
        add     - Adds one or more files with one or more tags to the station.
        rm      - Removes a tag from a file or a file from the station.
        update  - Updates all links to files and tags. Run this if you modify
                  a file currently in the station.
        find    - Finds all files with the given tag and places them in the
                  current working directory.
        tags    - See all tags in the index.
        version - Get the current version of bork.
        help    - Get this text or provide a command to get additional
                  information, such as 'bork help init'.
        license - View the license text.

      bork is copyright (c) 2012 Noel R. Cower.
      This program comes with ABSOLUTELY NO WARRANTY. This is free software,
      and you are welcome to redistribute it under certain conditions. You
      should have received a copy of the GNU General Public License along with
      this program.  If not, see <http://www.gnu.org/licenses/>.

      EOS
    end

    Bork::Hub.default_hub.add_command_class self

  end

end

if __FILE__ == $0
  # have to load all other files here to get the required help strings
  Dir.foreach(File.dirname(__FILE__)) {
    |entry|
    next if entry =~ /^\./ || File.extname(entry).downcase != '.rb'
    # avoid horrible things.. well, too many horrible things
    next if File.basename(__FILE__) == entry
    require "bork/commands/#{entry}"
  }

  Bork::HelpCommand.new.run ARGV
end
