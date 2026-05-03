pipeline {
    agent any

    environment {
        APP_NAME = 'spring-petclinic'
        IMAGE_TAG = "4.0.0-SNAPSHOT-${BUILD_NUMBER}"
        IMAGE_NAME = "jagsonline/spring-petclinic"
        DOCKER_REPO  = 'docker-local'
        
        JFROG_HOST = 'trialsh57yr.jfrog.io'
        JFROG_URL = "https://${JFROG_HOST}"
        JFROG_DOCKER_REPO = 'docker-local'
        JFROG_IMAGE_NAME = "${JFROG_HOST}/${JFROG_DOCKER_REPO}/${APP_NAME}"
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

        stage('Configure JFrog CLI & Maven') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'jfrog-creds',
                    usernameVariable: 'JFROG_USER',
                    passwordVariable: 'JFROG_TOKEN'
                )]) {
                    bat '''
                    jf config add jfrog-server --url=%JFROG_URL% --user=%JFROG_USER% --password=%JFROG_TOKEN% --interactive=false --overwrite=true
                    
                    jf mvn-config --server-id-deploy=jfrog-server --repo-deploy-releases=sample-maven-release --repo-deploy-snapshots=sample-maven-snapshot
                    '''
                }
            }
        }

        stage('Publish JAR to JFrog') {
            steps {
                echo 'Deploying JAR to Artifactory...'
                // Using 'deploy' instead of 'package' automates the JFrog upload
                bat 'jf mvn deploy -DskipTests --server-id-resolve=jfrog-server --server-id-deploy=jfrog-server'
            }
        }

        stage('Build Docker image'){
            steps {
                echo 'Building docker image...'
                bat '''
                docker build -t %JFROG_IMAGE_NAME%:%IMAGE_TAG% .
                docker tag %JFROG_IMAGE_NAME%:%IMAGE_TAG% %JFROG_IMAGE_NAME%:latest
                '''
            }
        }

        stage('JFrog Docker Login') {
            steps {
                echo 'JFrog Docker login...'
                withCredentials([usernamePassword(
                    credentialsId: 'jfrog-creds',
                    usernameVariable: 'JFROG_USER',
                    passwordVariable: 'JFROG_TOKEN'
                )]) {
                    powershell '''
                    $env:JFROG_TOKEN | docker login $env:JFROG_HOST -u $env:JFROG_USER --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image to JFrog') {
            steps {
                echo 'Push docker image to JFrog...'
                bat '''
                docker push %JFROG_IMAGE_NAME%:%IMAGE_TAG%
                docker push %JFROG_IMAGE_NAME%:latest
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
                echo "Deploying image ${JFROG_IMAGE_NAME}:${IMAGE_TAG} to Dev env..."
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

