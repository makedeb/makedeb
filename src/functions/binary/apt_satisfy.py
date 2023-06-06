#!/usr/bin/env python3
import subprocess as sbp
from os import system
import sys
def run(*a):
	return sbp.run(a, stdout=subprocess.PIPE).stdout.decode('utf-8')

def runquery():
	return set(run("dpkg-query", "-Wf", "${Package}\\n").split("\n"))

prev_installed_packages = runquery()

if (system("apt-get satisfy " + ' '.join(sys.argv) != 0): #{
#error "$(gettext "Failed to install missing dependencies.")"
    exit(1);


cur_installed_packages = runquery()

newly_installed_packages = cur_installed_packages.difference(prev_installed_packages)
if (len(newly_installed_packages) > 0):
     if (system("apt-mark -qqqq auto " + " ".join(newly_installed_packages)) != 0):
        #error "$(gettext "Failed to install missing dependencies.")"
          print "some strange error";
          exit 1;

"""
my @prev_installed_packages = split('\n', `dpkg-query -Wf '\${Package}\\n'`);

# Install the missing deps.

if (system("apt-get", "satisfy", @ARGV) != 0) {
        #error "$(gettext "Failed to install missing dependencies.")"
     exit 1;
}

my @cur_installed_packages = split('\n', `dpkg-query -Wf '\${Package}\\n'`);

my @newly_installed_packages = grep { my $f = $_;
                      ! grep $_ eq $f, @prev_installed_packages }
               @cur_installed_packages;

if (scalar @newly_installed_packages > 0){
     if (system("apt-mark", "-qqqq", auto, @newly_installed_packages) != 0) {
        #error "$(gettext "Failed to install missing dependencies.")"
          print "some strange error";
          exit 1;
     }
}
"""
