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

require 'bork/aux'
require 'bork/hub'

module Bork

  module Commands

    class AddCommand

      def self.command
        :add
      end

      def run args, options = {}
        files = nil
        tags = nil
        station = nil

        begin
          files, tags = Bork.extract_file_tag_arguments args
          station = Bork::Station.new options[:station]
        rescue RuntimeError => ex
          puts "bork-add: #{ex}"
          exit 1
        end

        if tags.empty?
          puts "bork-add: No tags specified."
          exit 1
        elsif files.empty?
          puts "bork-add: No files specified."
          exit 1
        end

        files.map {
          |file_path|
          station.index_file! file_path, options
        }.each {
          |hash|
          station.tag_hash! tags, hash, options
        }
      end

      def help_string
        ''
      end

      Bork::Hub.default_hub.add_command_class self

      if __FILE__ == $0
        self.new.run ARGV
      end

    end # AddCommand

  end # Commands

end # Bork
