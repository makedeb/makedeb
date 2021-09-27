local createTag(tag) = {
	name: "create-tag-" + tag,
	kind: "pipeline",
	type: "docker",
	trigger: {branch: [tag]},

	steps: [{
		name: tag,
		image: "proget.hunterwittenborn.com/docker/makedeb/makedeb-alpha:ubuntu-focal",
		environment: {
			ssh_key: {from_secret: "ssh_key"},
			known_hosts: {from_secret: "known_hosts"},
			release_type: tag
		},

		commands: [
			"sudo apt-get install openssh-client git -y",
			".drone/scripts/create_tag.sh"
		]
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
            image: "proget.hunterwittenborn.com/docker/makedeb/makedeb-alpha:ubuntu-focal",
            environment: {release_type: tag, package_name: package_name},
            commands: [
							"sudo apt-get install sed grep mawk git -y",
							".drone/scripts/build.sh"
						]
        },

        {
            name: "publish-proget",
            image: "proget.hunterwittenborn.com/docker/makedeb/makedeb-alpha:ubuntu-focal",
            environment: {proget_api_key: {from_secret: "proget_api_key"}},
            commands: [
							"sudo apt-get install sed grep curl findutils -y",
							".drone/scripts/publish.sh"
						]
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
		image: "proget.hunterwittenborn.com/docker/makedeb/makedeb-alpha:ubuntu-focal",
		environment: {
			ssh_key: {from_secret: "ssh_key"},
			known_hosts: {from_secret: "known_hosts"},
			package_name: package_name,
			release_type: tag,
			target_repo: user_repo
		},

		commands: [
			"sudo apt-get install git ssh grep mawk sed -y",
			".drone/scripts/user-repo.sh"
		]
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
