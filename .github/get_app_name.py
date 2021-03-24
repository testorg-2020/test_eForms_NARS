import os

os.chdir(os.environ["GITHUB_WORKSPACE"])

f = open("local.yml", "r")
for line in f.readlines():
if line.startswith("- name:"):
  print("app_name=" + line.split(":")[1].strip())
f.close()
