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

require 'bork/station'

module Bork

  module Commands

    class TagsCommand

      def self.command
        :tags
      end

      def run args, options = {}
        station = Bork::Station.new options[:station]

        station.tag_names.each {
          |name|
          puts name
        }
      end

      def help_string
        ''
      end

      Bork::Hub.default_hub.add_command_class self

      if __FILE__ == $0
        self.new.run ARGV
      end

    end # TagsCommand

  end # Commands

end # Bork
