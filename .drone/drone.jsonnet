local buildAndPublish(a, b) = {
    name: "build-and-publish-" + b,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [b]},
    steps: [
        {
            name: "build-debian-package",
            image: "proget.hunterwittenborn.com/docker/hunter/makedeb:stable",
            environment: {release_type: b, package_name: a},
            commands: [".drone/scripts/build.sh"]
        },

        {
            name: "publish-proget",
            image: "proget.hunterwittenborn.com/docker/hunter/makedeb:stable",
            environment: {proget_api_key: {from_secret: "proget_api_key"}},
            commands: [".drone/scripts/publish.sh"]
        }
    ]
};

local userRepoPublish(a, b, c) = {
	name: c + "-publish-" + b,
	kind: "pipeline",
	type: "docker",
	trigger: {branch: [b]},
	depends_on: ["build-and-publish-" + b],

	steps: [{
		name: a,
		image: "proget.hunterwittenborn.com/docker/hunter/makedeb:stable",
		environment: {
			ssh_key: {from_secret: "ssh_key"},
			known_hosts: {from_secret: "known_hosts"},
			package_name: a,
			release_type: b,
			target_repo: c
		},

		commands: [".drone/scripts/user-repo.sh"]
	}]
};

local publishDocker(a) = {
    name: "docker-publish-" + a,
    kind: "pipeline",
    type: "docker",
    volumes: [{name: "docker", host: {path: "/var/run/docker.sock"}}],
    trigger: {branch: [a]},
    depends_on: [
		"mpr-publish-" + a,
		"aur-publish-" + a
	],
    steps: [
        {
            name: "configure-dockerfile",
            image: "ubuntu",
            environment: {release_type: a},
            commands: [".drone/scripts/dockerfile-config.sh"]
        },

        {
            name: "publish-image",
            image: "plugins/docker",
            volumes: [{name: "docker", path: "/var/run/docker.sock"}],
            settings: {
                username: "api",
                password: {from_secret: "proget_api_key"},
                repo: "proget.hunterwittenborn.com/docker/hunter/makedeb",
                registry: "proget.hunterwittenborn.com",
                tags: a,
                dockerfile: "docker/Dockerfile",
                no_cache: "true"
            }
        }
    ]
};

[
    buildAndPublish("makedeb", "stable"),
    buildAndPublish("makedeb-beta", "beta"),
    buildAndPublish("makedeb-alpha", "alpha"),

	userRepoPublish("makedeb", "stable", "mpr"),
	userRepoPublish("makedeb-beta", "beta", "mpr"),
	userRepoPublish("makedeb-alpha", "alpha", "mpr"),

	userRepoPublish("makedeb", "stable", "aur"),
	userRepoPublish("makedeb-beta", "beta", "aur"),
	userRepoPublish("makedeb-alpha", "alpha", "aur"),

    publishDocker("stable"),
    publishDocker("beta"),
    publishDocker("alpha"),
]
