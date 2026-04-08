pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDS = credentials('dockerhub-creds')
        IMAGE_NAME = "asheesh972/trend-app"
        IMAGE_TAG = "latest"
    }
    
    stages {
        stage('Clone') {
            steps {
                git branch: 'main',
                    credentialsId: 'github-creds',
                    url: 'https://github.com/nehraashish972-cloud/trend-app.git'
            }
        }
        
        stage('Docker Build') {
            steps {
                sh "sudo docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }
        
        stage('Docker Push') {
            steps {
                sh "echo $DOCKERHUB_CREDS_PSW | sudo docker login -u $DOCKERHUB_CREDS_USR --password-stdin"
                sh "sudo docker push ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                sh "kubectl apply -f k8s/deployment.yaml"
                sh "kubectl apply -f k8s/service.yaml"
                sh "kubectl rollout restart deployment/trend-app"
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline successful!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
