#!/usr/bin/perl

#my $file_root="/Users/darrylquinn/Desktop/aredn/downloads/firmware/ubnt";
#my $md5cmd="md5 -r";

my $file_root="/mnt/data/www/downloads/firmware/ubnt";
my $md5cmd="md5sum";
my $download_root="http://downloads.arednmesh.org/firmware/ubnt";

print "AREDN Production LIST file maker...\n\n";

# ==============================================================================================
opendir my $dh, $file_root or die "Could not open '$file_root' for reading: $!\n";
my @files = grep {/AREDN-.*\.bin/} readdir($dh);

# ---- FACTORY list
print "Creating factory list...\n";
open(LISTALL, ">", "firmware.all-factory.list") or die("$!");
foreach $f (@files)
{
	if($f =~ /AREDN-[0-9.]*-.*-factory.bin/) {
		print LISTALL "$f\n";
	}
};
close(LISTALL);

# ---- DEVICE lists
my @devs=("nano-m","bullet-m","airrouter","cpe510","rocket-m","nano-m-xw");
foreach $dev (@devs)
{
	print "Creating $dev sysupgrade list...\n";
	open(LISTD, ">", "firmware.$dev.list") or die("$!");
	foreach $f (@files)
	{
		if($dev eq "cpe510")
		{ 
			if($f =~ /AREDN-[0-9.]*-cpe210-220-510-520-squashfs-sysupgrade.bin/)
			{
				chomp ($md5  = `$md5cmd $file_root/$f | awk '{print \$1}'`);
				print LISTD "$md5 $f all\n";
			}
		} else {
			if($f =~ /AREDN-[0-9.]*-.*-$dev-squashfs-sysupgrade.bin/)
			{
				chomp ($md5  = `$md5cmd $file_root/$f | awk '{print \$1}'`);
				print LISTD "$md5 $f all\n";
			}
		}
	}
};
close(LISTD);

print "Make sure that .list files are copied to $file_root\n";
