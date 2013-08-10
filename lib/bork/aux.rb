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

require 'digest/sha1'
require 'pathname'

class Dir
  def empty?
    dot_regex = Bork.dot_dir_regex
    entries.reject { |e| e =~ dot_regex }.length == 0
  end

  def self.empty? file_name
    open(file_name) { |dir| dir.empty? }
  end
end

module Bork
  # used by version
  @@DOT_DIR_REGEX = /^\./

  # used by extract_file_tag_arguments
  @@PRIVATE_FILE_REGEX = %r((^|/)\.(?!=$|/))

  def self.dot_dir_regex
    @@DOT_DIR_REGEX
  end

  def self.bork_exec
    File.dirname __FILE__
  end

  def self.hash_file filepath
    contents = File.open(filepath, 'r') { |io| io.read }
    Digest::SHA1.hexdigest(contents).downcase!
  end

  # Takes two absolute paths and produces a path to target relative to source
  def self.relative_path source, target
    source_path = Pathname.new source
    target_path = Pathname.new target

    unless source_path.absolute? && target_path.absolute?
      raise "bork: Paths must be absolute"
    end

    target_path.relative_path_from(source_path).to_s
  end

  # Extracts files and tags from the arguments and returns arrays of both.
  def self.extract_file_tag_arguments args
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

    files = files.each_with_object([]) {
      |file_path, results|

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
        raise "No such file '#{file_path}'."
      end

      results
    }

    return files, tags
  end

end
