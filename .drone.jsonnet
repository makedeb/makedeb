// Function - Set PKGBUILD functions for PKGBUILDs in src/PKGBUILDs
local configurePKGBUILD() = {
  name: "Configure PKGBUILDs",
  kind: "pipeline",
  type: "docker",
  clone: { disable: true },
  image_pull_secrets: [ "nexus_repository_docker_login" ],
  steps: [
    {
      name: "Clone",
      image: "docker.hunterwittenborn.com/hwittenborn/drone-git",
      settings: { action: "clone" }
    },

    {
      name: "Set Variables in PKGBUILDs",
      image: "ubuntu",
      commands: [ "scripts/pkgbuild_gen.sh" ]
    },

    {
      name: "Push Modified PKGBUILDs Back to GitHub",
      image: "docker.hunterwittenborn.com/hwittenborn/drone-git",
      settings: {
        action: "push",
        username: "kavplex",
        password: { from_secret: "kavplex_github_pat"},
        message: "Updated version in PKGBUILDs"
      }
    }
  ]
};

// Function - Build and Publish
local buildAndPublish(nameCap, name) = {
  name: "Build and Publish to APT Repository (" + nameCap + " Release)",
  kind: "pipeline",
  type: "docker",
//  clone: { disable: true },
  depends_on: [ "Configure PKGBUILDs" ],
  trigger: {
    branch: name
  },
  steps: [
//    githubClone(),
    {
      name: "Build",
      image: "ubuntu",
      environment: {
        release_type: name,
        DEBIAN_FRONTEND: "noninteractive"
      },
      commands: [ "scripts/build.sh" ]
    },

    {
      name: "Publish",
      image: "ubuntu",
      environment: {
        nexus_repository_password: {
          from_secret: "nexus_repository_password"
        },
        DEBIAN_FRONTEND: "noninteractive"
      },
      commands: [ "scripts/publish.sh" ]
    }
  ]
};

// Function - Make GitHub Release
local makeGitHubRelease() = {
  name: "Publish GitHub Release",
  kind: "pipeline",
  type: "docker",
  depends_on: [ "Build and Publish to APT Repository (Stable Release)" ],
  trigger: {
    branch: "stable"
  },
  steps: [
    {
      name: "build",
      image: "ubuntu",
      environment: {
        DEBIAN_FRONTEND: "noninteractive"
      },
      commands: [ "scripts/build.sh" ]
    },

    {
      name: "publish",
      image: "ubuntu",
      environment: {
        kavplex_github_pat: {
          from_secret: "kavplex_github_pat"
        }
      },
      commands: [ "scripts/github_release.sh" ]
    }
  ]
};

// Run Functions
[
  configurePKGBUILD(),
  buildAndPublish("Stable", "stable"),
  buildAndPublish("Alpha", "alpha"),
  makeGitHubRelease(),
]
