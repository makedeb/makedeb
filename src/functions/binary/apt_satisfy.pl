#!/usr/bin/env perl
use Array::Diff;

#libarray-diff-perl

sub runquery{
	return [split('\n', `dpkg-query -Wf '\${Package}\\n'`)];
}

# Install the missing deps.
my $prev_installed_packages = runquery();

system("apt-get", "satisfy", @ARGV);

my $cur_installed_packages = runquery();

my $newly_installed_packages = 
Array::Diff->diff(
    $prev_installed_packages, 
    $cur_installed_packages)->added;

if (scalar @$newly_installed_packages > 0){
     if (system("apt-mark", "-qqqq", "auto", @$newly_installed_packages) != 0) {
        #error "$(gettext "Failed to install missing dependencies.")"
          print "some strange error";
          exit 1;
     }
     
    for (@$newly_installed_packages){
        print "$_\n";
    }
}
exit 0;
