// Function - Git Clone
local githubClone() = {
  name: "Clone",
  image: "ubuntu",
  environment: { DEBIAN_FRONTEND: "noninteractive" },
  commands: [ "scripts/github_pull.sh" ]
};

// Function - Set PKGBUILD functions for PKGBUILDs in src/PKGBUILDs
local configurePKGBUILD() = {
  name: "Configure PKGBUILDs",
  kind: "pipeline",
  type: "docker",
  clone: { disable: true },
  steps: [
    githubClone(),
    {
      name: "Set Variables in PKGBUILDs",
      image: "ubuntu",
      commands: [ "scripts/pkgbuild_gen.sh" ]
    }
  ]
};

// Function - Build and Publish
local buildAndPublish(nameCap, name) = {
  name: "Build and Publish to APT Repository (" + nameCap + " Release)",
  kind: "pipeline",
  type: "docker",
  clone: { disable: true },
  depends_on: [ "Configure PKGBUILDs" ],
  trigger: {
    branch: name
  },
  steps: [
    githubClone(),
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
  depends_on: [ "Build and Publish (Stable Release)" ],
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
  buildAndPublish("Stable", "stable"),
  buildAndPublish("Alpha", "alpha"),
  makeGitHubRelease(),
  configurePKGBUILD(),
]
