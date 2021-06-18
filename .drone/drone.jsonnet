local customClone() = {
        name: "Clone",
        image: "drone/git"
};

local buildAndPublish(a, b, c) = {
    name: "Build and Publish (" + b + " Release)",
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [a]},
    clone: {disable: true},
    steps: [
        {
            custom_clone()
        },

        {
            name: "Build Debian Package",
            image: "ubuntu",
            environment: {release_type: a, package_name: c},
            commands: [".drone/scripts/build.sh"]
        },

        {
            name: "Publish to ProGet Repository",
            image: "ubuntu",
            environment: {proget_api_key: "not_today"},
            commands: [".drone/scripts/publish.sh"]
        }
    ]
};

local aurPublish(a, b, c) = {
    name: "Publish to AUR (" + c + " Release)",
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [b]},
    depends_on: ["Build and Publish (" + c + " Release)"],

    steps: [
        {
            name: "Clone Package",
            image: "ubuntu",
            environment: {
                package_name: a
            },
            commands: [".drone/scripts/aur.sh clone"]
        },

        {
            name: "Configure PKGBUILD",
            image: "ubuntu",
            environment: {
                package_name: a
            },
            commands: [".drone/scripts/aur.sh configure"]
        },

        {
            name: "Push PKGBUILD Changes",
            image: "ubuntu",
            environment: {
                package_name: a
            },
            commands: [".drone/scripts/aur.sh push"]
        }
    ]
};

local publishDocker(a, b) = {
    name: "Publish Docker Image (" + b + " Release)",
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [a]},
    depends_on: ["Publish to AUR (" + b + " Release)"],
    steps: [{
        name: "Publish Image",
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
    buildAndPublish("stable", "Stable", "makedeb"),
    buildAndPublish("alpha", "Alpha", "makedeb-alpha"),
    aurPublish("makedeb", "stable", "Stable"),
    aurPublish("makedeb-alpha", "alpha", "Alpha"),
    publishDocker("stable", "Stable"),
    publishDocker("alpha", "Alpha"),
]
