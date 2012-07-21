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

    class RmCommand

      def self.command
        :rm
      end

      def run args, options = {}
        station = Bork::Station.new options[:station]

        files = nil
        tags = nil

        begin
          files, tags = Bork.extract_file_tag_arguments args
        rescue Exception => ex
          puts "bork-rm: #{ex}"
          exit 1
        end

        if tags.empty?
          puts "bork-rm: No tags specified."
          exit 1
        elsif files.empty?
          puts "bork-rm: No files specified."
          exit 1
        end

        files.each {
          |file_path|
          hash = Bork.hash_file file_path

          station.remove_tags_from_hash! tags, hash, options
        }
      end

      def help_string
        ''
      end

      Bork::Hub.default_hub.add_command_class self

      if __FILE__ == $0
        self.new.run ARGV
      end

    end # RmCommand

  end # Commands

end # Bork
