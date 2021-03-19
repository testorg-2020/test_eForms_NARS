# RUN apt-get update -y
# RUN apt-get install -y wget gnupg2
# RUN wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
# RUN echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
# RUN apt-get update -y
# RUN apt-get install cf-cli -y
# RUN cf install-plugin cflocal -f

apt-get update -y
apt-get install -y wget gnupg2
wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | apt-key add -
echo "deb https://packages.cloudfoundry.org/debian stable main" | tee /etc/apt/sources.list.d/cloudfoundry-cli.list
apt-get update -y
apt-get install cf-cli -y
cf install-plugin cflocal -f
