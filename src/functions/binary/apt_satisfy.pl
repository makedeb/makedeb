#!/usr/bin/env perl
my @prev_installed_packages = split('\n', `dpkg-query -Wf '\${Package}\\n'`);

# Install the missing deps.

if (system("apt-get", satisfy, @ARGV) != 0) {
        #error "$(gettext "Failed to install missing dependencies.")"
     exit 1;
}

my @cur_installed_packages = split('\n', `dpkg-query -Wf '\${Package}\\n'`);

my @newly_installed_packages = grep { my $f = $_;
                      ! grep $_ eq $f, @prev_installed_packages }
               @cur_installed_packages;


if (system("apt-mark", "-qqqq", auto, @newly_installed_packages) != 0) {
        #error "$(gettext "Failed to install missing dependencies.")"
     print "some strange error";
     exit 1;
}
