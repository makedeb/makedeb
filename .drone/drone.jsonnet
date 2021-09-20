local createTag(tag) = {
	name: "create-tag-" + tag,
	kind: "pipeline",
	type: "docker",
	trigger: {branch: [tag]},

	steps: [{
		name: tag,
		image: "proget.hunterwittenborn.com/docker/hunter/makedeb:stable",
		environment: {
			ssh_key: {from_secret: "ssh_key"},
			known_hosts: {from_secret: "known_hosts"},
			release_type: tag
		},

		commands: [".drone/scripts/create_tag.sh"]
	}]
};

local buildAndPublish(package_name, tag) = {
    name: "build-and-publish-" + tag,
    kind: "pipeline",
    type: "docker",
    trigger: {branch: [tag]},
	depends_on: ["create-tag-" + tag],
    steps: [
        {
            name: "build-debian-package",
            image: "proget.hunterwittenborn.com/docker/hunter/makedeb:alpha",
            environment: {release_type: tag, package_name: package_name},
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

local userRepoPublish(package_name, tag, user_repo) = {
	name: user_repo + "-publish-" + tag,
	kind: "pipeline",
	type: "docker",
	trigger: {branch: [tag]},
	depends_on: [
		"build-and-publish-" + tag,
		"create-tag-" + tag
	],

	steps: [{
		name: package_name,
		image: "proget.hunterwittenborn.com/docker/hunter/makedeb:stable",
		environment: {
			ssh_key: {from_secret: "ssh_key"},
			known_hosts: {from_secret: "known_hosts"},
			package_name: package_name,
			release_type: tag,
			target_repo: user_repo
		},

		commands: [".drone/scripts/user-repo.sh"]
	}]
};

[
	createTag("stable"),
	createTag("beta"),
	createTag("alpha"),

    buildAndPublish("makedeb", "stable"),
    buildAndPublish("makedeb-beta", "beta"),
    buildAndPublish("makedeb-alpha", "alpha"),

	userRepoPublish("makedeb", "stable", "mpr"),
	userRepoPublish("makedeb-beta", "beta", "mpr"),
	userRepoPublish("makedeb-alpha", "alpha", "mpr"),

	userRepoPublish("makedeb", "stable", "aur"),
	userRepoPublish("makedeb-beta", "beta", "aur"),
	userRepoPublish("makedeb-alpha", "alpha", "aur"),
]
