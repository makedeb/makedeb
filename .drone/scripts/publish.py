#!/usr/bin/env python3
import re
import requests

from os import environ as env
from requests.auth import HTTPBasicAuth

commit_message = env["DRONE_COMMIT_MESSAGE"]
commit_branch = env["DRONE_COMMIT_BRANCH"]
proget_server = env["proget_server"]
proget_api_key = env["proget_api_key"]

for i in commit_message.splitlines():
    current_string = re.search("Package Version: ")

    if current_version != None:
        package_version = current_string.replace("Package Version: ", "").split("-")
        pkgver = package_version[0]
        pkgrel = package_version[1]
        break

if commit_branch == "stable":
    package_name = "makedeb"
else:
    package_name = f"makedeb-{commit_branch}"

filename = f"{package_name}_{pkgver}-{pkgrel}_all.deb"

with open(f"./PKGBUILD/{filename}") as file:
    data = file.read()

print("INFO: Uploading package...")
response = post(f"https://{proget_server}/debian/packages/upload/makedeb/main/{filename}", data=data, auth=HTTPBasicAuth("api", proget_api_key))

if response.status_code != 200:
    print(f"ERROR: There was an error uploading the package {response.reason}.")
    exit(1)

print("INFO: Succesfully uploaded package.")
exit(0)
