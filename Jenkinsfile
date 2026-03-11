
pipeline {
    // 核心架构升级：告诉 K8s 派出一个“自带 Docker 装备”并且挂载了物理机引擎的临时工
    agent {
        kubernetes {
            yaml '''
            apiVersion: v1
            kind: Pod
            spec:
              containers:
              - name: docker
                image: docker:24.0.7-cli
                command: ['cat']
                tty: true
                volumeMounts:
                - mountPath: /var/run/docker.sock
                  name: docker-sock
              volumes:
              - name: docker-sock
                hostPath:
                  path: /var/run/docker.sock
            '''
        }
    }
    
    environment {
        // ⚠️ 请把这里的 your-dockerhub-username 换成你真实的 Docker Hub 用户名
        IMAGE_TAG = "flybirdhere/fruvee-api:v${env.BUILD_NUMBER}"
        // 指定我们刚挂载好的 Docker 客户端工具
        DOCKER_CMD = "/var/jenkins_home/docker-cli" 
    }

    stages {
        stage('Checkout') {
            steps {
                echo '开始拉取 Fruvée 业务代码...'
                // 保留你原本的 Git 拉取命令
                // ⚠️ 修改点 2：把这里的单引号里的网址，换成你真实 GitHub 仓库的 HTTPS 地址
                // 如果你的分支不是 main 而是 master，也请把 'main' 改掉
                git branch: 'main', url: 'https://github.com/flybirdhere/Fruvee-API-Pipeline.git'
            }
        }

        stage('Build & Push Image') {
            steps {
                // 这个 withCredentials 块会自动去保险箱里拿出账号密码，并临时赋值给变量
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PWD', usernameVariable: 'DOCKER_USER')]) {
                    
                    echo "正在登录 Docker Hub..."
                    // 采用最安全的标准输入流方式登录，防止密码在日志中泄露
                    sh "echo \$DOCKER_PWD | ${DOCKER_CMD} login -u \$DOCKER_USER --password-stdin"
                    
                    echo "开始打包 Fruvée 业务镜像..."
                    // ⚠️ 注意：记得把下面换成你之前更正过的、正确的 Dockerfile 文件名！
                    sh "${DOCKER_CMD} build -f <正确的Dockerfile名字> -t ${IMAGE_TAG} ."
                    
                    echo "推送镜像到云端仓库..."
                    sh "${DOCKER_CMD} push ${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to K8s') {
            steps {
                echo '准备发布 Fruvée 真实后台到 K8s 集群...'
                // 现场准备 kubectl 部署工具
                sh 'curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"'
                sh 'chmod +x ./kubectl'
                
                // 核心魔法：用刚刚打包好的真实镜像名，替换掉 k8s-deploy.yaml 里的 FRUVEE_IMAGE_PLACEHOLDER 占位符
                sh 'sed -i "s|FRUVEE_IMAGE_PLACEHOLDER|${IMAGE_TAG}|g" k8s-deploy.yaml'
                
                // 拿着替换好的图纸，发给 K8s 执行滚动更新
                sh './kubectl apply -f k8s-deploy.yaml'
            }
        }
    }
}
