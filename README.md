bork?
=======================================================================

bork is a relatively simple file-tagging utility. It takes any number 
of files as input, hashes them, stores them away in a central location 
called a station, and allows you to pull them back out using tag 
queries. Files can be re-tagged, tagged with many different tags, and 
so on. The only rule is that all files in bork must have tags. Tags or 
go home. Tags or pound sand, buddy. Tags, basically.

bork uses the filesystem as its database, so there are a few 
requirements for your filesystem must support:

* Hard links
* Filenames of 40 characters minimum

Fairly simple and I'm unaware of any filesystems commonly in use that 
do not support these things, but on the off chance that you're using 
FAT16 or something, be aware that bork hates you very, very much.


Install bork
-----------------------------------------------------------------------

Currently, bork can be installed using two relatively simple commands:

    $ gem build bork.gemspec
    $ gem install bork-<VERSION>.gem

After that, bork should be in your PATH and you can begin using it.


Use bork
-----------------------------------------------------------------------

### Create A Station

bork, again, is relatively simple. To begin using bork, navigate to the 
directory you'd like to use to store the bork station and init a 
station, like so:

    $ bork init

Henceforth, this will be your bork station. If you navigate outside of 
this directory, bork will cease to work. You can fix this by explicitly 
telling it the location of the station for every command. For example:

    $ bork --station path/to/station tags

Doing this instructs bork to begin searching for a station in the 
directory `path/to/station`. If you want to be more specific, you may 
also point it directly at the bork station, which in this case would be 
`path/to/station/.bork`.


### Add Files

Let's assume your bork station already has some files in it that you'd 
like bork to index: files 'foo', 'bar', and 'a_tree'. All three are 
different. _This is important._ Identical files by different names are 
the same thing to bork, so you really only index one name for that 
file. You'd like to add all these files to station and tag them all as 
being 'old-hat'. Well, just go ahead and use `bork add`:

    $ bork add foo bar a_tree -t old-hat

This will add the files to the bork station and all of them will be 
tagged as 'old-hat'.  Now let's say you like that tag, but you'd also 
like to tag 'a_tree' as 'wooden' and 'brownish'. Alright, the files are 
still there, just do another add:

    $ bork add a_tree -T wooden brownish

First, bork already has 'a_tree' indexed, so it will simply add the 
tags 'wooden' and 'brownish' to 'a_tree'. Next, let's draw your 
attention to the `-T`. Previously, we used `-t` to specify a single 
tag. `-T` is special: everything after it is a tag. Always. It swallows 
everything after it. This is useful if you're in the habit of listing 
all of your files and then all of your tags.


### Remove Tags

Now let's say you've changed your mind, 'a_tree' isn't actually 
'brownish'. It's probably more nonexistent and therefore invisible. So, 
you want to remove the 'brownish' tag from it. Just use `bork rm`:

    $ bork rm a_tree -t brownish

Doing this will look up 'a_tree' under the 'brownish' tag and, if it's 
in there, bork will remove 'a_tree' from the 'brownish' tag. The same 
options as `bork add` apply here as well: `-t` is a single tag, `-T` is 
many tags.


### Finding Files

The main point of using bork, however, is finding files later. Maybe 
you've used bork to tag all the reference photos you use while painting 
and now you'd like to look up all files tagged with 'meat'. This is 
easy, but requires some notice: bork places found files in the current 
working directory. If you want to check out files, it's best to do so 
in a clean, empty directory. With that in mind, we'll use `bork find` 
to grab all 'meat' files:

    $ mkdir meat-space
    $ cd meat-space
    $ bork find meat

bork will then place all files under the 'meat' tag in your current 
working directory. So, 'giblets.png', 'bacon.jpg', and 
'dancing-fat-man.mov' will all be placed in the 'meat-space' directory.

But it's not very useful if you can only search for invidual tags -- 
what good are the meatfiles if they're not also tagged with 'salsa'? 
So, let's get all files tagged with 'meat' and 'salsa'.

    $ bork find meat salsa

This will clear away previously found files and place only the meaty 
salsa pictures in 'meat-space'. By default, any additional tags will 
create an intersection: files found from the tags on the left will be 
intersected with additional tags. This operation can be made explicit 
by prefixing the tag with an ampersand, such as `&salsa`, but shells 
don't like this, so it's also the default operator. But there are other 
operators.

Since you're getting somewhere with your inspirational pictures, or at 
least you have a lot of meat pictures, this is good, but it's not 
great. Let's say you'd also like to have baby pictures in meat-space 
along with the meaty salsa. That's fine, everyone needs babies 
alongside food:

    $ bork find meat salsa +baby

So now you've got the baby pictures in there. The `+` operator is 
simple, it produces a union of previous tags' files and the new tag's 
files. But much to your dismay, your neighbor's "baby" picture is in 
there. I don't know why you have a photo of your neighbor's dog, but we 
both agree it's hairless and ugly. So, let's remove that:

    $ bork find meat salsa +baby "-the neighbor's ugly dog"

You thankfully had the foresight to tag your neighbor's ugly dog with 
the `your neighbor's ugly dog` tag. The important point here is that 
you can have spaces in your tags. You can have whatever your filesystem 
supports in your tags, really, but the other important point is the `-` 
operator, which produces a difference of all previous files and the 
current tag. That means that any file that is part of the difference 
tag is removed from the results.

To summarize, `bork find` tags at least one tag. The first tag is the 
base set of files you get to operate on. Subsequent tags may have the 
following operators applied to them:

* `&` → The intersection operator. This is the default and does not 
need to  be explicitly specified for tags. It also doesn't play nice 
with shells. There is one exception here, however: the first tag is a 
union. This is because `bork find` starts with the empty set and adds 
files to it. As such, an intersection of the empty set and any other 
tag is the empty set.
* `+` → The union operator. Creates a union of the previous files and 
the next tag's files.
* `-` → The difference operator. Takes all the previous files and 
removes this tag's files from the results.

`bork find` queries are not advanced, they are simply handled left to 
right. You cannot wrap tags in parentheses to do complex things, so 
keep that in mind. So, to break it down really quickly, given a query 
of `foo +bar -baz fabio`:

1. `foo` → All files tagged 'foo' are added to the results.
2. `+bar` → All files tagged 'baz' are added to the results.
3. `-baz` → Files tagged baz are removed from the results.
4. `fabio` → Files not in fabio are removed from the results.

So, it's simple, just don't over-think it.


### Other Things

For other commands, you can check `bork help` and see a listing of 
regular commands. If you require eadditional help, you can use `bork 
help <command>`, where you fill in the name of a command you want more 
information on.


License
-----------------------------------------------------------------------

bork is licensed under the GPLv3:

    bork is copyright (c) 2012 Noel R. Cower.
   
    This file is part of bork.
   
    bork is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
   
    bork is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
   
    You should have received a copy of the GNU General Public License
    along with bork.  If not, see <http://www.gnu.org/licenses/>.

For the full license, refer to the COPYING document that should have
accompanied bork. If you did not receive a document with the GPLv3 in
it, you may view it at the link in the above license header. If you
would like to discuss this choice, you may want to send an email to
<ncower@gmail.com>.
