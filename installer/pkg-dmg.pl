#!/usr/bin/perl
# ***** BEGIN LICENSE BLOCK *****
# Version: MPL 1.1/GPL 2.0/LGPL 2.1
#
# The contents of this file are subject to the Mozilla Public License Version
# 1.1 (the "License"); you may not use this file except in compliance with
# the License. You may obtain a copy of the License at
# http://www.mozilla.org/MPL/
#
# Software distributed under the License is distributed on an "AS IS" basis,
# WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
# for the specific language governing rights and limitations under the
# License.
#
# The Original Code is pkg-dmg, a Mac OS X disk image (.dmg) packager
#
# The Initial Developer of the Original Code is
# Mark Mentovai <mark@moxienet.com>.
# Portions created by the Initial Developer are Copyright (C) 2005
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#
# Alternatively, the contents of this file may be used under the terms of
# either the GNU General Public License Version 2 or later (the "GPL"), or
# the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
# in which case the provisions of the GPL or the LGPL are applicable instead
# of those above. If you wish to allow use of your version of this file only
# under the terms of either the GPL or the LGPL, and not to allow others to
# use your version of this file under the terms of the MPL, indicate your
# decision by deleting the provisions above and replace them with the notice
# and other provisions required by the GPL or the LGPL. If you do not delete
# the provisions above, a recipient may use your version of this file under
# the terms of any one of the MPL, the GPL or the LGPL.
#
# ***** END LICENSE BLOCK *****

use strict;
use warnings;

=pod

=head1 NAME

B<pkg-dmg> - Mac OS X disk image (.dmg) packager

=head1 SYNOPSIS

