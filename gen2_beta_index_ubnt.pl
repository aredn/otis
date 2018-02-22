#!/usr/bin/perl

#my $file_root="/Users/darrylquinn/Desktop/aredn/downloads/firmware/ubnt";
#my $md5cmd="md5 -r";

my $file_root="/mnt/data/www/downloads/firmware/ubnt";
my $md5cmd="md5sum";
my $download_root="http://downloads.arednmesh.org/firmware/ubnt";

print "AREDN Release Candidate Page builder...\n\n";

my %image_type = (
  factory => "Loading from AirOS or TFTP",
  sysupgrade => "Loading from AREDN or BBHN"
);

my @firmware = (
  {
    mfg     => "ubnt",
    mfg_name=> "Ubiquiti",
    family  => "bullet-m",
    models  => [
      "AirGrid M2",
      "AirGrid M5",
      "Bullet M2",
      "Bullet M5",
      "Bullet M2 Titanium",
      "Bullet M5 Titanium",
      "NanoBridge M2",
      "NanoBridge M5",
      "NanoBridge M9",
      "NanoStation Loco M2",
      "NanoStation Loco M5 (XM)",
      "NanoStation Loco M9",
      "PicoStation M2",
    ],
  },
  {
    mfg     => "ubnt",
    mfg_name=> "Ubiquiti",
    family  => "nano-m",
    models  => [
      "NanoBridge M3",
      "NanoStation M2",
      "NanoStation M3",
      "NanoStation M5 (XM)",
    ],
  },
  {
    mfg     => "ubnt",
    mfg_name=> "Ubiquiti",
    family  => "rocket-m",
    models  => [
      "Rocket M2",
      "Rocket M3",
      "Rocket M5",
      "Rocket M5 GPS",
      "Rocket M9",
    ],
  },
  {
    mfg     => "ubnt",
    mfg_name=> "Ubiquiti",
    family  => "airrouter",
    models  => [
      "AirRouter",
      "AirRouter HP",
    ],
  },
  {
    mfg     => "ubnt",
    mfg_name=> "Ubiquiti",
    family  => "nano-m-xw",
    models  => [
      "NanoStation M5 (XW)",
    ],
  },
  {
    mfg     => "ubnt",
    mfg_name=> "Ubiquiti",
    family  => "loco-m-xw",
    models  => [
      "AirGrid M5 (XW)",
      "NanoBeam NBE-M5-16",
      "NanoBeam NBE-M5-19",
      "NanoStation Loco M5 (XW)",
      "PowerBeam PBE-M2-400",
      "PowerBeam PBE-M5-300",
    ],
  },
  {
    mfg     => "ubnt",
    mfg_name=> "Ubiquiti",
    family  => "rocket-m-xw",
    models  => [
      "PowerBeam PBE-M5-400",
      "Rocket M5 (XW)",
    ],
  },
  {
    mfg     => "cpe210",
    mfg_name=> "TP-Link",
    family  => "220-510-520",
    models  => [
      "CPE210",
      "CPE510"
    ],
  },
);

my @patches = (
  {
    name  => "AREDN 3.16.1.1 OTA Fixup",
    filename  => "patchFixAREDN31611SysUpgrade.tgz",
    desc  => "Fixup for AREDN 3.16.1.1 nodes before upgrading to 3.17.1.0 to free memory and ensure a successful upgrade.",
  },

);


# ==============================================================================================

$ver = shift;
die unless $ver;

my $prev_mfg;

#open(IDX, ">", "/mnt/data/www/downloads/firmware/ubnt/html/experimental2.html") or die("$!");

open(IDX, ">", "$file_root/html/releasecandidates.html") or die("$!");

