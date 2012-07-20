#!/usr/bin/env ruby -w

require 'bork'
require 'bork/hub'

module Bork

  class VersionCommand

    def self.command
      :version
    end

    def run args, options = {}
      puts Bork.version
    end

    def help_string
      <<-EOS.gsub(/^ {6}/, '')
      bork version

      Displays the current version of bork.
      EOS
    end

    Bork::Hub.default_hub.add_command_class self

  end

end

if __FILE__ == $0
  Bork::VersionCommand.new.run ARGV
end
