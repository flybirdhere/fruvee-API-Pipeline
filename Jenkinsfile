
pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                echo '拉取代码成功...'
                // 这里是你原本拉代码的步骤
            }
        }
        stage('Deploy to K8s') {
            steps {
                echo '准备发布 Fruvée 后台系统到生产环境...'
                // 使用刚刚下载到持久化目录里的 kubectl 执行部署图纸
                sh '/var/jenkins_home/kubectl apply -f k8s-deploy.yaml'
            }
        }
    }
}
