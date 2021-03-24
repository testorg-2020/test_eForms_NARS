import os

app_name = os.environ["APP_NAME"]
repo = lower(os.environ["GITHUB_REPOSITORY"])
run_id = os.environ["GITHUB_RUN_ID"]

print("docker_tag=ghcr.io/" + repo + "/" + app_name + ":" + run_id)
