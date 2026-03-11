
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
                    
                    // 1. 明确打印日志，看看是不是 sed 替换文件卡住了
                    sh 'echo "--> 正在执行文件替换..."'
                    sh 'sed -i "s|FRUVEE_IMAGE_PLACEHOLDER|${IMAGE_TAG}|g" k8s-deploy.yaml'
                    
                    // 2. 核心排雷：暴力清空所有可能劫持流量的代理变量，并开启详细日志
                    sh '''
                        echo "--> 正在清理容器内可能存在的幽灵代理..."
                        export HTTP_PROXY=""
                        export HTTPS_PROXY=""
                        export http_proxy=""
                        export https_proxy=""
                        
                        echo "--> 测试与 K8s 大脑的连通性..."
                        kubectl cluster-info
                        
                        echo "--> 真正执行发布动作..."
                        # --v=6 会把 kubectl 底层的每一次请求都打印出来，让卡点无所遁形
                        kubectl apply -f k8s-deploy.yaml --v=6
                    '''
                }
            }
        }
    }
}
