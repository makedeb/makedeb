local buildAndPublish(a, b, c) = {
    name: "Build and Publish (" + b + " Release)",
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [a]},
    steps: [
        {
            name: "Build Debian Package",
            image: "ubuntu",
            environment: {release_type: a, package_name: c},
            commands: [
                "useradd user",
                "cd src",
                "sudo -u user './makedeb.sh'"
            ]
        },

        {
            name: "Publish to ProGet Repository",
            image: "ubuntu",
            environment: {proget_api_key: "not_today"},
            commands: [".drone/scripts/publish.sh"]
        }
    ]
};

local aurPublish(a, b) = {
    name: "Publish to AUR (" + b + " Release)",
    kind: "pipeline",
    type: "docker",
    depends_on: ["Build and Publish (" + b + " Release)"],

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
    aurPublish("makedeb", "Stable"),
    aurPublish("makedeb-alpha", "Alpha"),
    publishDocker("stable", "Stable"),
    publishDocker("alpha", "Alpha"),
]