B<pkg-dmg>
B<--source> I<source-folder>
B<--target> I<target-image>
[B<--format> I<format>]
[B<--volname> I<volume-name>]
[B<--tempdir> I<temp-dir>]
[B<--mkdir> I<directory>]
[B<--copy> I<source>[:I<dest>]]
[B<--symlink> I<source>[:I<dest>]]
[B<--license> I<file>]
[B<--resource> I<file>]
[B<--icon> I<icns-file>]
[B<--attribute> I<a>:I<file>[:I<file>...]
[B<--idme>]
[B<--sourcefile>]
[B<--verbosity> I<level>]
[B<--dry-run>]

=head1 DESCRIPTION

I<pkg-dmg> takes a directory identified by I<source-folder> and transforms
it into a disk image stored as I<target-image>.  The disk image will
occupy the least space possible for its format, or the least space that the
authors have been able to figure out how to achieve.

=head1 OPTIONS

=over 5

==item B<--source> I<source-folder>

Identifies the directory that will be packaged up.  This directory is not
touched, a copy will be made in a temporary directory for staging purposes.
See B<--tempdir>.

==item B<--target> I<target-image>

The disk image to create.  If it exists and is not in use, it will be
overwritten.  If I<target-image> already contains a suitable extension,
it will be used unmodified.  If no extension is present, or the extension
is incorrect for the selected format, the proper extension will be added.
See B<--format>.

==item B<--format> I<format>

The format to create the disk image in.  Valid values for I<format> are:
     - UDZO - zlib-compressed, read-only; extension I<.dmg>
     - UDBZ - bzip2-compressed, read-only; extension I<.dmg>;
              create and use on 10.4 ("Tiger") and later only
     - UDRW - read-write; extension I<.dmg>
     - UDSP - read-write, sparse; extension I<.sparseimage>

UDZO is the default format.

See L<hdiutil(1)> for a description of these formats.

=item B<--volname> I<volume-name>

The name of the volume in the disk image.  If not specified, I<volume-name>
defaults to the name of the source directory from B<--source>.

=item B<--tempdir> I<temp-dir>

A temporary directory to stage intermediate files in.  I<temp-dir> must
have enough space available to accommodate twice the size of the files
being packaged.  If not specified, defaults to the same directory that
the I<target-image> is to be placed in.  B<pkg-dmg> will remove any
temporary files it places in I<temp-dir>.

=item B<--mkdir> I<directory>

Specifies a directory that should be created in the disk image.
I<directory> and any ancestor directories will be created.  This is
useful in conjunction with B<--copy>, when copying files to directories
that may not exist in I<source-folder>.  B<--mkdir> may appear multiple
times.

=item B<--copy> I<source>[:I<dest>]

Additional files to copy into the disk image.  If I<dest> is
specified, I<source> is copied to the location I<dest> identifies,
otherwise, I<source> is copied to the root of the new volume.  B<--copy>
provides a way to package up a I<source-folder> by adding files to it
without modifying the original I<source-folder>.  B<--copy> may appear
multiple times.

This option is useful for adding .DS_Store files and window backgrounds
to disk images.

=item B<--symlink> I<source>[:I<dest>]

Like B<--copy>, but allows symlinks to point out of the volume. Empty symlink
destinations are interpreted as "like the source path, but inside the dmg"

This option is useful for adding symlinks to external resources,
e.g. to /Applications.

=item B<--license> I<file>

A plain text file containing a license agreement to be displayed before
the disk image is mounted.  English is the only supported language.  To
include license agreements in other languages, in multiple languages,
or to use formatted text, prepare a resource and use L<--resource>.

=item B<--resource> I<file>

A resource file to merge into I<target-image>.  If I<format> is UDZO or
UDBZ, the disk image will be flattened to a single-fork file that contains
the resource but may be freely transferred without any special encodings.
I<file> must be in a format suitable for L<Rez(1)>.  See L<Rez(1)> for a
description of the format, and L<hdiutil(1)> for a discussion on flattened
disk images.  B<--resource> may appear multiple times.

This option is useful for adding license agreements and other messages
to disk images.

=item B<--icon> I<icns-file>

Specifies an I<icns> file that will be used as the icon for the root of
the volume.  This file will be copied to the new volume and the custom
icon attribute will be set on the root folder.

=item B<--attribute> I<a>:I<file>[:I<file>...]

Sets the attributes of I<file> to the attribute list in I<a>.  See
L<SetFile(1)>

=item B<--idme>

Enable IDME to make the disk image "Internet-enabled."  The first time
the image is mounted, if IDME processing is enabled on the system, the
contents of the image will be copied out of the image and the image will
be placed in the trash with IDME disabled.

=item B<--sourcefile>

If this option is present, I<source-folder> is treated as a file, and is
placed as a file within the volume's root folder.  Without this option,
I<source-folder> is treated as the volume root itself.

=item B<--verbosity> I<level>

Adjusts the level of loudness of B<pkg-dmg>.  The possible values for
I<level> are:
     0 - Only error messages are displayed.
     1 - Print error messages and command invocations.
     2 - Print everything, including command output.

The default I<level> is 2.

=item B<--dry-run>

When specified, the commands that would be executed are printed, without
actually executing them.  When commands depend on the output of previous
commands, dummy values are displayed.

=back

=head1 NON-OPTIONS

=over 5

=item

Resource forks aren't copied.

=item

The root folder of the created volume is designated as the folder
to open when the volume is mounted.  See L<bless(8)>.

=item

All files in the volume are set to be world-readable, only writable
by the owner, and world-executable when appropriate.  All other
permissions bits are cleared.

=item

When possible, disk images are created without any partition tables.  This
is what L<hdiutil(1)> refers to as I<-layout NONE>, and saves a handful of
kilobytes.  The alternative, I<SPUD>, contains a partition table that
is not terribly handy on disk images that are not intended to represent any
physical disk.

=item

Read-write images are created with journaling off.  Any read-write image
created by this tool is expected to be transient, and the goal of this tool
is to create images which consume a minimum of space.

=back

=head1 EXAMPLE

pkg-dmg --source /Applications/DeerPark.app --target ~/DeerPark.dmg
  --sourcefile --volname DeerPark --icon ~/DeerPark.icns
  --mkdir /.background
  --copy DeerParkBackground.png:/.background/background.png
  --copy DeerParkDSStore:/.DS_Store
  --symlink /Applications:"/Drag to here"

=head1 REQUIREMENTS

I<pkg-dmg> has been tested with Mac OS X releases 10.2 ("Jaguar")
through 10.4 ("Tiger").  Certain adjustments to behavior are made
depending on the host system's release.  Mac OS X 10.3 ("Panther") or
later are recommended.

=head1 LICENSE

MPL 1.1/GPL 2.0/LGPL 2.1.  Your choice.

=head1 AUTHOR

Mark Mentovai

=head1 SEE ALSO

L<bless(8)>, L<diskutil(8)>, L<hdid(8)>, L<hdiutil(1)>, L<Rez(1)>,
L<rsync(1)>, L<SetFile(1)>

=cut

use Fcntl;
use POSIX;
use Getopt::Long;

sub argumentEscape(@);
sub cleanupDie($);
sub command(@);
sub commandInternal($@);
sub commandInternalVerbosity($$@);
sub commandOutput(@);
sub commandOutputVerbosity($@);
sub commandVerbosity($@);
sub copyFiles($@);
sub diskImageMaker($$$$$$$$);
sub giveExtension($$);
sub hdidMountImage($@);
sub isFormatCompressed($);
sub licenseMaker($$);
sub pathSplit($);
sub setAttributes($@);
sub trapSignal($);
sub usage();

# Variables used as globals
my(@gCleanup, %gConfig, $gDarwinMajor, $gDryRun, $gVerbosity);

# Use the commands by name if they're expected to be in the user's
# $PATH (/bin:/sbin:/usr/bin:/usr/sbin).  Otherwise, go by absolute
# path.  These may be overridden with --config.
%gConfig = ('cmd_bless'          => 'bless',
            'cmd_chmod'          => 'chmod',
            'cmd_diskutil'       => 'diskutil',
            'cmd_du'             => 'du',
            'cmd_hdid'           => 'hdid',
            'cmd_hdiutil'        => 'hdiutil',
            'cmd_mkdir'          => 'mkdir',
            'cmd_mktemp'         => 'mktemp',
            'cmd_Rez'            => '/Applications/Xcode.app/Contents/Developer/Tools/Rez',
            'cmd_rm'             => 'rm',
            'cmd_rsync'          => 'rsync',
            'cmd_SetFile'        => '/Applications/Xcode.app/Contents/Developer/Tools/SetFile',

            # create_directly indicates whether hdiutil create supports
            # -srcfolder and -srcdevice.  It does on >= 10.3 (Panther).
            # This is fixed up for earlier systems below.  If false,
            # hdiutil create is used to create empty disk images that
            # are manually filled.
            'create_directly'    => 1,

            # If hdiutil attach -mountpoint exists, use it to avoid
            # mounting disk images in the default /Volumes.  This reduces
            # the likelihood that someone will notice a mounted image and
            # interfere with it.  Only available on >= 10.3 (Panther),
            # fixed up for earlier systems below.
            #
            # This is presently turned off for all systems, because there
            # is an infrequent synchronization problem during ejection.
            # diskutil eject might return before the image is actually
            # unmounted.  If pkg-dmg then attempts to clean up its
            # temporary directory, it could remove items from a read-write
            # disk image or attempt to remove items from a read-only disk
            # image (or a read-only item from a read-write image) and fail,
            # causing pkg-dmg to abort.  This problem is experienced
            # under Tiger, which appears to eject asynchronously where
            # previous systems treated it as a synchronous operation.
            # Using hdiutil attach -mountpoint didn't always keep images
            # from showing up on the desktop anyway.
            'hdiutil_mountpoint' => 0,

            # hdiutil makehybrid results in optimized disk images that
            # consume less space and mount more quickly.  Use it when
            # it's available, but that's only on >= 10.3 (Panther).
            # If false, hdiutil create is used instead.  Fixed up for
            # earlier systems below.
            'makehybrid'         => 1,

            # hdiutil create doesn't allow specifying a folder to open
            # at volume mount time, so those images are mounted and
            # their root folders made holy with bless -openfolder.  But
            # only on >= 10.3 (Panther).  Earlier systems are out of luck.
            # Even on Panther, bless refuses to run unless root.
            # Fixed up below.
            'openfolder_bless'   => 1,

            # It's possible to save a few more kilobytes by including the
            # partition only without any partition table in the image.
            # This is a good idea on any system, so turn this option off.
            #
            # Except it's buggy.  "-layout NONE" seems to be creating
            # disk images with more data than just the partition table
            # stripped out.  You might wind up losing the end of the
            # filesystem - the last file (or several) might be incomplete.
            'partition_table'    => 1,

            # To create a partition table-less image from something
            # created by makehybrid, the hybrid image needs to be
            # mounted and a new image made from the device associated
            # with the relevant partition.  This requires >= 10.4
            # (Tiger), presumably because earlier systems have
            # problems creating images from devices themselves attached
            # to images.  If this is false, makehybrid images will
            # have partition tables, regardless of the partition_table
            # setting.  Fixed up for earlier systems below.
            'recursive_access'   => 1);

# --verbosity
$gVerbosity = 2;

# --dry-run
$gDryRun = 0;

# %gConfig fix-ups based on features and bugs present in certain releases.
my($ignore, $uname_r, $uname_s);
($uname_s, $ignore, $uname_r, $ignore, $ignore) = POSIX::uname();
if($uname_s eq 'Darwin') {
  ($gDarwinMajor, $ignore) = split(/\./, $uname_r, 2);

  # $major is the Darwin major release, which for our purposes, is 4 higher
  # than the interesting digit in a Mac OS X release.
  if($gDarwinMajor <= 6) {
    # <= 10.2 (Jaguar)
    # hdiutil create does not support -srcfolder or -srcdevice
    $gConfig{'create_directly'} = 0;
    # hdiutil attach does not support -mountpoint
    $gConfig{'hdiutil_mountpoint'} = 0;
    # hdiutil mkhybrid does not exist
    $gConfig{'makehybrid'} = 0;
  }
  if($gDarwinMajor <= 7) {
    # <= 10.3 (Panther)
    # Can't mount a disk image and then make a disk image from the device
    $gConfig{'recursive_access'} = 0;
    # bless does not support -openfolder on 10.2 (Jaguar) and must run
    # as root under 10.3 (Panther)
    $gConfig{'openfolder_bless'} = 0;
  }
}
else {
  # If it's not Mac OS X, just assume all of those good features are
  # available.  They're not, but things will fail long before they
  # have a chance to make a difference.
  #
  # Now, if someone wanted to document some of these private formats...
  print STDERR ($0.": warning, not running on Mac OS X, ".
   "this could be interesting.\n");
}

# Non-global variables used in Getopt
my(@attributes, @copyFiles, @createSymlinks, $iconFile, $idme, $licenseFile,
 @makeDirs, $outputFormat, @resourceFiles, $sourceFile, $sourceFolder,
 $targetImage, $tempDir, $volumeName);

# --format
$outputFormat = 'UDZO';

# --idme
$idme = 0;

# --sourcefile
$sourceFile = 0;

# Leaving this might screw up the Apple tools.
delete $ENV{'NEXT_ROOT'};

# This script can get pretty messy, so trap a few signals.
$SIG{'INT'} = \&trapSignal;
$SIG{'HUP'} = \&trapSignal;
$SIG{'TERM'} = \&trapSignal;

Getopt::Long::Configure('pass_through');
GetOptions('source=s'    => \$sourceFolder,
           'target=s'    => \$targetImage,
           'volname=s'   => \$volumeName,
           'format=s'    => \$outputFormat,
           'tempdir=s'   => \$tempDir,
           'mkdir=s'     => \@makeDirs,
           'copy=s'      => \@copyFiles,
           'symlink=s'   => \@createSymlinks,
           'license=s'   => \$licenseFile,
           'resource=s'  => \@resourceFiles,
           'icon=s'      => \$iconFile,
           'attribute=s' => \@attributes,
           'idme'        => \$idme,
           'sourcefile'  => \$sourceFile,
           'verbosity=i' => \$gVerbosity,
           'dry-run'     => \$gDryRun,
           'config=s'    => \%gConfig); # "hidden" option not in usage()

if(@ARGV) {
  # All arguments are parsed by Getopt
  usage();
  exit(1);
}

if($gVerbosity<0 || $gVerbosity>2) {
  usage();
  exit(1);
}

if(!defined($sourceFolder) || $sourceFolder eq '' ||
 !defined($targetImage) || $targetImage eq '') {
  # --source and --target are required arguments
  usage();
  exit(1);
}

# Make sure $sourceFolder doesn't contain trailing slashes.  It messes with
# rsync.
while(substr($sourceFolder, -1) eq '/') {
  chop($sourceFolder);
}

if(!defined($volumeName)) {
  # Default volumeName is the name of the source directory.
  my(@components);
  @components = pathSplit($sourceFolder);
  $volumeName = pop(@components);
}

my(@tempDirComponents, $targetImageFilename);
@tempDirComponents = pathSplit($targetImage);
$targetImageFilename = pop(@tempDirComponents);

if(defined($tempDir)) {
  @tempDirComponents = pathSplit($tempDir);
}
else {
  # Default tempDir is the same directory as what is specified for
  # targetImage
  $tempDir = join('/', @tempDirComponents);
}

# Ensure that the path of the target image has a suitable extension.  If
# it didn't, hdiutil would add one, and we wouldn't be able to find the
# file.
#
# Note that $targetImageFilename is not being reset.  This is because it's
# used to build other names below, and we don't need to be adding all sorts
# of extra unnecessary extensions to the name.
my($originalTargetImage, $requiredExtension);
$originalTargetImage = $targetImage;
if($outputFormat eq 'UDSP') {
  $requiredExtension = '.sparseimage';
}
else {
  $requiredExtension = '.dmg';
}
$targetImage = giveExtension($originalTargetImage, $requiredExtension);

if($targetImage ne $originalTargetImage) {
  print STDERR ($0.": warning: target image extension is being added\n");
  print STDERR ('  The new filename is '.
   giveExtension($targetImageFilename,$requiredExtension)."\n");
}

# Make a temporary directory in $tempDir for our own nefarious purposes.
my(@output, $tempSubdir, $tempSubdirTemplate);
$tempSubdirTemplate=join('/', @tempDirComponents,
 'pkg-dmg.'.$$.'.XXXXXXXX');
if(!(@output = commandOutput($gConfig{'cmd_mktemp'}, '-d',
 $tempSubdirTemplate)) || $#output != 0) {
  cleanupDie('mktemp failed');
}

if($gDryRun) {
  (@output)=($tempSubdirTemplate);
}

($tempSubdir) = @output;

push(@gCleanup,
 sub {commandVerbosity(0, $gConfig{'cmd_rm'}, '-rf', $tempSubdir);});

my($tempMount, $tempRoot, @tempsToMake);
$tempRoot = $tempSubdir.'/stage';
$tempMount = $tempSubdir.'/mount';
push(@tempsToMake, $tempRoot);
if($gConfig{'hdiutil_mountpoint'}) {
  push(@tempsToMake, $tempMount);
}

if(command($gConfig{'cmd_mkdir'}, @tempsToMake) != 0) {
  cleanupDie('mkdir tempRoot/tempMount failed');
}

# This cleanup object is not strictly necessary, because $tempRoot is inside
# of $tempSubdir, but the rest of the script relies on this object being
# on the cleanup stack and expects to remove it.
push(@gCleanup,
 sub {commandVerbosity(0, $gConfig{'cmd_rm'}, '-rf', $tempRoot);});

# If $sourceFile is true, it means that $sourceFolder is to be treated as
# a file and placed as a file within the volume root, as opposed to being
# treated as the volume root itself.  rsync will do this by default, if no
# trailing '/' is present.  With a trailing '/', $sourceFolder becomes
# $tempRoot, instead of becoming an entry in $tempRoot.
if(command($gConfig{'cmd_rsync'}, '-a', '--copy-unsafe-links',
 $sourceFolder.($sourceFile?'':'/'),$tempRoot) != 0) {
  cleanupDie('rsync failed');
}

if(@makeDirs) {
  my($makeDir, @tempDirsToMake);
  foreach $makeDir (@makeDirs) {
    if($makeDir =~ /^\//) {
      push(@tempDirsToMake, $tempRoot.$makeDir);
    }
    else {
      push(@tempDirsToMake, $tempRoot.'/'.$makeDir);
    }
  }
  if(command($gConfig{'cmd_mkdir'}, '-p', @tempDirsToMake) != 0) {
    cleanupDie('mkdir failed');
  }
}

# copy files and/or create symlinks
copyFiles($tempRoot, 'copy', @copyFiles);
copyFiles($tempRoot, 'symlink', @createSymlinks);

if($gConfig{'create_directly'}) {
  # If create_directly is false, the contents will be rsynced into a
  # disk image and they would lose their attributes.
  setAttributes($tempRoot, @attributes);
}

if(defined($iconFile)) {
  if(command($gConfig{'cmd_rsync'}, '-a', '--copy-unsafe-links', $iconFile,
   $tempRoot.'/.VolumeIcon.icns') != 0) {
    cleanupDie('rsync failed for volume icon');
  }

  # It's pointless to set the attributes of the root when diskutil create
  # -srcfolder is being used.  In that case, the attributes will be set
  # later, after the image is already created.
  if(isFormatCompressed($outputFormat) &&
   (command($gConfig{'cmd_SetFile'}, '-a', 'C', $tempRoot) != 0)) {
    cleanupDie('SetFile failed');
  }
}

if(command($gConfig{'cmd_chmod'}, '-R', 'a+rX,a-st,u+w,go-w',
 $tempRoot) != 0) {
  cleanupDie('chmod failed');
}

my($unflattenable);
if(isFormatCompressed($outputFormat)) {
  $unflattenable = 1;
}
else {
  $unflattenable = 0;
}

diskImageMaker($tempRoot, $targetImage, $outputFormat, $volumeName,
 $tempSubdir, $tempMount, $targetImageFilename, defined($iconFile));

if(defined($licenseFile) && $licenseFile ne '') {
  my($licenseResource);
  $licenseResource = $tempSubdir.'/license.r';
  if(!licenseMaker($licenseFile, $licenseResource)) {
    cleanupDie('licenseMaker failed');
  }
  push(@resourceFiles, $licenseResource);
  # Don't add a cleanup object because licenseResource is in tempSubdir.
}

if(@resourceFiles) {
  # Add resources, such as a license agreement.

  # Only unflatten read-only and compressed images.  It's not supported
  # on other image times.
  if($unflattenable &&
   (command($gConfig{'cmd_hdiutil'}, 'unflatten', $targetImage)) != 0) {
    cleanupDie('hdiutil unflatten failed');
  }
  # Don't push flatten onto the cleanup stack.  If we fail now, we'll be
  # removing $targetImage anyway.

  # Type definitions come from Carbon.r.
  if(command($gConfig{'cmd_Rez'}, 'Carbon.r', @resourceFiles, '-a', '-o',
   $targetImage) != 0) {
    cleanupDie('Rez failed');
  }

  # Flatten.  This merges the resource fork into the data fork, so no
  # special encoding is needed to transfer the file.
  if($unflattenable &&
   (command($gConfig{'cmd_hdiutil'}, 'flatten', $targetImage)) != 0) {
    cleanupDie('hdiutil flatten failed');
  }
}

# $tempSubdir is no longer needed.  It's buried on the stack below the
# rm of the fresh image file.  Splice in this fashion is equivalent to
# pop-save, pop, push-save.
splice(@gCleanup, -2, 1);
# No need to remove licenseResource separately, it's in tempSubdir.
if(command($gConfig{'cmd_rm'}, '-rf', $tempSubdir) != 0) {
  cleanupDie('rm -rf tempSubdir failed');
}

if($idme) {
  if(command($gConfig{'cmd_hdiutil'}, 'internet-enable', '-yes',
   $targetImage) != 0) {
    cleanupDie('hdiutil internet-enable failed');
  }
}

# Done.

exit(0);

# argumentEscape(@arguments)
#
# Takes a list of @arguments and makes them shell-safe.
sub argumentEscape(@) {
  my(@arguments);
  @arguments = @_;
  my($argument, @argumentsOut);
  foreach $argument (@arguments) {
    $argument =~ s%([^A-Za-z0-9_\-/.=+,])%\\$1%g;
    push(@argumentsOut, $argument);
  }
  return @argumentsOut;
}

# cleanupDie($message)
#
# Displays $message as an error message, and then runs through the
# @gCleanup stack, performing any cleanup operations needed before
# exiting.  Does not return, exits with exit status 1.
sub cleanupDie($) {
  my($message);
  ($message) = @_;
  print STDERR ($0.': '.$message.(@gCleanup?' (cleaning up)':'')."\n");
  while(@gCleanup) {
    my($subroutine);
    $subroutine = pop(@gCleanup);
    &$subroutine;
  }
  exit(1);
}

# command(@arguments)
#
# Runs the specified command at the verbosity level defined by $gVerbosity.
# Returns nonzero on failure, returning the exit status if appropriate.
# Discards command output.
sub command(@) {
  my(@arguments);
  @arguments = @_;
  return commandVerbosity($gVerbosity,@arguments);
}

# commandInternal($command, @arguments)
#
# Runs the specified internal command at the verbosity level defined by
# $gVerbosity.
# Returns zero(!) on failure, because commandInternal is supposed to be a
# direct replacement for the Perl system call wrappers, which, unlike shell
# commands and C equivalent system calls, return true (instead of 0) to
# indicate success.
sub commandInternal($@) {
  my(@arguments, $command);
  ($command, @arguments) = @_;
  return commandInternalVerbosity($gVerbosity, $command, @arguments);
}

# commandInternalVerbosity($verbosity, $command, @arguments)
#
# Run an internal command, printing a bogus command invocation message if
# $verbosity is true.
#
# If $command is unlink:
# Removes the files specified by @arguments.  Wraps unlink.
#
# If $command is symlink:
# Creates the symlink specified by @arguments. Wraps symlink.
sub commandInternalVerbosity($$@) {
  my(@arguments, $command, $verbosity);
  ($verbosity, $command, @arguments) = @_;
  if($command eq 'unlink') {
    if($verbosity || $gDryRun) {
      print(join(' ', 'rm', '-f', argumentEscape(@arguments))."\n");
    }
    if($gDryRun) {
      return $#arguments+1;
    }
    return unlink(@arguments);
  }
  elsif($command eq 'symlink') {
    if($verbosity || $gDryRun) {
      print(join(' ', 'ln', '-s', argumentEscape(@arguments))."\n");
    }
    if($gDryRun) {
      return 1;
    }
    my($source, $target);
    ($source, $target) = @arguments;
    return symlink($source, $target);
  }
}

# commandOutput(@arguments)
#
# Runs the specified command at the verbosity level defined by $gVerbosity.
# Output is returned in an array of lines.  undef is returned on failure.
# The exit status is available in $?.
sub commandOutput(@) {
  my(@arguments);
  @arguments = @_;
  return commandOutputVerbosity($gVerbosity, @arguments);
}

# commandOutputVerbosity($verbosity, @arguments)
#
# Runs the specified command at the verbosity level defined by the
# $verbosity argument.  Output is returned in an array of lines.  undef is
# returned on failure.  The exit status is available in $?.
#
# If an error occurs in fork or exec, an error message is printed to
# stderr and undef is returned.
#
# If $verbosity is 0, the command invocation is not printed, and its
# stdout is not echoed back to stdout.
#
# If $verbosity is 1, the command invocation is printed.
#
# If $verbosity is 2, the command invocation is printed and the output
# from stdout is echoed back to stdout.
#
# Regardless of $verbosity, stderr is left connected.
sub commandOutputVerbosity($@) {
  my(@arguments, $verbosity);
  ($verbosity, @arguments) = @_;
  my($pid);
  if($verbosity || $gDryRun) {
    print(join(' ', argumentEscape(@arguments))."\n");
  }
  if($gDryRun) {
    return(1);
  }
  if (!defined($pid = open(*COMMAND, '-|'))) {
    printf STDERR ($0.': fork: '.$!."\n");
    return undef;
  }
  elsif ($pid) {
    # parent
    my(@lines);
    while(!eof(*COMMAND)) {
      my($line);
      chop($line = <COMMAND>);
      if($verbosity > 1) {
        print($line."\n");
      }
      push(@lines, $line);
    }
    close(*COMMAND);
    if ($? == -1) {
      printf STDERR ($0.': fork: '.$!."\n");
      return undef;
    }
    elsif ($? & 127) {
      printf STDERR ($0.': exited on signal '.($? & 127).
       ($? & 128 ? ', core dumped' : '')."\n");
      return undef;
    }
    return @lines;
  }
  else {
    # child; this form of exec is immune to shell games
    if(!exec {$arguments[0]} (@arguments)) {
      printf STDERR ($0.': exec: '.$!."\n");
      exit(-1);
    }
  }
}

# commandVerbosity($verbosity, @arguments)
#
# Runs the specified command at the verbosity level defined by the
# $verbosity argument.  Returns nonzero on failure, returning the exit
# status if appropriate.  Discards command output.
sub commandVerbosity($@) {
  my(@arguments, $verbosity);
  ($verbosity, @arguments) = @_;
  if(!defined(commandOutputVerbosity($verbosity, @arguments))) {
    return -1;
  }
  return $?;
}

# copyFiles($tempRoot, $method, @arguments)
#
# Copies files or create symlinks in the disk image.
# See --copy and --symlink descriptions for details.
# If $method is 'copy', @arguments are interpreted as source:target, if $method
# is 'symlink', @arguments are interpreted as symlink:target.
sub copyFiles($@) {
  my(@fileList, $method, $tempRoot);
  ($tempRoot, $method, @fileList) = @_;
  my($file, $isSymlink);
  $isSymlink = ($method eq 'symlink');
  foreach $file (@fileList) {
    my($source, $target);
    ($source, $target) = split(/:/, $file);
    if(!defined($target) and $isSymlink) {
      # empty symlink targets would result in an invalid target and fail,
      # but they shall be interpreted as "like source path, but inside dmg"
      $target = $source;
    }
    if(!defined($target)) {
      $target = $tempRoot;
    }
    elsif($target =~ /^\//) {
      $target = $tempRoot.$target;
    }
    else {
      $target = $tempRoot.'/'.$target;
    }

    my($success);
    if($isSymlink) {
      $success = commandInternal('symlink', $source, $target);
    }
    else {
      $success = !command($gConfig{'cmd_rsync'}, '-a', '--copy-unsafe-links',
                          $source, $target);
    }
    if(!$success) {
      cleanupDie('copyFiles failed for method '.$method);
    }
  }
}

# diskImageMaker($source, $destination, $format, $name, $tempDir, $tempMount,
#  $baseName, $setRootIcon)
#
# Creates a disk image in $destination of format $format corresponding to the
# source directory $source.  $name is the volume name.  $tempDir is a good
# place to write temporary files, which should be empty (aside from the other
# things that this script might create there, like stage and mount).
# $tempMount is a mount point for temporary disk images.  $baseName is the
# name of the disk image, and is presently unused.  $setRootIcon is true if
# a volume icon was added to the staged $source and indicates that the
# custom volume icon bit on the volume root needs to be set.
sub diskImageMaker($$$$$$$$) {
  my($baseName, $destination, $format, $name, $setRootIcon, $source,
   $tempDir, $tempMount);
  ($source, $destination, $format, $name, $tempDir, $tempMount,
   $baseName, $setRootIcon) = @_;
  if(isFormatCompressed($format)) {
    my($uncompressedImage);

    if($gConfig{'makehybrid'}) {
      my($hybridImage);
      $hybridImage = giveExtension($tempDir.'/hybrid', '.dmg');

      if(command($gConfig{'cmd_hdiutil'}, 'makehybrid', '-hfs',
       '-hfs-volume-name', $name, '-hfs-openfolder', $source, '-ov',
       $source, '-o', $hybridImage) != 0) {
        cleanupDie('hdiutil makehybrid failed');
      }

      $uncompressedImage = $hybridImage;

      # $source is no longer needed and will be removed before anything
      # else can fail.  splice in this form is the same as pop/push.
      splice(@gCleanup, -1, 1,
       sub {commandInternalVerbosity(0, 'unlink', $hybridImage);});

      if(command($gConfig{'cmd_rm'}, '-rf', $source) != 0) {
        cleanupDie('rm -rf failed');
      }

      if(!$gConfig{'partition_table'} && $gConfig{'recursive_access'}) {
        # Even if we do want to create disk images without partition tables,
        # it's impossible unless recursive_access is set.
        my($rootDevice, $partitionDevice, $partitionMountPoint);

        if(!(($rootDevice, $partitionDevice, $partitionMountPoint) =
         hdidMountImage($tempMount, '-readonly', $hybridImage))) {
          cleanupDie('hdid mount failed');
        }

        push(@gCleanup, sub {commandVerbosity(0,
         $gConfig{'cmd_diskutil'}, 'eject', $rootDevice);});

        my($udrwImage);
        $udrwImage = giveExtension($tempDir.'/udrw', '.dmg');

        if(command($gConfig{'cmd_hdiutil'}, 'create', '-format', 'UDRW',
         '-ov', '-srcdevice', $partitionDevice, $udrwImage) != 0) {
          cleanupDie('hdiutil create failed');
        }

        $uncompressedImage = $udrwImage;

        # Going to eject before anything else can fail.  Get the eject off
        # the stack.
        pop(@gCleanup);

        # $hybridImage will be removed soon, but until then, it needs to
        # stay on the cleanup stack.  It needs to wait until after
        # ejection.  $udrwImage is staying around.  Make it appear as
        # though it's been done before $hybridImage.
        #
        # splice in this form is the same as popping one element to
        # @tempCleanup and pushing the subroutine.
        my(@tempCleanup);
        @tempCleanup = splice(@gCleanup, -1, 1,
         sub {commandInternalVerbosity(0, 'unlink', $udrwImage);});
        push(@gCleanup, @tempCleanup);

        if(command($gConfig{'cmd_diskutil'}, 'eject', $rootDevice) != 0) {
          cleanupDie('diskutil eject failed');
        }

        # Pop unlink of $uncompressedImage
        pop(@gCleanup);

        if(commandInternal('unlink', $hybridImage) != 1) {
          cleanupDie('unlink hybridImage failed: '.$!);
        }
      }
    }
    else {
      # makehybrid is not available, fall back to making a UDRW and
      # converting to a compressed image.  It ought to be possible to
      # create a compressed image directly, but those come out far too
      # large (journaling?) and need to be read-write to fix up the
      # volume icon anyway.  Luckily, we can take advantage of a single
      # call back into this function.
      my($udrwImage);
      $udrwImage = giveExtension($tempDir.'/udrw', '.dmg');

      diskImageMaker($source, $udrwImage, 'UDRW', $name, $tempDir,
       $tempMount, $baseName, $setRootIcon);

      # The call back into diskImageMaker already removed $source.

      $uncompressedImage = $udrwImage;
    }

    # The uncompressed disk image is now in its final form.  Compress it.
    # Jaguar doesn't support hdiutil convert -ov, but it always allows
    # overwriting.
    # bzip2-compressed UDBZ images can only be created and mounted on 10.4
    # and later.  The bzip2-level imagekey is only effective when creating
    # images in 10.5.  In 10.4, bzip2-level is harmlessly ignored, and the
    # default value of 1 is always used.
    if(command($gConfig{'cmd_hdiutil'}, 'convert', '-format', $format,
     '-imagekey', ($format eq 'UDBZ' ? 'bzip2-level=9' : 'zlib-level=9'),
     (defined($gDarwinMajor) && $gDarwinMajor <= 6 ? () : ('-ov')),
     $uncompressedImage, '-o', $destination) != 0) {
      cleanupDie('hdiutil convert failed');
    }

    # $uncompressedImage is going to be unlinked before anything else can
    # fail.  splice in this form is the same as pop/push.
    splice(@gCleanup, -1, 1,
     sub {commandInternalVerbosity(0, 'unlink', $destination);});

    if(commandInternal('unlink', $uncompressedImage) != 1) {
      cleanupDie('unlink uncompressedImage failed: '.$!);
    }

    # At this point, the only thing that the compressed block has added to
    # the cleanup stack is the removal of $destination.  $source has already
    # been removed, and its cleanup entry has been removed as well.
  }
  elsif($format eq 'UDRW' || $format eq 'UDSP') {
    my(@extraArguments);
    if(!$gConfig{'partition_table'}) {
      @extraArguments = ('-layout', 'NONE');
    }

    if($gConfig{'create_directly'}) {
      # Use -fs HFS+ to suppress the journal.
      if(command($gConfig{'cmd_hdiutil'}, 'create', '-format', $format,
       @extraArguments, '-fs', 'HFS+', '-volname', $name,
       '-ov', '-srcfolder', $source, $destination) != 0) {
        cleanupDie('hdiutil create failed');
      }

      # $source is no longer needed and will be removed before anything
      # else can fail.  splice in this form is the same as pop/push.
      splice(@gCleanup, -1, 1,
       sub {commandInternalVerbosity(0, 'unlink', $destination);});

      if(command($gConfig{'cmd_rm'}, '-rf', $source) != 0) {
        cleanupDie('rm -rf failed');
      }
    }
    else {
      # hdiutil create does not support -srcfolder or -srcdevice, it only
      # knows how to create blank images.  Figure out how large an image
      # is needed, create it, and fill it.  This is needed for Jaguar.

      # Use native block size for hdiutil create -sectors.
      delete $ENV{'BLOCKSIZE'};

      my(@duOutput, $ignore, $sizeBlocks, $sizeOverhead, $sizeTotal, $type);
      if(!(@output = commandOutput($gConfig{'cmd_du'}, '-s', $tempRoot)) ||
       $? != 0) {
        cleanupDie('du failed');
      }
      ($sizeBlocks, $ignore) = split(' ', $output[0], 2);

      # The filesystem itself takes up 152 blocks of its own blocks for the
      # filesystem up to 8192 blocks, plus 64 blocks for every additional
      # 4096 blocks or portion thereof.
      $sizeOverhead = 152 + 64 * POSIX::ceil(
       (($sizeBlocks - 8192) > 0) ? (($sizeBlocks - 8192) / (4096 - 64)) : 0);

      # The number of blocks must be divisible by 8.
      my($mod);
      if($mod = ($sizeOverhead % 8)) {
        $sizeOverhead += 8 - $mod;
      }

      # sectors is taken as the size of a disk, not a filesystem, so the
      # partition table eats into it.
      if($gConfig{'partition_table'}) {
        $sizeOverhead += 80;
      }

      # That was hard.  Leave some breathing room anyway.  Use 1024 sectors
      # (512kB).  These read-write images wouldn't be useful if they didn't
      # have at least a little free space.
      $sizeTotal = $sizeBlocks + $sizeOverhead + 1024;

      # Minimum sizes - these numbers are larger on Jaguar than on later
      # systems.  Just use the Jaguar numbers, since it's unlikely to wind
      # up here on any other release.
      if($gConfig{'partition_table'} && $sizeTotal < 8272) {
        $sizeTotal = 8272;
      }
      if(!$gConfig{'partition_table'} && $sizeTotal < 8192) {
        $sizeTotal = 8192;
      }

      # hdiutil create without -srcfolder or -srcdevice will not accept
      # -format.  It uses -type.  Fortunately, the two supported formats
      # here map directly to the only two supported types.
      if ($format eq 'UDSP') {
        $type = 'SPARSE';
      }
      else {
        $type = 'UDIF';
      }

      if(command($gConfig{'cmd_hdiutil'}, 'create', '-type', $type,
       @extraArguments, '-fs', 'HFS+', '-volname', $name,
       '-ov', '-sectors', $sizeTotal, $destination) != 0) {
        cleanupDie('hdiutil create failed');
      }

      push(@gCleanup,
       sub {commandInternalVerbosity(0, 'unlink', $destination);});

      # The rsync will occur shortly.
    }

    my($mounted, $rootDevice, $partitionDevice, $partitionMountPoint);

    $mounted=0;
    if(!$gConfig{'create_directly'} || $gConfig{'openfolder_bless'} ||
     $setRootIcon) {
      # The disk image only needs to be mounted if:
      #  create_directly is false, because the content needs to be copied
      #  openfolder_bless is true, because bless -openfolder needs to run
      #  setRootIcon is true, because the root needs its attributes set.
      if(!(($rootDevice, $partitionDevice, $partitionMountPoint) =
       hdidMountImage($tempMount, $destination))) {
        cleanupDie('hdid mount failed');
      }

      $mounted=1;

      push(@gCleanup, sub {commandVerbosity(0,
       $gConfig{'cmd_diskutil'}, 'eject', $rootDevice);});
    }

    if(!$gConfig{'create_directly'}) {
      # Couldn't create and copy directly in one fell swoop.  Now that
      # the volume is mounted, copy the files.  --copy-unsafe-links is
      # unnecessary since it was used to copy everything to the staging
      # area.  There can be no more unsafe links.
      if(command($gConfig{'cmd_rsync'}, '-a',
       $source.'/',$partitionMountPoint) != 0) {
        cleanupDie('rsync to new volume failed');
      }

      # We need to get the rm -rf of $source off the stack, because it's
      # being cleaned up here.  There are two items now on top of it:
      # removing the target image and, above that, ejecting it.  Splice it
      # out.
      my(@tempCleanup);
      @tempCleanup = splice(@gCleanup, -2);
      # The next splice is the same as popping once and pushing @tempCleanup.
      splice(@gCleanup, -1, 1, @tempCleanup);

      if(command($gConfig{'cmd_rm'}, '-rf', $source) != 0) {
        cleanupDie('rm -rf failed');
      }
    }

    if($gConfig{'openfolder_bless'}) {
      # On Tiger, the bless docs say to use --openfolder, but only
      # --openfolder is accepted on Panther.  Tiger takes it with a single
      # dash too.  Jaguar is out of luck.
      if(command($gConfig{'cmd_bless'}, '-openfolder',
       $partitionMountPoint) != 0) {
        cleanupDie('bless failed');
      }
    }

    setAttributes($partitionMountPoint, @attributes);

    if($setRootIcon) {
      # When "hdiutil create -srcfolder" is used, the root folder's
      # attributes are not copied to the new volume.  Fix up.

      if(command($gConfig{'cmd_SetFile'}, '-a', 'C',
       $partitionMountPoint) != 0) {
        cleanupDie('SetFile failed');
      }
    }

    if($mounted) {
      # Pop diskutil eject
      pop(@gCleanup);

      if(command($gConfig{'cmd_diskutil'}, 'eject', $rootDevice) != 0) {
        cleanupDie('diskutil eject failed');
      }
    }

    # End of UDRW/UDSP section.  At this point, $source has been removed
    # and its cleanup entry has been removed from the stack.
  }
  else {
    cleanupDie('unrecognized format');
    print STDERR ($0.": unrecognized format\n");
    exit(1);
  }
}

# giveExtension($file, $extension)
#
# If $file does not end in $extension, $extension is added.  The new
# filename is returned.
sub giveExtension($$) {
  my($extension, $file);
  ($file, $extension) = @_;
  if(substr($file, -length($extension)) ne $extension) {
    return $file.$extension;
  }
  return $file;
}

# hdidMountImage($mountPoint, @arguments)
#
# Runs the hdid command with arguments specified by @arguments.
# @arguments may be a single-element array containing the name of the
# disk image to mount.  Returns a three-element array, with elements
# corresponding to:
#  - The root device of the mounted image, suitable for ejection
#  - The device corresponding to the mounted partition
#  - The mounted partition's mount point
#
# If running on a system that supports easy mounting at points outside
# of the default /Volumes with hdiutil attach, it is used instead of hdid,
# and $mountPoint is used as the mount point.
#
# The root device will differ from the partition device when the disk
# image contains a partition table, otherwise, they will be identical.
#
# If hdid fails, undef is returned.
sub hdidMountImage($@) {
  my(@arguments, @command, $mountPoint);
  ($mountPoint, @arguments) = @_;
  my(@output);

  if($gConfig{'hdiutil_mountpoint'}) {
    @command=($gConfig{'cmd_hdiutil'}, 'attach', @arguments,
     '-mountpoint', $mountPoint);
  }
  else {
    @command=($gConfig{'cmd_hdid'}, @arguments);
  }

  if(!(@output = commandOutput(@command)) ||
   $? != 0) {
    return undef;
  }

  if($gDryRun) {
    return('/dev/diskX','/dev/diskXsY','/Volumes/'.$volumeName);
  }

  my($line, $restOfLine, $rootDevice);

  foreach $line (@output) {
    my($device, $mountpoint);
    if($line !~ /^\/dev\//) {
      # Consider only lines that correspond to /dev entries
      next;
    }
    ($device, $restOfLine) = split(' ', $line, 2);

    if(!defined($rootDevice) || $rootDevice eq '') {
      # If this is the first device seen, it's the root device to be
      # used for ejection.  Keep it.
      $rootDevice = $device;
    }

    if($restOfLine =~ /(\/.*)/) {
      # The first partition with a mount point is the interesting one.  It's
      # usually Apple_HFS and usually the last one in the list, but beware of
      # the possibility of other filesystem types and the Apple_Free partition.
      # If the disk image contains no partition table, the partition will not
      # have a type, so look for the mount point by looking for a slash.
      $mountpoint = $1;
      return($rootDevice, $device, $mountpoint);
    }
  }

  # No mount point?  This is bad.  If there's a root device, eject it.
  if(defined($rootDevice) && $rootDevice ne '') {
    # Failing anyway, so don't care about failure
    commandVerbosity(0, $gConfig{'cmd_diskutil'}, 'eject', $rootDevice);
  }

  return undef;
}

# isFormatCompressed($format)
#
# Returns true if $format corresponds to a compressed disk image format.
# Returns false otherwise.
sub isFormatCompressed($) {
  my($format);
  ($format) = @_;
  return $format eq 'UDZO' || $format eq 'UDBZ';
}

# licenseMaker($text, $resource)
#
# Takes a plain text file at path $text and creates a license agreement
# resource containing the text at path $license.  English-only, and
# no special formatting.  This is the bare-bones stuff.  For more
# intricate license agreements, create your own resource.
#
# ftp://ftp.apple.com/developer/Development_Kits/SLAs_for_UDIFs_1.0.dmg
sub licenseMaker($$) {
  my($resource, $text);
  ($text, $resource) = @_;
  if(!sysopen(*TEXT, $text, O_RDONLY)) {
    print STDERR ($0.': licenseMaker: sysopen text: '.$!."\n");
    return 0;
  }
  if(!sysopen(*RESOURCE, $resource, O_WRONLY|O_CREAT|O_EXCL)) {
    print STDERR ($0.': licenseMaker: sysopen resource: '.$!."\n");
    return 0;
  }
  print RESOURCE << '__EOT__';
// See /System/Library/Frameworks/CoreServices.framework/Frameworks/CarbonCore.framework/Headers/Script.h for language IDs.
data 'LPic' (5000) {
  // Default language ID, 0 = English
  $"0000"
  // Number of entries in list
  $"0001"

  // Entry 1
  // Language ID, 0 = English
  $"0000"
  // Resource ID, 0 = STR#/TEXT/styl 5000
  $"0000"
  // Multibyte language, 0 = no
  $"0000"
};

resource 'STR#' (5000, "English") {
  {
    // Language (unused?) = English
    "English",
    // Agree
    "Agree",
    // Disagree
    "Disagree",
__EOT__
    # This stuff needs double-quotes for interpolations to work.
    print RESOURCE ("    // Print, ellipsis is 0xC9\n");
    print RESOURCE ("    \"Print\xc9\",\n");
    print RESOURCE ("    // Save As, ellipsis is 0xC9\n");
    print RESOURCE ("    \"Save As\xc9\",\n");
    print RESOURCE ('    // Descriptive text, curly quotes are 0xD2 and 0xD3'.
     "\n");
    print RESOURCE ('    "If you agree to the terms of this license '.
     "agreement, click \xd2Agree\xd3 to access the software.  If you ".
     "do not agree, press \xd2Disagree.\xd3\"\n");
print RESOURCE << '__EOT__';
  };
};

// Beware of 1024(?) byte (character?) line length limitation.  Split up long
// lines.
// If straight quotes are used ("), remember to escape them (\").
// Newline is \n, to leave a blank line, use two of them.
// 0xD2 and 0xD3 are curly double-quotes ("), 0xD4 and 0xD5 are curly
//   single quotes ('), 0xD5 is also the apostrophe.
data 'TEXT' (5000, "English") {
__EOT__

  while(!eof(*TEXT)) {
    my($line);
    chop($line = <TEXT>);

    while(defined($line)) {
      my($chunk);

      # Rez doesn't care for lines longer than (1024?) characters.  Split
      # at less than half of that limit, in case everything needs to be
      # backwhacked.
      if(length($line)>500) {
        $chunk = substr($line, 0, 500);
        $line = substr($line, 500);
      }
      else {
        $chunk = $line;
        $line = undef;
      }

      if(length($chunk) > 0) {
        # Unsafe characters are the double-quote (") and backslash (\), escape
        # them with backslashes.
        $chunk =~ s/(["\\])/\\$1/g;

        print RESOURCE '  "'.$chunk.'"'."\n";
      }
    }
    print RESOURCE '  "\n"'."\n";
  }
  close(*TEXT);

  print RESOURCE << '__EOT__';
};

data 'styl' (5000, "English") {
  // Number of styles following = 1
  $"0001"

  // Style 1.  This is used to display the first two lines in bold text.
  // Start character = 0
  $"0000 0000"
  // Height = 16
  $"0010"
  // Ascent = 12
  $"000C"
  // Font family = 1024 (Lucida Grande)
  $"0400"
  // Style bitfield, 0x1=bold 0x2=italic 0x4=underline 0x8=outline
  // 0x10=shadow 0x20=condensed 0x40=extended
  $"00"
  // Style, unused?
  $"02"
  // Size = 12 point
  $"000C"
  // Color, RGB
  $"0000 0000 0000"
};
__EOT__
  close(*RESOURCE);

  return 1;
}

# pathSplit($pathname)
#
# Splits $pathname into an array of path components.
sub pathSplit($) {
  my($pathname);
  ($pathname) = @_;
  return split(/\//, $pathname);
}

# setAttributes($root, @attributeList)
#
# @attributeList is an array, each element of which must be in the form
# <a>:<file>.  <a> is a list of attributes, per SetFile.  <file> is a file
# which is taken as relative to $root (even if it appears as an absolute
# path.)  SetFile is called to set the attributes on each file in
# @attributeList.
sub setAttributes($@) {
  my(@attributes, $root);
  ($root, @attributes) = @_;
  my($attribute);
  foreach $attribute (@attributes) {
    my($attrList, $file, @fileList, @fixedFileList);
    ($attrList, @fileList) = split(/:/, $attribute);
    if(!defined($attrList) || !@fileList) {
      cleanupDie('--attribute requires <attributes>:<file>');
    }
    @fixedFileList=();
    foreach $file (@fileList) {
      if($file =~ /^\//) {
        push(@fixedFileList, $root.$file);
      }
      else {
        push(@fixedFileList, $root.'/'.$file);
      }
    }
    if(command($gConfig{'cmd_SetFile'}, '-a', $attrList, @fixedFileList)) {
      cleanupDie('SetFile failed to set attributes');
    }
  }
  return;
}

sub trapSignal($) {
  my($signalName);
  ($signalName) = @_;
  cleanupDie('exiting on SIG'.$signalName);
}

sub usage() {
  print STDERR (
"usage: pkg-dmg --source <source-folder>\n".
"               --target <target-image>\n".
"              [--format <format>]           (default: UDZO)\n".
"              [--volname <volume-name>]     (default: same name as source)\n".
"              [--tempdir <temp-dir>]        (default: same dir as target)\n".
"              [--mkdir <directory>]         (make directory in image)\n".
"              [--copy <source>[:<dest>]]    (extra files to add)\n".
"              [--symlink <source>[:<dest>]] (extra symlinks to add)\n".
"              [--license <file>]            (plain text license agreement)\n".
"              [--resource <file>]           (flat .r files to merge)\n".
"              [--icon <icns-file>]          (volume icon)\n".
"              [--attribute <a>:<file>]      (set file attributes)\n".
"              [--idme]                      (make Internet-enabled image)\n".
"              [--sourcefile]                (treat --source as a file)\n".
"              [--verbosity <level>]         (0, 1, 2; default=2)\n".
"              [--dry-run]                   (print what would be done)\n");
  return;
}
