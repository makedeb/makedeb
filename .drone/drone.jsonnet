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
            environment: {proget_api_key: "not_today"},
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
            environment: {
                package_name: a
            },
            commands: [".drone/scripts/aur.sh clone"]
        },

        {
            name: "configure-pkgbuild",
            image: "ubuntu",
            environment: {
                package_name: a
            },
            commands: [".drone/scripts/aur.sh configure"]
        },

        {
            name: "push-pkgbuild",
            image: "ubuntu",
            environment: {
                package_name: a
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
        image: "",
        settings: {
            username: "api",
            password: "big_old_lie",
            repo:"",
            tags: a
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
