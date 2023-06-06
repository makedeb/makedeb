#!/usr/bin/env python3
import subprocess as sbp
import sys
def run(*a):
	return sbp.run(a, stdout=subprocess.PIPE).stdout.decode('utf-8')
def system(*a):
	return sbp.call(a)

def runquery():
	return set(run("dpkg-query", "-Wf", "${Package}\\n").split("\n"))

prev_installed_packages = runquery()

if (system("apt-get", "satisfy", *sys.argv) != 0): #{
#error "$(gettext "Failed to install missing dependencies.")"
    exit(1);


cur_installed_packages = runquery()

newly_installed_packages = cur_installed_packages.difference(prev_installed_packages)
if (len(newly_installed_packages) > 0):
     if (system("apt-mark", "-qqqq",  "auto", *newly_installed_packages) != 0):
        #error "$(gettext "Failed to install missing dependencies.")"
          print "some strange error";
          exit 1;

"""
sub runquery{
	return split('\n', `dpkg-query -Wf '\${Package}\\n'`);
}

my @prev_installed_packages = runquery();

# Install the missing deps.

if (system("apt-get", "satisfy", @ARGV) != 0) {
        #error "$(gettext "Failed to install missing dependencies.")"
     exit 1;
}

my @cur_installed_packages = runquery();

my @newly_installed_packages = grep { my $f = $_;
                      ! grep $_ eq $f, @prev_installed_packages }
               @cur_installed_packages;

if (scalar @newly_installed_packages > 0){
     if (system("apt-mark", "-qqqq", "auto", @newly_installed_packages) != 0) {
        #error "$(gettext "Failed to install missing dependencies.")"
          print "some strange error";
          exit 1;
     }
}
"""
