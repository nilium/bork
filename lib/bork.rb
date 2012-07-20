module Bork

  @@VERSION = '1.0.0'

  def self.version
    @@VERSION
  end

  autoload :Hub, 'bork/hub'
  autoload :Station, 'bork/station'

  def self.load_commands
    Dir.foreach("#{File.dirname __FILE__}/bork/commands") {
      |entry|
      next if entry.start_with? '.'
      require "bork/commands/#{entry}"
    }
  end

end