print IDX << 'INDEXHTMLHEADER';
<html>
<head>
<title>AREDN&trade; Release Candidate Firmware</title>
<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
<META HTTP-EQUIV="Expires" CONTENT="-1">
<style>
  body {
    font-family: Verdana;
  }

  .main-section {
    width: 80%;
    border: solid 1px black;
  }

  .latest-version-section {
    background-color: #e0e0e0;
  }

  .mfg-section {
    background-color: #e0e0e0;
  }

  .image-section td {
    border: solid 1px black;
  }

  .models {}

  .image-size {}

  .image-link-section {}

  .models {}

  .patches-section {}

  .patch-section td {
    border: solid 1px black;  
  }

  .experimental-warning {
    font-weight: bold;
    color: #FF0000;
  }

  .message-section {
    background-color: #E4CCC9;
  }

  #image-md5 { font-size: 8pt;}

  #note {
    background-color: yellow;
    font-size: 8pt;
    color: black;
  }
  
</style>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-62457121-1', 'auto');
  ga('send', 'pageview');

</script>
</head>
<body>
<center>

<p>
<table class="main-section" cellpadding=5>
<tr class="experimental-warning"><td colspan="3">WARNING: Releases on this page have not undergone full testing. Releases on this page  may contain bugs and or vulnerabilities and are subject to frequent revision. Production use is not supported.</td></tr>
<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->
INDEXHTMLHEADER

print IDX "<tr class=\"latest-version-section\"><th colspan=3>Latest Release Candidate version is: $ver</th></tr>\n\n";
print IDX "<tr><th>STEP 1: Find your device/model from this column.</th>";
print IDX "<th colspan=2>STEP 2: Choose either the FACTORY or SYSUPGRADE file from these columns</th></tr>\n\n";
print IDX "<tr class=\"message-section\"><th>&nbsp;</th><th>$image_type{factory}</th><th>$image_type{sysupgrade}</th></tr>\n\n";

foreach $f (@firmware)
{
  print "msg=$f->{mfg}\nmfg name=$f->{mfg_name}\nfamily=$f->{family}\n";
  if ($f->{mfg} ne $prev_mfg)
  {
    print IDX "<tr class=\"mfg-section\"><th colspan=3>AREDN&trade; Firmware for $f->{mfg_name}</th></tr>\n\n";
    $prev_mfg=$f->{mfg};
  }
	  
  print IDX "<tr class=\"image-section\">\n";
  print IDX "<td width=\"40%\" class=\"models\">";
  #my @mods=@{ $f->{models} };
  foreach my $model_name (@{ $f->{models}})
  {
    print IDX "$model_name<br />\n";
  }  
  print IDX "</td>";
 
  foreach $type ("factory","sysupgrade")
  {
    $file = "AREDN-$ver-$f->{mfg}-$f->{family}-squashfs-$type.bin";
    chomp ($size = `ls -lh $file_root/$file | awk '{print \$5}'`);
    chomp ($md5  = `$md5cmd $file_root/$file | awk '{print \$1}'`);
    #print IDX "<td class=\"image-size\">$size</td>\n";
    print IDX "<td width=\"30%\" ><a href=\"$download_root/$file\">$type</a><br>";
    print IDX "<small>md5sum: $md5</small><hr />Size: $size</td>\n";
  }
  print IDX "</tr>\n\n";
};

# ======================= PATCHES =========================
print IDX "<tr bgcolor=\"e0e0e0\"><th colspan=3><strong>Patches</strong></th></tr>";

foreach $f (@patches)
{
  chomp ($size = `ls -lh $file_root/$f->{filename} | awk '{print \$5}'`);
  print IDX "<tr class=\"image-section\">\n";
  print IDX "<td width=\"40%\" class=\"models\">$f->{desc}</td>";
  print IDX "<td width=\"60%\" colspan=\"2\"><a href=\"http://downloads.arednmesh.org/firmware/ubnt/$f->{filename}\">$f->{name}</a><hr />Size: $size</td>";
  print IDX "</tr>";
} 
print IDX "</table>";
print IDX "</p>";
print IDX "</center>";
print IDX "</body>";
print IDX "</html>";


close(IDX);

