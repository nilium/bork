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

require 'json'

require 'bork/aux'
require 'bork/hub'

module Bork

  module Commands

    class ClearCommand

      def self.command
        :clear
      end

      def run args, options = {}
        station = Bork::Station.new options[:station]

        verbose = options[:verbose]
        noop = options[:noop]

        checkout_file = "#{station}/checkout"
        do_update = false

        if File.exists? checkout_file
          checkout_string = File.open(checkout_file) { |io| io.read }
          cdata = JSON[checkout_string]

          cdata.each {
            |map|
            relpath = map['path']
            filepath = File.expand_path relpath, station.station_home

            if File.exists? filepath
              old_hash = map['hash']
              new_hash = Bork.hash_file filepath

              if old_hash != new_hash
                puts "bork-clear: Hashes differ for '#{Bork.relative_path Dir.pwd, filepath}'. Will update station." if verbose
                do_update = true
              end

              puts "bork-clear: Unlinking '#{Bork.relative_path Dir.pwd, filepath}'." if verbose
              File.unlink filepath unless noop
            elsif verbose
              puts "bork-clear: File '#{Bork.relative_path Dir.pwd, filepath}' does not exist."
            end
          }

          puts "bork-clear: Unlinking '#{checkout_file}'." if verbose
          File.unlink checkout_file unless noop

          if do_update
            options[:station] = station
            Bork::Hub.default_hub.run :update, [], options
          end
        end
      end

      def help_string
        ''
      end

      Bork::Hub.default_hub.add_command_class self

      if __FILE__ == $0
        require 'bork/commands/update'

        self.new.run ARGV
      end

    end # RmCommand

  end # Commands

end # Bork
