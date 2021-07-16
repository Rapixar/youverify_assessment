pipeline {
    agent any
    environment {
        //variable for image name
        PROJECT = "youverify_assessment"
        APP = "customer-service"
		NAMESPACE = "youverify"
    }
    tools {
        maven 'mvn339'
        jdk 'jdk8'
    }
    stages {
        stage ('Initialize') {
            steps {
                deleteDir()
                googlechatnotification (url: 'https://chat.googleapis.com/v1/spaces/AAAAWOYgloM/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=ZMebLi9FSS_m2weO0mNx2b7nsZk_YyTMZm8F12B5r3c%3D', message: "Initializing build process for *${env.JOB_NAME}* ...")
            }
        }
        stage ('Clean WorkSpace') {
            steps {
                checkout scm
            }
        }
        stage ("Installing Dependencies and Building"){
            steps {
                script{
                    env.VERSION = env.OLD_VERSION + '-' + env.BUILD_NUMBER
                    echo "Building ${env.BRANCH_NAME} for BioRegistra portal"
                    try {
                        if(env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'origin/master' || env.GIT_BRANCH == 'origin/master' || env.GIT_BRANCH == 'master'  ) {
                           googlechatnotification (url: 'https://chat.googleapis.com/v1/spaces/AAAAuvIDdoQ/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=I7VzE4LUOmrrhTt_jmDoiAJwbAI0z70DqfiJ6eOBvUY%3D', message: "Build Initialized, Installing & Building Prod *${env.JOB_NAME}* ...")
                            sh '''
                                pwd
                                npm set registry https://registry.npmjs.org
                                npm get registry
                                npm install
                                '''
                            googlechatnotification (url: 'https://chat.googleapis.com/v1/spaces/AAAAuvIDdoQ/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=I7VzE4LUOmrrhTt_jmDoiAJwbAI0z70DqfiJ6eOBvUY%3D', message: "Build Successful *${env.JOB_NAME}*")
                        } else {
                            googlechatnotification (url: 'https://chat.googleapis.com/v1/spaces/AAAAuvIDdoQ/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=I7VzE4LUOmrrhTt_jmDoiAJwbAI0z70DqfiJ6eOBvUY%3D', message: "Build Initialized, Installing & Building Staging *${env.JOB_NAME}* ...")
                            sh '''
                                pwd
                                npm set registry https://registry.npmjs.org
                                npm get registry
                                npm install
                                '''
                            googlechatnotification (url: 'https://chat.googleapis.com/v1/spaces/AAAAuvIDdoQ/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=I7VzE4LUOmrrhTt_jmDoiAJwbAI0z70DqfiJ6eOBvUY%3D', message: "Build Successful *${env.JOB_NAME}*, ${env.BUILD_URL}")
                        }
                    }
                    catch (Exception e) {
                        googlechatnotification (url: 'https://chat.googleapis.com/v1/spaces/AAAAuvIDdoQ/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=I7VzE4LUOmrrhTt_jmDoiAJwbAI0z70DqfiJ6eOBvUY%3D', message: ":-( Build Failed *${env.JOB_NAME}*, ${env.BUILD_URL}")
                        currentBuild.result = 'ABORTED'
                        return
                    }
                }
            }
        }
        stage('package') {
            steps {
                                withCredentials([[$class: 'UsernamePasswordMultiBinding',
                                credentialsId: 'DOCKER_CRAPHAEL',
                                usernameVariable: 'DOCKER_USER',
                                passwordVariable: 'DOCKER_PASSWORD']]) {
                           sh 'sudo docker login -u ${DOCKER_USER} -p ${DOCKER_PASSWORD} ${DOCKER_REGISTRY}'
						   sh 'sudo docker build -t ${DOCKER_REGISTRY}/${PROJECT}/${APP}:$VERSION .'
						   sh 'sudo docker push ${DOCKER_REGISTRY}/${PROJECT}/${APP}:$VERSION'
						   googlechatnotification (url: 'https://chat.googleapis.com/v1/spaces/AAAAWOYgloM/messages?key=AIzaSyDdI0hCZtE6vySjMm-WEfRq3CPzqKqqsHI&token=ZMebLi9FSS_m2weO0mNx2b7nsZk_YyTMZm8F12B5r3c%3D', message: "docker push successful for *${env.JOB_NAME}* ...")
                        }
                    }
                }
		stage('image prune'){
			steps {
                           sh label: '', script: 'sudo docker system prune -a -f'
						   //sh label: '', script: 'sudo docker rmi $(docker images -a -q)'
		             }
                }

            stage("deploy") {
                steps {
                    build job: 'kubernetes-deploy',
                        parameters: [
                            string(name: 'ENVIRONMENT', value: 'youverify'),
                            string(name: 'APP', value: APP),
                            string(name: 'VERSION', value: VERSION),
                            string(name: 'NAMESPACE', value: NAMESPACE)
                        ]
                }
            }
		}
    }
