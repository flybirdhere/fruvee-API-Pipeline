
# 1. 使用极其轻量的 Node.js 运行环境 (仅约 40MB)
FROM node:18-alpine

# 2. 在容器内指定工作目录
WORKDIR /app

# 3. 把刚才写的 server.js 拷贝到容器里
COPY server.js .

# 4. 声明对外暴露 8080 端口
EXPOSE 8080

# 5. 启动服务的命令
CMD ["node", "server.js"]
