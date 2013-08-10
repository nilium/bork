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

module Bork

  class Station

    @@OP_REGEX = /^([&@+\-])?(hash:)?(.+)$/
    @@BORK_DIRECTORY = '.bork'

    def self.station_directory
      @@BORK_DIRECTORY
    end

    # If no search directory is provided, it looks for a Bork station in the
    # current directory.
    def initialize search_dir = nil
      station_dir = nil

      @tag_map = nil
      @file_hashes = nil
      @hash_path_map = nil

      if search_dir.kind_of? Station
        station_dir = search_dir.to_s

        @tag_map = search_dir.tag_hash_map
        @file_hashes = search_dir.file_hashes
        @hash_path_map = search_dir.hash_path_map
      else
        station_dir = dir = if search_dir
          File.expand_path search_dir
        else
          search_dir = 'the current directory'
          Dir.pwd
        end

        raise "No search directory provided." unless dir

        stdir = Station.station_directory

        unless File.basename(dir) == stdir && File.directory?(dir)
          until File.directory?((station_dir = "#{dir}/#{stdir}"))
            raise "No station found in or above #{search_dir}." if dir == '/'

            dir = File.dirname dir
          end
        end
      end

      @station_path = station_dir.freeze
      @indices_root = "#{station_dir}/index".freeze
      @tags_root = "#{station_dir}/tags".freeze

      if ! File.directory? @indices_root
        raise "Station index doesn't exist (or isn't a directory)."
      elsif ! File.directory? @tags_root
        raise "Station tag set doesn't exist (or isn't a directory)."
      end
    end

    def station_home
      @station_home ||= File.dirname self.station_path
    end

    def station_path
      @station_path
    end

    def indices_root
      @indices_root
    end

    def tags_root
      @tags_root
    end

    def index_for_hash hash
      "#{self.indices_root}/#{hash[0..1]}/#{hash[2..-1]}"
    end

    def hashes_for_tag tag
      tag_dir = "#{self.tags_root}/#{tag}"

      return [] unless File.directory? tag_dir

      Dir.foreach(tag_dir).reject {
        |entry|
        entry.start_with? '.'
      }
    end

    def tag_names
      dot_regex = Bork.dot_dir_regex
      Dir.foreach(self.tags_root).reject {
        |e| dot_regex === e
      }
    end

    def tag_hash_map
      return @tag_map.clone if @tag_map

      tags = {}

      tag_dir = self.tags_root
      dot_regex = Bork.dot_dir_regex

      Dir.foreach(tag_dir) {
        |tag|
        next if dot_regex === tag

        hashes = Dir.foreach("#{tag_dir}/#{tag}").reject { |h| dot_regex === h }

        tags[tag] = hashes
      }

      @tag_map = tags
    end

    def tag_hashes tag
      return @tag_map[tag].clone if @tag_map && @tag_map.include?(tag)

      (@tag_map[tag] = Dir.foreach("#{self.tags_root}/#{tag}").reject {
              |entry|
              entry.start_with? '.'
            }).clone
    end

    def file_for_hash hash
      hash_map = (@hash_path_map = @hash_path_map || {})
      file_path = hash_map[hash]
      return file_path unless file_path.nil?

      metadata = read_file_metadata hash

      return (hash_map[hash] = metadata['path'])
    end

    def sort_hashes hashes
      file_map = hashes.each_with_object(Hash.new) {
        |file_hash, map|
        index_path = index_for_hash file_hash
        map[file_hash] = index_path
        map
      }

      hashes.sort {
        |left, right|
        file_map[left] <=> file_map[right]
      }
    end

    def file_hashes
      return @file_hashes if @file_hashes

      dot_regex = Bork.dot_dir_regex
      index_dir = self.indices_root

      hashes = Dir.foreach(index_dir).each_with_object([]) {
        |bucket, container|
        next if bucket.start_with? '.'
        unless dot_regex === bucket
          tails = Dir.foreach("#{index_dir}/#{bucket}").reject {
            |h|
            dot_regex === h || h.end_with?('.meta')
          }
          container.concat tails.map { |h| "#{bucket}#{h}" }
        end
      }

      (@file_hashes = hashes).clone
    end

    # === find_hashes
    # tag_ops is an array of strings containing tags as strings. The tag strings
    # may optionally contain operator prefixes (&, +, and -). If no operator is
    # specified, the default is &, the intersection operator.
    #
    # === Tag Operators:
    # [&] Intersection (default after the first tag). Results in an intersection
    #     of the results of previous operations and the right-hand tag.
    # [+] Union (first tag is a union unless specified otherwise). Results in a
    #     union of the results of the previous ops and the right-hand tag.
    # [-] Difference. Gets the difference of the previous ops and the right-hand
    #     tag.
    def find_tagged_hashes tag_ops
      # using ruby for set operations
      first_match = true

      tag_ops.inject(Set.new) {
        |hash_set, arg|

        op_match = @@OP_REGEX.match(arg)
        op = op_match[1] || (first_match ? '+' : '&')
        tag = op_match[3]

        first_match = false

        hashes = hashes_for_tag tag

        case op
        when '&' then hash_set & hashes
        when '+' then hash_set | hashes
        when '-' then hash_set - hashes
        else
          raise "Invalid tag operator #{op}"
        end
      }.to_a
    end

    # Creates a bucket for the given hash and returns the path to the bucket.
    # If the bucket path already exists, nothing changes.
    def ensure_bucket_for_hash! hash, options = {}
      verbose = options[:verbose]
      noop = options[:noop]

      bucket = hash[0..1]
      bucket_dir = "#{self.indices_root}/#{bucket}"

      if ! File.directory? bucket_dir
        puts "mkdir '#{bucket_dir}'" if verbose
        Dir.mkdir bucket_dir unless noop
      elsif verbose
        puts "'#{bucket_dir}' already exists."
      end

      bucket_dir
    end

    def ensure_tag_dir! tag, options
      verbose = options[:verbose]
      noop = options[:noop]

      tag_dir = "#{self.tags_root}/#{tag}"

      if ! File.directory? tag_dir
        puts "mkdir '#{tag_dir}'" if verbose
        Dir.mkdir tag_dir unless noop
      elsif verbose
        puts "'#{tag_dir}' already exists."
      end

      tag_dir
    end

    # Adds a file to the index. Returns the hash for the file.
    def index_file! file, options
      raise "#{file} is not a regular file" unless File.file? file

      verbose = options[:verbose]
      noop = options[:noop]

      hash = Bork.hash_file file
      ensure_bucket_for_hash! hash, options
      index_path = index_for_hash hash

      puts "Indexing '#{file}' (#{hash})." if verbose

      if ! File.exists? index_path
        unless noop
          File.link file, index_path
          File.open("#{index_path}.meta", 'w') {
            |io|
            io.write gen_file_metadata file
          }
        end

        if verbose
          puts "ln '#{file}' '#{index_path}'"
          puts "Writing metadata to '#{index_path}.meta'."
        end

        if @file_hashes && ! noop
          @files_hashes << hash
        end

        puts "Indexed '#{file}' as #{hash}." if verbose
      elsif verbose
        puts "'#{file}' already indexed."
      end

      hash
    end

    def tag_hash! tags, hash, options
      verbose = options[:verbose]
      noop = options[:noop]

      tag_files = tags.map {
        |tag|
        "#{ensure_tag_dir! tag, options}/#{hash}"
      }.reject {
        |file_path|
        File.exists? file_path
      }

      unless tag_files.empty?
        FileUtils.touch tag_files, :verbose => verbose, :noop => noop

        if @tag_map
          tag_files.each {
            |path|
            hash = File.basename path
            tag = File.basename File.dirname path
            @tag_map[tag] << hash
          }
        end
      end
    end

    # Checks that all hashes are still correct and updates them if they aren't.
    def update! options = {}
      verbose = options[:verbose]
      noop = options[:noop]

      changed_hashes = {}

      puts "Updating indices." if verbose

      file_hashes.each {
        |hash|

        file_index = index_for_hash hash
        cur_hash = Bork.hash_file file_index

        if hash != cur_hash
          ensure_bucket_for_hash! cur_hash, options
          cur_index = index_for_hash cur_hash

          changed_hashes[hash] = cur_hash

          if ! File.exists? cur_index
            FileUtils.mv file_index,
                         cur_index,
                         :verbose => verbose, :noop => noop

            FileUtils.mv "#{file_index}.meta",
                         "#{cur_index}.meta",
                         :verbose => verbose, :noop => noop
          else
            FileUtils.rm file_index, :verbose => verbose, :noop => noop
            FileUtils.rm "#{file_index}.meta", :verbose => verbose, :noop => noop
          end

          old_bucket_path = File.dirname file_index
          if Dir.empty?(old_bucket_path) && ! noop
            puts "Unlinking dir '#{old_bucket_path}'." if verbose
            Dir.unlink old_bucket_path unless noop
          end
        end
      }

      tags_dir = self.tags_root
      tags = tag_hash_map

      puts "Updating tags." if verbose

      tags.each {
        |tag, hashes|

        puts "Updating '#{tag}' tag." if verbose

        tag_path = "#{tags_dir}/#{tag}"

        changed_hashes.each {
          |old_hash, new_hash|

          if hashes.include? old_hash
            FileUtils.mv "#{tag_path}/#{old_hash}",
                         "#{tag_path}/#{new_hash}",
                         :verbose => verbose, :noop => noop
          end
        }

        Dir.unlink tag_path if hashes.empty? && ! noop
      }

      invalidate_tag_cache
      invalidate_hash_cache

      if changed_hashes.empty?
        puts "bork: No indices updated."
      else
        puts "bork: Updated #{changed_hashes.length} indices."
        puts "bork: Dry run finished." if noop
      end
    end

    def remove_tags_from_hash! tags, hash, options = {}
      noop = options[:noop]
      verbose = options[:verbose]

      tags_path = self.tags_root

      tags.each {
        |tag|
        tag_dir = "#{tags_path}/#{tag}"

        if File.directory? tag_dir
          tag_file = "#{tag_dir}/#{hash}"

          if File.exists? tag_file
            puts "Unlinking file '#{tag_file}'." if verbose
            File.unlink tag_file unless noop
          elsif verbose
            puts "#{hash} not tagged with '#{tag}'."
          end

          if Dir.empty? tag_dir
            puts "Unlinking dir '#{tag_dir}'." if verbose
            Dir.unlink tag_dir unless noop
          end
        end
      }
    end

    def to_s
      station_path
    end


    protected

    def hash_path_map
      @hash_path_map
    end


    private

    def gen_file_metadata file
      file = File.expand_path file
      JSON[{
          'path' => Bork.relative_path(self.station_home, file)
        }]
    end

    def read_file_metadata hash
      metapath = "#{index_for_hash hash}.meta"
      meta_contents = File.open(metapath, 'r') { |io| io.read }
      JSON[meta_contents]
    end

    def invalidate_tag_cache
      @tag_map = nil
    end

    def invalidate_hash_cache
      @file_hashes = nil
    end

  end # Station

end # Bork
