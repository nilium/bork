#!/usr/bin/env ruby -rbork
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
require 'pathname'

require 'bork/station'
require 'bork/aux'
require 'bork/hub'

module Bork

  module Commands

    class ListCommand

      TRUNCATED_HASH_LENGTH = 8

      def self.command
        :list
      end

      def run args, options = {}
        begin
          station = Bork::Station.new options[:station]

          verbose = options[:verbose]

          hashes = if ! args.empty?
            station.find_tagged_hashes(args)
          else
            station.file_hashes
          end

          root = station.station_home
          current_pn = Pathname.new(Dir.pwd)

          hashes.each {
            |hash|
            file_path = station.file_for_hash(hash)
            file_path = File.expand_path(file_path, root)
            rel_path = Pathname.new(file_path).relative_path_from(current_pn).to_s
            puts "#{verbose ? hash : hash[0...TRUNCATED_HASH_LENGTH]}: #{rel_path}"
          }
        rescue RuntimeError => ex
          puts "bork-list: #{ex}"
          exit 1
        end

      end

      def help_string
        <<-EOS.gsub(/^ {8}/, '')
        bork list [tag] [<op><tag>] ...

        Searches for files with the given tags and prints their filenames to
        stdout.

        Tags can be optionally be prefixed with one of three operators, &, the
        intersection operator; +, the union operator; and -, the difference
        operator. The first tag is assumed to always be a union and all other
        tags default to the intersection operator.

        OPERATORS
        ------------------------------------------------------------------------
        & @ The intersection operator. This is the default operator. It returns
            the intersection of the current file set and the operator's tag.
            For example:

              $ bork find foo bar

            will find all files tagged with both foo and bar. This is the same
            as writing:

              $ bork find foo \\&bar
              $ bork find foo @bar

            Again, intersections are the default for all tags after the first.
            (Note: the escaped ampersand is important to prevent the shell from
            swallowing the ampersand and sending the process to the background.)

        +   The union operator. This simply creates a union of two tags' files.

        -   The difference operator. This operator takes all previous tags'
            files and remove's the difference tag's files from the set of found
            files. So, if the found files are <1, 2, 3, 4> and the difference
            tag's files are <1, 3>, the difference is <2, 4>, meaning you only
            get files not shared with the difference tag.

        EOS
      end

      Bork::Hub.default_hub.add_command_class self

      if __FILE__ == $0
        self.new.run ARGV
      end

    end # ListCommand

  end # Commands

end # Bork
