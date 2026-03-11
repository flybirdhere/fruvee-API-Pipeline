
pipeline {
    // 【云原生核心】声明一个包含完整工具链的工作 Pod
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              # 第一个容器：专门负责打包和推送的 Docker 专家
              - name: docker
                image: docker:27-cli
                command: ['cat']
                tty: true
                volumeMounts:
                - mountPath: /var/run/docker.sock
                  name: docker-sock
              # 第二个容器：专门负责与 K8s 通信的部署专家
              - name: kubectl
                image: bitnami/kubectl:latest
                command: ['cat']
                tty: true
              volumes:
              - name: docker-sock
                hostPath:
                  path: /var/run/docker.sock
            '''
        }
    }
    
    environment {
        // 直接使用你日志里暴露的真实账号
        IMAGE_TAG = "flybirdhere/fruvee-api:v${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                echo '开始拉取 Fruvée 业务代码...'
                // ⚠️ 这里请确保你的 GitHub 地址是对的
                git branch: 'main', url: 'https://github.com/flybirdhere/Fruvee-API-Pipeline.git'
            }
        }

        stage('Build & Push Image') {
            steps {
                // 切换到 docker 容器执行环境
                container('docker') {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PWD', usernameVariable: 'DOCKER_USER')]) {
                        
                        echo "正在登录 Docker Hub..."
                        // 直接使用原生 docker 命令，不再需要任何绝对路径
                        sh "echo \$DOCKER_PWD | docker login -u \$DOCKER_USER --password-stdin"
                        
                        echo "开始打包 Fruvée 极简版 API 镜像..."
                        sh "docker build -t ${IMAGE_TAG} ."
                        
                        echo "正在将镜像推送至云端..."
                        sh "docker push ${IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                // 切换到 kubectl 容器执行环境
                container('kubectl') {
                    echo '准备发布 Fruvée 后台到生产环境...'
                    
                    // 用刚刚推送到云端的真实镜像名，替换图纸里的占位符
                    sh 'sed -i "s|FRUVEE_IMAGE_PLACEHOLDER|${IMAGE_TAG}|g" k8s-deploy.yaml'
                    
                    // 原生 kubectl 执行部署
                    sh 'kubectl apply -f k8s-deploy.yaml'
                }
            }
        }
    }
}
