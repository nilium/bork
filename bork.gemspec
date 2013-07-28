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

require 'rake'

Gem::Specification.new { |spec|
  spec.name        = 'bork'
  spec.version     = '1.0.1'
  spec.date        = '2013-07-28'
  spec.summary     = 'bork file tagging utility'
  spec.description = <<-EOS.gsub(/^ {4}/, '')
    bork is a simple file-tagging utility for people who really like the word
    'bork.' Also doubles as an acronym for 'big ostriches ride kings' or whatever
    other odd acronym you can imagine.
  EOS
  spec.authors     = ['Noel R. Cower']
  spec.licenses    = ['GPLv3']
  spec.email       = 'ncower@gmail.com'
  spec.homepage    = 'http://nilium.github.com/bork/'
  spec.executables << 'bork'
  spec.files = FileList['lib/**/*.rb',
                        'bin/*',
                        '[A-Z]*',
                        'test/**/*'].to_a
}
