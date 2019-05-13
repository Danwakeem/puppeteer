workflow "CD" {
  on = "release"
  resolves = ["Push Version Image"]
}

action "Build Image" {
  uses = "actions/docker/cli@c08a5fc9e0286844156fefff2c141072048141f6"
  runs = "build -t danwakeem/puppeteer ."
}

action "Docker Registry Login" {
  uses = "actions/docker/login@c08a5fc9e0286844156fefff2c141072048141f6"
  env = {
    DOCKER_USERNAME = "danwakeem"
  }
  secrets = ["DOCKER_PASSWORD"]
}

action "Push Latest Image" {
  uses = "actions/docker/cli@c08a5fc9e0286844156fefff2c141072048141f6"
  needs = ["Build Image", "Docker Registry Login"]
  args = "push danwakeem/puppeteer:latest"
}

action "Set Version" {
  uses = "docker://node:10-alpine"
  runs = "export"
  args = "VERSION=$(yarn --silent run version)"
}

action "Create Version Tag" {
  uses = "actions/docker/tag@c08a5fc9e0286844156fefff2c141072048141f6"
  needs = ["Build Image", "Set Version"]
  args = "danwakeem/puppeteer danwakeem/puppeteer:$VERSION"
}

action "Push Version Image" {
  uses = "actions/docker/cli@c08a5fc9e0286844156fefff2c141072048141f6"
  needs = ["Push Latest Image", "Create Version Tag"]
  args = "push danwakeem/puppeteer:$VERSION"
}
