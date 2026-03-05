
stage('Deploy to K8s') {
            steps {
                echo '准备发布 Fruvée 后台系统到生产环境...'
                
                // 1. 在当前流水线工作目录中，现场下载 kubectl
                sh 'curl -sLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"'
                
                // 2. 赋予执行权限
                sh 'chmod +x ./kubectl'
                
                // 3. 使用刚刚下载好的 ./kubectl 执行部署图纸
                sh './kubectl apply -f k8s-deploy.yaml'
            }
        }
