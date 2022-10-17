local runUnitTests(pkgname, tag) = {
    name: "run-unit-tests-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},

    steps: [{
        name: "run-unit-tests",
        image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-jammy",
        environment: {
            release_type: tag,
            pkgname: pkgname
        },
        commands: [
            ".drone/scripts/install-deps.sh",
            "source \"$HOME/.cargo/env\"",
            "sudo chown 'makedeb:makedeb' ../ -R",
            ".drone/scripts/run-unit-tests.sh"
        ]
    }]
};

local createTag(tag) = {
    name: "create-tag-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["run-unit-tests-" + tag],
    steps: [{
        name: tag,
        image: "proget.hunterwittenborn.com/docker/makedeb/makedeb:ubuntu-jammy",
        environment: {
            github_api_key: {from_secret: "github_api_key"}
        },
        commands: [
            ".drone/scripts/create_tag.sh"
        ]
    }]
};

local userRepoPublish(pkgname, tag, user_repo) = {
    name: user_repo + "-publish-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["create-tag-" + tag],
    steps: [{
        name: pkgname,
        image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-jammy",
        environment: {
            ssh_key: {from_secret: "ssh_key"},
            package_name: pkgname,
            release_type: tag,
            target_repo: user_repo
        },
        commands: [
            ".drone/scripts/install-deps.sh",
            "source \"$HOME/.cargo/env\"",
            ".drone/scripts/user-repo.sh"
        ]
    }]
};

local buildAndPublish(pkgname, tag, image, distro, architecture) = {
    name: "build-and-publish-" + tag + "-" + distro + "-" + architecture,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
    depends_on: ["mpr-publish-" + tag],
    steps: [
        {
            name: "build",
            image: image,
            environment: {
                release_type: tag,
                pkgname: pkgname,
                distro: distro,
                architecture: architecture
            },
            commands: [
                ".drone/scripts/install-deps.sh",
                "source \"$HOME/.cargo/env\"",
                "sudo chown 'makedeb:makedeb' ../ -R",
                ".drone/scripts/build.sh"
            ]
        },

        {
            name: "publish",
            image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-jammy",
            environment: {
                proget_api_key: {from_secret: "proget_api_key"},
                dpkg_distro: distro,
                dpkg_architecture: architecture
            },
            commands: [
                ".drone/scripts/install-deps.sh",
                ".drone/scripts/publish.py"
            ]
        }
    ]
};

local buildAndPublishLists(pkgname, tag) = [
    // APT amd64.
    buildAndPublish(pkgname, tag, "ubuntu:18.04", "bionic", "amd64"),
    buildAndPublish(pkgname, tag, "ubuntu:20.04", "focal", "amd64"),
    buildAndPublish(pkgname, tag, "ubuntu:22.04", "jammy", "amd64"),
    buildAndPublish(pkgname, tag, "debian:11", "bullseye", "amd64"),

    // APT arm64.
    buildAndPublish(pkgname, tag, "arm64v8/ubuntu:18.04", "bionic", "arm64"),
    buildAndPublish(pkgname, tag, "arm64v8/ubuntu:20.04", "focal", "arm64"),
    buildAndPublish(pkgname, tag, "arm64v8/ubuntu:22.04", "jammy", "arm64"),
    buildAndPublish(pkgname, tag, "arm64v8/debian:11", "bullseye", "arm64"),

    // APT armhf.
    buildAndPublish(pkgname, tag, "arm32v7/ubuntu:18.04", "bionic", "armhf"),
    buildAndPublish(pkgname, tag, "arm32v7/ubuntu:20.04", "focal", "armhf"),
    buildAndPublish(pkgname, tag, "arm32v7/ubuntu:22.04", "jammy", "armhf"),
    buildAndPublish(pkgname, tag, "arm32v7/debian:11", "bullseye", "armhf"),

    // APT i386.
    // TODO: Ubuntu doesn't publish recent images for this architecture, need to find out why before the Rust changes can make it into stable.
    // See https://bugs.launchpad.net/cloud-images/+bug/1993102.
    buildAndPublish("makedeb", "stable", "i386/ubuntu:18.04", "bionic", "i386"),
    buildAndPublish("makedeb", "stable", "i386/debian:11", "bullseye", "i386"),
];

[
    // Unit tests.
    runUnitTests("makedeb", "stable"),
    runUnitTests("makedeb-beta", "beta"),
    runUnitTests("makedeb-alpha", "alpha"),

    // Tags.
    createTag("stable"),
    createTag("beta"),
    createTag("alpha"),

    // MPR.
    userRepoPublish("makedeb", "stable", "mpr"),
    userRepoPublish("makedeb-beta", "beta", "mpr"),
    userRepoPublish("makedeb-alpha", "alpha", "mpr"),
]
+ buildAndPublishLists("makedeb", "stable")
+ buildAndPublishLists("makedeb-beta", "beta")
+ buildAndPublishLists("makedeb-alpha", "alpha")