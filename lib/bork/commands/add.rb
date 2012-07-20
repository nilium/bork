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

  class AddCommand

    @@PRIVATE_FILE_REGEX = %r((^|/)\.(?!=$|/))

    def self.command
      :add
    end

    def error_no_file file
      puts "bork-add: No such file '#{file}'."
      exit 1
    end

    # Extracts files and tags from the arguments and returns arrays of both.
    def extract_arguments args
      tags = []
      files = []

      # can be :any, :tag, or :tags
      # :any -> check the argument. If not a valid option, it's a file.
      # :tag -> this argument is a tag.
      # :tags -> all arguments hereinafter are tags.
      arg_state = :any
      args.each {
        |arg|
        case arg_state
        when :any
          case arg
          when '-t', '--tag' then arg_state = :tag
          when '-T', '--tags' then arg_state = :tags
          else files << arg
          end
        when :tag
          tags << arg
          arg_state = :any
        when :tags
          tags << arg
        end
      }

      files = files.reduce([]) {
        |results, file_path|

        if File.exists? file_path
          if File.directory? file_path
            results += Dir.glob("#{file_path}/**/*").reject {
              |entry|
              entry =~ @@PRIVATE_FILE_REGEX || File.directory?(entry)
            }
          else
            results << file_path
          end
        else
          error_no_file file_path
        end

        results
      }

      return files, tags
    end

    def run args, options = {}
      files, tags = extract_arguments args
      station = Bork::Station.new options[:station]

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

  end # AddCommand

end # Bork

if __FILE__ == $0
  Bork::AddCommand.new.run ARGV, {}
end
