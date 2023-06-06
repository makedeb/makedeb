#!/usr/bin/env python3
import re
import json
import glob

from os import environ as env
from requests import post
from requests.auth import HTTPBasicAuth

commit_branch = env["DRONE_COMMIT_BRANCH"]
proget_server = env["proget_server"]
proget_api_key = env["proget_api_key"]
distro = env["dpkg_distro"]

if commit_branch == "stable":
    package_name = "makedeb"
else:
    package_name = f"makedeb-{commit_branch}"

print("INFO: Uploading package...")

for filename in glob.glob("makedeb*.deb"):
    with open(filename, "rb") as file:
        response = post(
            f"https://{proget_server}/debian-packages/upload/makedeb/{distro}/{filename}",
            data=file,
            auth=HTTPBasicAuth("api", proget_api_key)
        )

    if response.reason != "Created":
        print("ERROR: There was an error uploading the package.")
        print("=====")
        print(response.reason)
        print(response.text)
        exit(1)

print("INFO: Succesfully uploaded package.")
exit(0)
