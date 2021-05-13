// Function - Build and Publish 
local buildAndPublish(nameCap, name) = {
  name: "Build and Publish (" + nameCap + " Release)",
  kind: "pipeline",
  type: "docker",
  trigger: {
    branch: name
  },
  steps: [
    {
      name: "build",
      image: "ubuntu",
      environment: {
        release_type: name,
        DEBIAN_FRONTEND: "noninteractive"
      },
      commands: [ "scripts/build.sh" ]
    },

    {
      name: "publish",
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
]
