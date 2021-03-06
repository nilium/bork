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

  @@VERSION = '1.0.0'

  def self.version
    @@VERSION
  end

  def self.load_commands
    Dir.foreach(File.expand_path("../bork/commands", __FILE__)) {
      |entry|
      next if entry.start_with? '.'
      require "bork/commands/#{entry.chomp '.rb'}"
    }
  end

end

require 'bork/hub'
require 'bork/station'
