pipeline {
    agent any

    environment {
        APP_NAME = 'spring-petclinic'
        IMAGE_TAG = "4.0.0-SNAPSHOT-${BUILD_NUMBER}"
        IMAGE_NAME = "jagsonline/spring-petclinic"
    }

    stages {
        stage('Build') {
            steps {
                echo 'Build step...'
                bat 'mvnw.cmd clean compile'
            }
        }

        stage('Test') {
            steps {
                echo 'Test the code...'
                bat 'mvnw.cmd test'
            }
        
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package Jar') {
            steps {
                echo 'Package Jar...'
                bat 'mvnw.cmd package -DskipTests'
                
            }
        }

        stage('Archive Jar'){
            steps {
                archiveArtifacts artifacts: 'target/*.jar' , fingerprint: true
            }
        }

        stage('Build Docker image'){
            steps {
                echo 'Building docker image...'
                bat '''
                docker build -t %IMAGE_NAME%:%IMAGE_TAG% .
                docker tag %IMAGE_NAME%:%IMAGE_TAG% %IMAGE_NAME%:latest
                '''
            }
        }

        stage ('Docker Login'){
            steps {
                echo 'Docker login...'
                withCredentials([usernamePassword(
                    credentialsId: 'docker-creds2',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_TOKEN'
                )]) {
                    powershell '''
                    Write-Host "Docker user is $env:DOCKER_USER"
                    docker login -u $env:DOCKER_USER -p $env:DOCKER_TOKEN
                    '''
                }
            }
        }

        stage ('Push Docker Image') {
            steps {
                echo 'Push docker image...'
                bat '''
                docker push %IMAGE_NAME%:%IMAGE_TAG% 
                docker push %IMAGE_NAME%:latest
                '''

            }
        }

        stage ('Deploy to Dev') {
            when {
                expression {
                    currentBuild.result == null ||
                    currentBuild.result == 'SUCCESS' ||
                    currentBuild.result == 'UNSTABLE'
                }
            }
            steps {
                echo "Deploying image ${IMAGE_NAME}:${IMAGE_TAG} to Dev env..."
            }
        }

    }

    post {
        success {
            echo 'Pipeline completed successfully.'
        }

        failure {
            echo 'Pipeline failed.'
        }

        always {
            echo 'Pipeline finished.'
        }
    }
}

