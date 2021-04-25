pipeline {
    agent any

    environment{
        registry = "ramp110397/webelight_practical_test"
        registryCredential = "my.local"
        dockerImage = ''
    }
    stages {
        stage('SonarQube analysis') {
            steps {
                script {
                      def scannerHome = tool 'LocalSonarQubeScanner';
                      withSonarQubeEnv('LocalSonarQubeScanner') {
                       sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=webelight_practical_test-qa-sonar -Dsonar.sources=./config"
                    }
                }
            }
        }
        stage('Building Dockerimage') {
            steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage = docker.build registry + ":$BRANCH_NAME-$BUILD_NUMBER"
                    }
                }
            }
        }
        stage('Pushing Dockerimage Into Dockerhub') {
            steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                    }
                }
            }
        }
        stage('Remove Unused Dockerimage') {
            steps{
                sh "docker rmi $registry:$BRANCH_NAME-$BUILD_NUMBER"
           }
        }
        stage('Secrets Copy') {
            steps{
                    withCredentials([file(credentialsId: 'LocalKubernetes', variable: 'LocalKubernetes')]) {
                        sh "cp \$LocalKubernetes config"
                }
            }
        }
        stage('Kubernetes Deploy') {
            steps{
                sh 'helm --kubeconfig=config upgrade -i  webelight_practical_test-$BRANCH_NAME -n local-server webelight_practical_test-$BRANCH_NAME/ --set image.tag=$BRANCH_NAME-$BUILD_NUMBER'
            }
        }
        cleanup {
            echo "Clean up in post work space"
            cleanWs()
            }
        }
    }
}

