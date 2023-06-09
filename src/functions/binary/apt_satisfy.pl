#!/usr/bin/env perl
use Array::Diff;
#libarray-diff-perl

if (scalar @ARGV == 0){
	exit 0;
}

sub runquery{
	return split('\n', `dpkg-query -Wf '\${Package}\\n'`);
}

# Install the missing deps.
my @prev_installed_packages = runquery();

if (system("apt-get", "satisfy", @ARGV) != 0) {
        #error "$(gettext "Failed to install missing dependencies.")"
     exit 1;
}

my @cur_installed_packages = runquery();

my @newly_installed_packages = 
Array::Diff->diff(
    \@prev_installed_packages, 
    \@cur_installed_packages)->added;

if (scalar @newly_installed_packages > 0){
     if (system("apt-mark", "-qqqq", "auto", @newly_installed_packages) != 0) {
        #error "$(gettext "Failed to install missing dependencies.")"
          print "some strange error";
          exit 1;
     }
}
