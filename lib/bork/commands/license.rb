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

module Bork

  class LicenseCommand

    def self.command
      :license
    end

    def run args, options = {}
      begin
        spec = Gem::Specification.find_by_name 'bork'
        copying_path = "#{spec.gem_dir}/COPYING"
        if File.exists? copying_path
          if ENV.include?('TERM') && ! ENV['TERM'].empty? && ENV.include?('PAGER') && ! ENV['PAGER'].empty?
            pager = ENV['PAGER'] || 'less'
            exec pager, copying_path
          else
            puts File.open(copying_path, 'r') {
              |io|
              io.read
            }
          end
        else
          raise 'COPYING not found.'
        end
      rescue
        puts <<-EOS.gsub(/^ {10}/, '')
          bork-license: Unable to locate license text. Please refer to
          <http://www.gnu.org/licenses/> to see a copy of the GPLv3.
        EOS
        exit 1
      end
    end

    def help_string
      <<-EOS.gsub(/^ {6}/, '')
      bork-license

      Displays the license under which bork is made available to you.
      EOS
    end

    Bork::Hub.default_hub.add_command_class self

  end # LicenseCommand

end # Bork
