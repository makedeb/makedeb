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
            "sudo chown 'makedeb:makedeb' ../ -R",
            ".drone/scripts/run-unit-tests-drone.sh"
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
            ".drone/scripts/install-deps.sh",
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
            ". \"$HOME/.cargo/env\"",
            ".drone/scripts/user-repo.sh"
        ]
    }]
};

local buildAndPublish(pkgname, tag, image, distro) = {
    name: "build-and-publish-" + tag + "-" + distro,
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
                github_api_key: {from_secret: "github_api_key"}
            },
            commands: [
                "NO_SUDO=1 .drone/scripts/install-deps.sh",
                "useradd -m makedeb",
                "echo 'makedeb ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers",
                "sudo chown 'makedeb:makedeb' ../ /root -R",
                "PUBLISH_GH=1 sudo -Eu makedeb .drone/scripts/build.sh"
            ]
        },

        {
            name: "publish",
            image: "proget.hunterwittenborn.com/docker/makedeb/" + pkgname + ":ubuntu-jammy",
            environment: {
                proget_api_key: {from_secret: "proget_api_key"},
                dpkg_distro: distro
            },
            commands: [
                ".drone/scripts/install-deps.sh",
                ".drone/scripts/publish.py"
            ]
        }
    ]
};

local buildAndPublishLists(pkgname, tag) = [
    buildAndPublish(pkgname, tag, "ubuntu:18.04", "bionic"),
    buildAndPublish(pkgname, tag, "ubuntu:20.04", "focal"),
    buildAndPublish(pkgname, tag, "ubuntu:22.04", "jammy"),
    buildAndPublish(pkgname, tag, "ubuntu:22.10", "kinetic"),
    buildAndPublish(pkgname, tag, "debian:11", "bullseye"),
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