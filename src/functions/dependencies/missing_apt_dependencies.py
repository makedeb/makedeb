#!/usr/bin/env python3
import apt_pkg
import sys

from apt_pkg import CURSTATE_INSTALLED, version_compare
from operator import lt, le, eq, ge, gt

# Function mappings for relationship operators.
relation_operators = {"<<": lt, "<=": le, "=": eq, ">=": ge, ">>": gt}

# Set up APT cache.
apt_pkg.init()
cache = apt_pkg.Cache(None)

missing_packages = []

for i in sys.argv[1:]:
    # Build the package relationship string for use by 'apt-get satisfy'.
    relationship_operator = None

    for j in ["<=", ">=", "<", ">", "="]:
        if j in i:
            relationship_operator = j
            break

    if relationship_operator is not None:
        if relationship_operator in ["<", ">"]:
            relationship_operator_formatted = j + j
        else:
            relationship_operator_formatted = j

        package = i.split(relationship_operator)
        pkgname = package[0]
        pkgver = package[1]
        package_string = f"{pkgname} ({relationship_operator_formatted} {pkgver})"
    else:
        pkgname = i
        pkgver = None
        package_string = pkgname

    # Check if the package is in the cache.
    try:
        pkg = cache[pkgname]
    except KeyError:
        missing_packages += [package_string]
        continue

    # Get the list of installed and provided packages that are currently installed.
    installed_pkg_versions = []

    if pkg.current_state == CURSTATE_INSTALLED:
        installed_pkg_versions += [pkg]

    for i in pkg.provides_list:
        parent_pkg = i[2].parent_pkg

        if parent_pkg.current_state == CURSTATE_INSTALLED:
            installed_pkg_versions += [parent_pkg]

    # If an installed package was found and no relationship operators were used, the dependency has been satisfied.
    if (len(installed_pkg_versions) != 0) and (relationship_operator is None):
        continue

    # Otherwise, check all matching installed packages and see if any of them fit the specified relationship operator.
    matched_pkg = False

    for i in installed_pkg_versions:
        installed_version = i.current_ver.ver_str
        version_result = version_compare(installed_version, pkgver)

        if relation_operators[relationship_operator_formatted](version_result, 0):
            matched_pkg = True

    if not matched_pkg:
        missing_packages += [package_string]

for i in missing_packages:
    print(i)

exit(0)
