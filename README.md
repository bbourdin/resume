# Benoit Bourdin

[Click here to access to my resume](https://github.dxc.com/pages/bbourdin/resume/)

## This resume as code / the DevOps way

Detailing here how this resume is built from one single source code on GitHub, leveraging a CI/CD pipeline, automated testing and our DevOps principles to generate multiple artifacts (HTML, PDF, Word, PPT...).

### Source code

* [Benoit-Bourdin-resume.rmd.j2](Benoit-Bourdin-resume.rmd.j2): my full resume under the [R markdown format](https://rmarkdown.rstudio.com/gallery.html), making data science beautiful and leveraging the [VisualResume library](https://github.com/ndphillips/VisualResume).
* [Benoit-Bourdin-slide.md.j2](Benoit-Bourdin-slide.md.j2): a short summary of my profile under the [Marp markdown presentation format](https://marp.app/)
* [resume-data.yml](resume-data.yml): values of placeholders to be replaced in above two files, to keep any sensible information sensible to DXC hosted in a [separated repository](https://github.dxc.com/bbourdin/resume-dxc-data).

### CI/CD configuration as code

Source code available here:

* [Jenkinsfile](Jenkinsfile)
* GitHub actions (in progress)

### pipeline steps

#### Replacing placeholders

* We use the [vikingco/jinja2cli](https://hub.docker.com/r/vikingco/jinja2cli) docker image to run the [Jinja2 CLI](https://github.com/mattrobenolt/jinja2-cli) and easily replace placeholders defined in the `j2` files by values defined in a `yml` file.

#### Automated testing

* We do the following tests:
  * linting of the yaml files with [yamllint](https://hub.docker.com/r/pipelinecomponents/yamllint)
  * linting of the markdown files with [markdownlint](https://hub.docker.com/r/pipelinecomponents/markdownlint) - [configuration here](.mdlint-style.rb)
  * spell check using mdspell installed from this [Dockerfile](Dockerfile.rmarkdown) and using `.spelling` files from the 2 repositories.

#### Run R for the full resume

* [R is nice for data science](https://www.r-graph-gallery.com/).
* To make Data on the DevOps way, we use the [rocker/r-rmd](https://hub.docker.com/r/rocker/r-rmd) docker image (based on Ubuntu) to run R inside a container started by the pipeline.
* To get all the packages we need (including [VisualResume](https://github.com/ndphillips/VisualResume)), we needed a customized [Dockerfile](Dockerfile.rmarkdown).
* In this case, we use R markdown for rendering, which is using [Pandoc](https://pandoc.org/) for conversion.

#### Run Marp for a profile slide

* [Marp is nice for presentation as code using markdown](https://marp.app/).
* To make it on the DevOps way, we use the [marpteam/marp-cli](https://hub.docker.com/r/marpteam/marp-cli) docker image to run it inside the pipeline.

#### Publishing

* The content is pushed to the `gh-pages` branch, then served by [GitHub pages](https://pages.github.com/).
