import os
import re

def only_allowed_characters(inputString):
    return "".join(re.split("[^a-zA-Z0-9_-]*", inputString))

os.chdir(os.environ["GITHUB_WORKSPACE"])

f = open("local.yml", "r")
for line in f.readlines():
    if line.startswith("- name:"):
        name_from_local_yml = line.split(":")[1].strip()
        app_name = only_allowed_characters(name_from_local_yml)
        print("app_name=" + app_name)
f.close()
