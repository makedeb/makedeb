local buildAndPublish(a, b) = {
    name: "build-and-publish-" + a,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [a]},
    steps: [
        {
            name: "build-debian-package",
            image: "ubuntu",
            environment: {release_type: a, package_name: b},
            commands: [".drone/scripts/build.sh"]
        },

        {
            name: "publish-proget",
            image: "ubuntu",
            environment: {proget_api_key: {from_secret: "proget_api_key"}},
            commands: [".drone/scripts/publish.sh"]
        }
    ]
};

local aurPublish(a, b) = {
    name: "aur-publish-" + b,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [b]},
    depends_on: ["build-and-publish-" + b],

    steps: [
        {
            name: "clone-aur",
            image: "ubuntu",
            environment: {package_name: a},
            commands: [".drone/scripts/aur.sh clone"]
        },

        {
            name: "configure-pkgbuild",
            image: "ubuntu",
            environment: {package_name: a},
            commands: [".drone/scripts/aur.sh configure"]
        },

        {
            name: "push-pkgbuild",
            image: "ubuntu",
            environment: {
                package_name: a,
                aur_ssh_key: {from_secret: "aur_ssh_key"},
                known_hosts: {from_secret: "known_hosts"}
            },
            commands: [".drone/scripts/aur.sh push"]
        }
    ]
};

local publishDocker(a) = {
    name: "docker-publish-" + a,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [a]},
    depends_on: ["aur-publish-" + a],
    steps: [{
        name: "publish-image",
        image: "plugins/docker",
        settings: {
            username: "api",
            password: {from_secret: "proget_api_key"},
            repo: "proget.hunterwittenborn.com/docker/hunter/makedeb",
            tags: a,
            dockerfile: "docker/Dockerfile",
            no_cache: "true"
        }
    }]
};

[
    buildAndPublish("stable", "makedeb"),
    buildAndPublish("alpha", "makedeb-alpha"),
    aurPublish("makedeb", "stable"),
    aurPublish("makedeb-alpha", "alpha"),
    publishDocker("stable"),
    publishDocker("alpha"),
]
