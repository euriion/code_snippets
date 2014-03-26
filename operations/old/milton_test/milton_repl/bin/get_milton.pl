#!/usr/bin/perl -w
use strict;
use File::Basename;

my $prog_dir=dirname($0);

my @milton_list=split_cfg("tw_milton_repl__list");
my @repl_host=split_cfg("tw_milton_repl__host");

my $export_dir="/home/y/share/milton_repl/data";
my $export_cmd="/home/y/bin/milton__export_list.pl";


foreach my $l (@milton_list) {
     my $l_len=length($l);
     if(substr($l, $l_len-1, 1) eq "/") {
         warn("skip : list format error [$l]");
         next;
     }

     my $dest="${export_dir}${l}";
     my $dest_dir=dirname($dest);

     if(!-d $dest_dir) {
         my $cmd = "mkdir -p $dest_dir";
         my_system($cmd);
     }

     my $cmd="${export_cmd} $l $dest";
     my_system($cmd);
}

foreach my $h (@repl_host) {
#     my_system("ssh $h \"mkdir -p $export_dir\"");
     my $rc=my_system("ssh $h \"ls -ld $export_dir > /dev/null 2>&1\"", 1);
     if(!$rc) {
         write_build_conf("$prog_dir", \@repl_host, $export_dir);
         die("\n\nplease run the following command as your id:\n     $prog_dir/build_dir.sh\n");
     }
     my_system("rsync -a $export_dir/* $h:$export_dir");
}

sub write_build_conf {
    my ($prog_dir, $repl_host, $export_dir) = @_;
    my $host_conf="$prog_dir/build_dir.host";
    my $dir_conf="$prog_dir/build_dir.dir";
    open(HOST_CFG, ">$host_conf") or die "unable to open $host_conf for write : $!";
    print HOST_CFG join("\n", @$repl_host);
    close(HOST_CFG);

    open(DIR_CFG, ">$dir_conf") or die "unable to open $dir_conf for write : $!";
    print DIR_CFG $export_dir, "\n";
    close(DIR_CFG);
}


sub split_cfg {
    my $name = shift;
    if(!$name) { die "$name can't empty"; }
    my $list=$ENV{$name};
    if(!$list) { die "please define env value for $name"; }

    my @data=split(",", $list);
    return @data;
}


sub my_system {
    my $cmd = shift;
    my $allow_error = shift;

    my $rc = 0xffff & system $cmd;

    if ($rc == 0) {

    } elsif ($rc == 0xff00) {
        print "command failed: $!\n";
    } elsif (($rc & 0xff) == 0) {
        $rc >>= 8;
        print "ran $cmd with non-zero exit status $rc\n";
    } else {
        print "ran with ";
        if ($rc &   0x80) {
            $rc &= ~0x80;
            print "coredump from ";
        } 
        print "signal $rc\n"
    } 

    die "error exec $cmd" if($rc!=0 && !$allow_error);
    return $rc==0;
}
