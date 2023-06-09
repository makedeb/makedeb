#!/usr/bin/env perl

use AptPkg::Cache;
#libapt-pkg-perl
#libdpkg-perl
use Data::Dumper;
use Dpkg::Deps;
no warnings 'all';

$cache = AptPkg::Cache->new();

$facts = Dpkg::Deps::KnownFacts->new();

while (my ($key, $value) = each(%$cache)) {
    my $ver=$value->{"CurrentVer"};
    if (defined $ver){
        my $virlist = $ver->{"ProvidesList"};
        my $name = $value->{"Name"};
        my $version = $ver->{"VerStr"};
        my $arch = $ver->{"Arch"};
        my $multi = $value->{"MultiArch"};
        $facts->add_installed_package($name, $version, $arch, $multi);
        for (@{$virlist}){
            $name = $_->{"Name"};
            $version = $_->{"ProvideVersion"};
            if (! defined  $version) { $version = ''; }
            $facts->add_installed_package($name, $version, $arch, $multi);
        }
    };
}

for (@ARGV){
    my $deps = deps_parse($_);
    my @ordeps;
    
    if(!$deps->get_evaluation($facts)){
        print "${deps}\n";
    }    
}
