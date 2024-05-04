pipeline {
  agent {
    dockerfile true
  }
  parameters {
      string(name: 'GLOBAL_IMAGE_TAG', defaultValue: '')
  }

  options {
    timeout(time: 20, unit: 'MINUTES')
  }

  environment {
      gitDevelopmentBranch = "development"

  }


    stages {

      stage ('Init') {

         when {
               beforeAgent true

               anyOf {
                   triggeredBy cause: "UserIdCause"
                   expression { env.gitlabActionType == 'MERGE' && env.gitlabMergeRequestState == 'opened' && env.gitlabTargetBranch == env.gitDevelopmentBranch }
                   expression { env.gitlabSourceBranch == env.gitDevelopmentBranch && env.gitlabTargetBranch == env.gitDevelopmentBranch }
               }

         }
          steps {
              script {
                  env.JAVA_HOME = '/opt/java/openjdk'
                  env.GLOBAL_IMAGE_TAG = 'TEST'
                  try{
                    if(env.gitlabSourceBranch != null && env.gitlabTargetBranch != null){
                        env.sourceBranch = env.gitlabSourceBranch
                        env.targetBranch = env.gitlabTargetBranch
                    }
                  } catch (err) {
                    echo err.getMessage()
                    echo "Error setting variables, but we will continue."
                  }
              }
          }
      }


       stage('checkout') {

         when {
               beforeAgent true

               anyOf {
                   triggeredBy cause: "UserIdCause"
                   expression { env.gitlabActionType == 'MERGE' && env.gitlabMergeRequestState == 'opened' && env.gitlabTargetBranch == env.gitDevelopmentBranch }
                   expression { env.gitlabSourceBranch == env.gitDevelopmentBranch && env.gitlabTargetBranch == env.gitDevelopmentBranch }
               }


         }

          steps {
            echo "checkout branch: $sourceBranch"
            echo "Init result: ${currentBuild.result}"
            echo "Init currentResult: ${currentBuild.currentResult}"
            echo "env.GLOBAL_IMAGE_TAG: ${env.GLOBAL_IMAGE_TAG}"

            checkout changelog: true,
                    poll: true,
                    scm: [$class: 'GitSCM',
                          branches: [[name: 'origin/${sourceBranch}']],
                          browser: [$class: 'GitLab', repoUrl: 'https://gitlab2.robosoftin.com/tatamf-microservices/nextgenmf-admin.git', version: '11.11'],
                          doGenerateSubmoduleConfigurations: false,
                          extensions:  [[$class: 'GitLFSPull'],[$class: 'LocalBranch', localBranch: '**'],[$class: 'CleanBeforeCheckout']],
                          submoduleCfg: [],
                          userRemoteConfigs: [[credentialsId: 'c07b5d19-6de4-4206-9d39-6bf153500894', url: 'git@gitlab2.robosoftin.com:tatamf-microservices/nextgenmf-admin.git']]
                    ]

             sh 'printenv'
          }

       }

       stage('build') {

         when {
               beforeAgent true

              anyOf {
                  triggeredBy cause: "UserIdCause"
                  expression { env.gitlabActionType == 'MERGE' && env.gitlabMergeRequestState == 'opened' && env.gitlabTargetBranch == env.gitDevelopmentBranch }
                  expression { env.gitlabSourceBranch == env.gitDevelopmentBranch && env.gitlabTargetBranch == env.gitDevelopmentBranch }
              }

         }
        environment {
            ENC_PASSWORD=credentials('ENC_PASSWORD')
        }
          steps {

               echo 'Notify GitLab'
               updateGitlabCommitStatus name: 'build', state: 'pending'


               script {
                 env.GRADLE_OPTS = ''
               }
               sh "chmod +x gradlew"
               sh './gradlew clean build  -x test'

               updateGitlabCommitStatus name: 'build', state: 'success'

             }

       }

       stage(image){

         when {
               beforeAgent true
              anyOf {
                  triggeredBy cause: "UserIdCause"
                  expression { env.gitlabSourceBranch == env.gitDevelopmentBranch && env.gitlabTargetBranch == env.gitDevelopmentBranch }
              }
         }
        environment {
            HARBOR_CREDS=credentials('0b07deb4-ab09-4d12-94c1-de590a4a10fc')
        }
          steps{

           updateGitlabCommitStatus name: 'image', state: 'pending'
           script{
               sh "chmod +x gradlew"
               env.GRADLE_OPTS = ''

               def SVC_VER = env.BUILD_NUMBER

               def SVC_NAME = sh (
                       script: '''
                               SVC_NAME=`./gradlew getApplicationName | grep "ApplicationName:" | cut -d':' -f2`
                               echo ${SVC_NAME}
                               ''',
                       returnStdout: true
               ).trim()

               def DEPLOY_ENV='prod'

              //  def DEPLOY_ENV1='uat'

              //  def DEPLOY_ENV2='prod'

               def IMAGE_TAG = "${SVC_VER}-${DEPLOY_ENV}"

              //  def IMAGE_TAG1 = "${SVC_VER}-${DEPLOY_ENV1}"

              //  def IMAGE_TAG2 = "${SVC_VER}-${DEPLOY_ENV2}"

               env.GLOBAL_IMAGE_TAG = IMAGE_TAG

               withDockerRegistry(credentialsId: '0b07deb4-ab09-4d12-94c1-de590a4a10fc', url: 'https://camelotdev-harbor.robosoftin.com:8443') {
                 echo "Connectecd to docker"
                 sh '''
                     echo "Perform deploy..."
                     '''
                 sh ("""
                     ./gradlew jib --image=camelotdev-harbor.robosoftin.com:8443/nextgenmf/${SVC_NAME}:${IMAGE_TAG} -Djib.allowInsecureRegistries=true -Djib.to.auth.username=${HARBOR_CREDS_USR}  -Djib.to.auth.password=${HARBOR_CREDS_PSW}
                     """)
               }
           }
           updateGitlabCommitStatus name: 'image', state: 'success'

          }
       }
    }
 } 
