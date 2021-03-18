FROM cloudfoundry/cflinuxfs3

ENV R_LIBS_USER=/opt/Rlib

echo "set-up install"
RUN apt update && \
  apt install software-properties-common -y && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
  add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/' && \
  apt update

echo "start install"
RUN apt install -y --no-install-recommends r-base
echo "finished base install"

RUN R -e "install.packages('shiny', 'shinyjs', 'purr', 'RJSONIO', 'stringr', 'writexl',
          'zip', 'zhinyBS', 'kableExtra', 'knitr', 'rmarkdown')"
echo "finished installing dependencies"
