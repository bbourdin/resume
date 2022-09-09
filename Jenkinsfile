pipeline {
	agent any

	options {
		timestamps()
		timeout(time: 30, unit: 'MINUTES')   // timeout of 30mn for every play
		disableConcurrentBuilds()
	}

	stages {
		// pre-processing stages
		// load DXC variables, only applicable on DXC side
		stage('checkout the resume-dxc-data') {
			steps {
				sh 'mkdir -p dxc-data'
				dir('dxc-data') {
					git branch: 'master',
						credentialsId: 'pdxc-jenkins',
						url: 'https://github.dxc.com/bbourdin/resume-dxc-data.git'
					sh "ls -latr"
				}
				stash includes: "dxc-data/**", name: 'dxc_data'
			}
		}

				// testing of yaml files
		stage('Lint - yaml files') {
			agent {
				docker {
					image "pipelinecomponents/yamllint:latest"
					args '-u="root" -v $WORKSPACE:/srv/lint -w /srv/lint --entrypoint=""'
				}
			}
			steps {
				unstash 'dxc_data'
				echo "Linting of yaml files"
				sh '''
				yamllint -v
				yamllint *.yml dxc-data/*.yml
				'''
			}
		}

		// github action: https://github.com/cuchi/jinja2-action
		// doing with default only for testing 
		stage('Replace data (default)') {
			agent {
				docker {
					image 'vikingco/jinja2cli:latest'
					registryCredentialsId 'dockerhub_bbourdin'
					args '--entrypoint=""'
				}
			}
			steps {
				// on DXC side, only for testing
				sh "jinja2 Benoit-Bourdin-resume.rmd.j2 resume-data.yml > Benoit-Bourdin-resume.rmd"
				sh "jinja2 Benoit-Bourdin-slide.md.j2 resume-data.yml > Benoit-Bourdin-slide.md"
				sh "ls -latr"
			}
		}

		stage('Replace data (DXC)') {
			agent {
				docker {
					image 'vikingco/jinja2cli:latest'
					registryCredentialsId 'dockerhub_bbourdin'
					args '--entrypoint=""'
				}
			}
			steps {
				unstash 'dxc_data'
				// only applicable on DXC side
				sh "jinja2 Benoit-Bourdin-resume.rmd.j2 dxc-data/resume-data.yml > Benoit-Bourdin-resume.rmd"
				sh "jinja2 Benoit-Bourdin-slide.md.j2 dxc-data/resume-data.yml > Benoit-Bourdin-slide.md"
				sh "ls -latr"
				stash includes: "Benoit-Bourdin-resume.rmd,Benoit-Bourdin-slide.md", name: 'r_input'
			}
		}

			// testing of markdown files
		stage('Lint - markdown files') {
			agent {
				docker {
					image "pipelinecomponents/markdownlint:latest"
					args '-u="root" -v $WORKSPACE:/srv/lint -w /srv/lint --entrypoint=""'
				}
			}
			steps {
				unstash 'r_input'
				echo "Linting of markdown files"
				sh '''
				mdl -V
				mdl Benoit-Bourdin-resume.rmd Benoit-Bourdin-slide.md README.md
				'''
			}
		}

		// check spelling
		stage('Spell Check') {
			agent {
				dockerfile {
					filename 'Dockerfile.spell'
					args '-u="root" -v $WORKSPACE:/srv/spell -w /srv/spell --entrypoint=""'
				}
			}
			steps {
				unstash 'r_input'
				unstash 'dxc_data'
				echo "Spell Check"
				sh '''
				mdspell -V
				cat dxc-data/.spelling >> .spelling
				find . -name "*.md" -o -name "*.rmd" | xargs mdspell -n -a -r --en-us --dictionary dictionary/en_US-large
				'''
			}
		}
		
		// processing
		stage('Marp') {
			agent {
				docker {
					image 'marpteam/marp-cli'
					registryCredentialsId 'dockerhub_bbourdin'
					args '-u="root" -v $WORKSPACE:/home/marp/app/ -w /home/marp/app -e LANG=$LANG --entrypoint=""'
				}
			}
			 steps {
				unstash 'r_input'
				unstash 'dxc_data'
				sh '''
				alias marp="node /home/marp/.cli/marp-cli.js"
				export PUPPETEER_TIMEOUT=0   # to solve this issue: https://github.com/marp-team/marp-vscode/issues/319
				marp Benoit-Bourdin-slide.md
                marp --pptx --allow-local-files Benoit-Bourdin-slide.md
				marp --pdf --allow-local-files Benoit-Bourdin-slide.md
				marp --image png --allow-local-files Benoit-Bourdin-slide.md
				ls -latr
				rm -rf output
				mkdir -p output/
				mv Benoit-Bourdin-slide.html Benoit-Bourdin-slide.pptx Benoit-Bourdin-slide.pdf Benoit-Bourdin-slide.png output/
				'''
				stash includes: "output/**", name: 'p_docs'
			 }
		}
		
		stage('R markdown') {
			agent {
				dockerfile {
					filename "Dockerfile.rmarkdown"
					registryCredentialsId 'dockerhub_bbourdin'
					args '-u="root" -v $WORKSPACE:/work -w /work --entrypoint=""'
				}
			}
			 steps {
				unstash 'r_input'
				unstash 'p_docs'
				sh '''
                ls -latr
				mv -f output/Benoit-Bourdin-slide.png .
				find /work
				cp -f /work/*.sty .
                R -e \'rmarkdown::render("Benoit-Bourdin-resume.rmd",output_format="all")\'
                ls -latr
				rm -rf output
				mkdir -p output/
				mv -f Benoit-Bourdin-resume.html index.html
				mv index.html Benoit-Bourdin-resume.md Benoit-Bourdin-resume.pdf Benoit-Bourdin-resume.docx resume-timeline.png Benoit-Bourdin-resume_files output/
				'''
				stash includes: "output/**", name: 'r_docs'
			 }
		}

		// publishing - only adapted to DXC GitHub
		stage ('publish to github pages') {
			environment {
				REPO_PATH="bbourdin/resume.git";
				TARGET_BRANCH = "${env.BRANCH_NAME == 'main' ? 'gh-pages' : 'develop-gh-pages'}"
			}
			when {
				anyOf {
					// We only publish when on main or develop branches
					branch 'main';
					branch 'master';
					branch 'develop'
				}
			}
			steps {
				sh "mkdir -p published"
				dir("published") {
					git branch: TARGET_BRANCH,
						credentialsId: 'pdxc-jenkins',
						url: "https://github.dxc.com/$REPO_PATH"
				}
				unstash 'r_docs'
				unstash 'p_docs'
				sh "rm -rf published/Benoit-Bourdin-resume_files published/img"
				sh "mv img published/"
				sh "mv output/* published/"
				dir("published") {
					withCredentials ([usernamePassword(credentialsId: 'pdxc-jenkins-github', usernameVariable: 'GIT_USER', passwordVariable: 'GIT_PASSWORD')]) {
						sh '''
							git remote set-url origin https://${GIT_USER}:${GIT_PASSWORD}@github.dxc.com/$REPO_PATH
							git config user.email "${GIT_USER}@dxc.com"
							git config user.name "${GIT_USER}"
							git add .
							git commit -m "publishing resume output" || exit 0
							git push https://${GIT_USER}:${GIT_PASSWORD}@github.dxc.com/$REPO_PATH HEAD:${TARGET_BRANCH}
						'''
					}
				}
			}
		} // stage publish script
	} // stages
} // pipeline
