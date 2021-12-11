#!/usr/bin/env python3
import apt_pkg
import sys

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
        
    # Check the cache for the package.
    try:
        cache[pkgname]
    except KeyError:
        missing_packages += [pkgname]
        continue
    
    if cache[pkgname].current_state != apt_pkg.CURSTATE_INSTALLED:
        missing_packages += [package_string]
    else:
        if pkgver is None:
            continue
        
        installed_pkgver = cache[pkgname].current_ver.ver_str
        version_status = apt_pkg.version_compare(installed_pkgver, pkgver)
        
        if relationship_operator == "<":
            if version_status >= 0:
                missing_packages += [package_string]
        elif relationship_operator == ">":
            if version_status <= 0:
                missing_packages += [package_string]
        elif relationship_operator == "<=":
            if version_status > 0:
                missing_packages += [package_string]
        elif relationship_operator == ">=":
            if version_status < 0:
                missing_packages += [package_string]
        elif relationship_operator == "=":
            if version_status != 0:
                missing_packages += [package_string]

for i in missing_packages:
    print(i)

exit(0)
