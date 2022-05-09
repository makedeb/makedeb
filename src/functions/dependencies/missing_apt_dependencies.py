#!/usr/bin/env python3
import apt_pkg
import sys

from apt_pkg import CURSTATE_INSTALLED, version_compare
from operator import lt, le, eq, ge, gt

# Function mappings for relationship operators.
relation_operators = {"<": lt, "<=": le, "=": eq, ">=": ge, ">": gt}

# Set up APT cache.
apt_pkg.init()
cache = apt_pkg.Cache(None)

# bad_dep keeps track of if any dependency in sys.argv is unable
# to be satisfied. good_dep (seen later in this script) checks
# each item in a dependency (i.e. 'pkg1' and 'pkg2' in 'pkg1 | pkg2').
missing_deps = []

for i in sys.argv[1:]:
    # We only pass in one group of dependencies ('pkg1=1 | pkg2>=2') at a time,
    # so we can safely only get the first item in the returned list.
    # See https://apt-team.pages.debian.net/python-apt/library/apt_pkg.html#apt_pkg.parse_depends
    # for how this is layed out.
    deps = apt_pkg.parse_depends(i)[0]
    
    # See if one of the provided deps were found.
    good_dep = False

    for dep in deps:
        pkgname, pkgver_restrictor, comparator_restrictor = dep

        if comparator_restrictor:
            ver_comparator = relation_operators[comparator_restrictor]

        try:
            pkg = cache[pkgname]
        except KeyError:
            continue

        # Check if the package in the cache provided this one.
        if pkg.current_state == apt_pkg.CURSTATE_INSTALLED:

            # If there was no version restrictor, it satisfied the dependency.
            if pkgver_restrictor == "":
                good_dep = True
                break

            # Otherwise, compare the versions see if it passes.
            ver_result = version_compare(pkg.current_ver.ver_str, pkgver_restrictor)

            if ver_comparator(ver_result, 0):
                good_dep = True
                break

        # If not, check if any provided packages do.
        for provided_pkg in pkg.provides_list:
            provided_pkgver_restrictor, provided_pkgver_object = provided_pkg[1:]
            provided_pkg_object = provided_pkgver_object.parent_pkg

            # If this provided package's version isn't installed in the first place, it can't satisfy the dep.
            if provided_pkg_object.current_state != apt_pkg.CURSTATE_INSTALLED:
                continue

            # If this dep specified a version restrictor, but this provided package didn't,
            # it also can't satisfy this dependency.
            if pkgver_restrictor != "" and provided_pkgver_restrictor is None:
                continue

            # If no restrictor was specified on both ends, it'll satisfy the dep.
            if ("", None) == (pkgver_restrictor, provided_pkgver_restrictor):
                good_dep = True
                break

            print(repr((pkgver_restrictor, provided_pkgver_restrictor)))

            # Else if the provided package's version satisfies the requirements of the version
            # restrictor, it'll satisfy the dep.
            ver_result = version_compare(provided_pkg_object.current_ver.ver_str, pkgver_restrictor)

            if ver_comparator(ver_result, 0):
                good_dep = True
                break

        # If good_dep was reached in the loop, break again.
        if good_dep is True:
            break

    # If good_dep was reached, mark bad_dep as false.
    if good_dep is not True:
        missing_deps += [i]

# Show all missing deps.
for dep in missing_deps:
    print(dep)
