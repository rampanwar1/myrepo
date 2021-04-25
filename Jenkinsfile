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
    stages {
        stage('Building Dockerimage') {
            steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage = docker.build (registry + ":webelight_practical_test-$Cluster-$BUILD_NUMBER" , "-f $dockerfile .")
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
                sh "docker rmi $registry:paradise-$Cluster-$BUILD_NUMBER"
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
                sh "cat 'webelight_practical_test.yaml' | sed 's/{{TAG}}/paradise-$Cluster-$BUILD_NUMBER/g' | kubectl --kubeconfig=config apply -n $namespace -f -"
            }
        }
        stage('Workspace Cleanup') {
            steps{
                cleanWs()
            }
        }
    }
}

