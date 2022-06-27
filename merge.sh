#!/bin/sh

# 0) checkout
mkdir REPO_NAME
cd REPO_NAME
#git clone https://github.com/cognitranlimited/REPO_NAME ./REPO_NAME
git clone https://github.com/zlolek/sandbox ./sandbox
git fetch origin

# 1) merge branch to master
git checkout main     
git merge origin/hotfix2
git push origin main

# 2) tag
git tag hotfix112
git push --tags

# 3) merge master to develop
git checkout develop  
git merge origin/main
git push origin develop

# 4) delete ##git push command with --delete flag, followed by the name of the branch you want to delete
git push origin --delete hotfix2




pipeline {
    agent {
        label 'master'
    }
    
    options {
        skipDefaultCheckout()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }
    stages {
        stage('Retag') {

            steps {
                script {
                    withCredentials(
                        [
                            usernamePassword(credentialsId: 'cognitran-github', usernameVariable: 'GITHUB_USER', passwordVariable: 'GITHUB_TOKEN'),
                        ]
                    ) {
                     sh '''#!/bin/bash
                             rm -Rf /mnt/xvdf/jenkins/jobs/jlr-otx-promote-branch/workspace/*
                             git clone https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/cognitranlimited/${REPO_NAME}
                             pwd
                             ls -ltr
                             cd ${REPO_NAME}
                             pwd
                             ls -ltr
                             git --version
                             
                             git checkout master
                             git branch
                             git status
                             
                             git merge origin/${TYPE_REF}${RELEASE_REF}
                             git push origin master
                             # TAG
                             git tag ${RELEASE_REF}
                             git push --tags
                             # MERGE master to develop
                             git checkout develop
                             git merge origin/master
                             git push origin develop
                             #DELETE OLD BRANCH
                             git push origin --delete ${TYPE_REF}${RELEASE_REF}
                     '''
                    }
                }
            }
        }
    }
}
