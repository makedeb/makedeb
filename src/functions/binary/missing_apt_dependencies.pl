#!/usr/bin/env perl

# libdpkg-perl
# libdpkg-parse-perl

use DPKG::Parse::Status;
use Dpkg::Deps;

use Data::Dumper;

$cache = DPKG::Parse::Status->new();
$cache->parse();

$facts = Dpkg::Deps::KnownFacts->new();

for my $value (@{$cache->entryarray()}){
    my $name = $value->{'package'};
    my $arch = $value->{'architecture'};
    my $version = $value->{'version'} || '';
    my $multi = $value->{'multi_arch'} || '';
    my $prov = $value->{'provides'};
    my $virlist;
    if (! $prov){
        $virlist = [];
    } else {
        $virlist = deps_parse($prov)->{'list'};
    }
    
    $facts->add_installed_package("$name", "$version", "$arch", "$multi");
    for my $prov (@{$virlist}){
        $version = $prov->{'version'} || '';
        $name = $prov->{'package'} || '';
        my $archqual = $prov->{'archqual'} || $arch;
        $facts->add_installed_package("$name", "$version", "$archqual", "$multi");
    }
}


for (@ARGV){
    my $deps = deps_parse($_);
    my @ordeps;
    
    if(!$deps->get_evaluation($facts)){
        print "${deps}\n";
    }    
}

#use AptPkg::Cache;
##libapt-pkg-perl
##libdpkg-perl
#use Data::Dumper;
#use Dpkg::Deps;
#no warnings 'all';

#$cache = AptPkg::Cache->new();

#$facts = Dpkg::Deps::KnownFacts->new();

#while (my ($key, $value) = each(%$cache)) {
    #my $ver=$value->{"CurrentVer"};
    #if (defined $ver){
        #my $virlist = $ver->{"ProvidesList"};
        #my $name = $value->{"Name"};
        #my $version = $ver->{"VerStr"};
        #my $arch = $ver->{"Arch"};
        #my $multi = $value->{"MultiArch"};
        #$facts->add_installed_package($name, $version, $arch, $multi);
        #for (@{$virlist}){
            #$name = $_->{"Name"};
            #$version = $_->{"ProvideVersion"};
            #if (! defined  $version) { $version = ''; }
            #$facts->add_installed_package($name, $version, $arch, $multi);
        #}
    #};
#}

#for (@ARGV){
    #my $deps = deps_parse($_);
    #my @ordeps;
    
    #if(!$deps->get_evaluation($facts)){
        #print "${deps}\n";
    #}    
#}
