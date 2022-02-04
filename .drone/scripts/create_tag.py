#!/usr/bin/env python3
import json
import subprocess

from os import environ
from github import Github

# Get all the info we need.
github_api_key = environ["github_api_key"]
drone_branch = environ["DRONE_COMMIT_BRANCH"]
drone_repo = "makedeb/makedeb"
commit_sha = (
    subprocess.run(["git", "log", "-n", "1", "--format=%H"], stdout=subprocess.PIPE)
    .stdout.decode()
    .strip("\n")
)

with open(".data.json", "r") as file:
    data = json.loads(file.read())

pkgver = data["current_pkgver"]
pkgrel = data["current_pkgrel"]

client = Github(github_api_key)

tag = f"v{pkgver}-{pkgrel}-{drone_branch}"
name = f"v{pkgver}-{pkgrel}"
message = f"Released {name}."

repo = client.get_repo(drone_repo)

# We publish GitHub releases on pushes to the 'stable' branch. Otherwise, we just publish tags.
if drone_branch == "stable":
    repo.create_git_release(tag, name, message)
else:
    repo.create_git_tag(tag, "test", commit_sha, "commit")
    repo.create_git_ref(f"refs/tags/{tag}", commit_sha)
