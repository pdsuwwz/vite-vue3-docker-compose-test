# 构建前端服务镜像
FROM node:lts-alpine AS frontend

# 全局安装 pnpm
RUN npm install pnpm -g

# 设置工作目录
WORKDIR /app

# 复制 package.json 和 pnpm-lock.yaml 文件
COPY package.json pnpm-lock.yaml ./

# 安装依赖项
RUN pnpm install @rollup/rollup-linux-x64-gnu --save-optional

RUN pnpm install --production && rm -rf /root/.npm /root/.pnpm-store /usr/local/share/.cache /tmp/*

# 复制项目文件
COPY . ./

# 打包前端代码
RUN pnpm run build


# Nginx 配置
FROM nginx:alpine

# 拷贝前端代码到 Nginx 静态文件目录
COPY --from=frontend /app/dist /usr/share/nginx/html

# 复制自定义 Nginx 配置文件
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf

# 暴露 Nginx 服务端口
EXPOSE 80


# 方法二：直接使用本地 pnpm build 打包好的 dist/ 映射到 nginx 容器内

# # 使用适合的 Nginx 镜像作为基础镜像
# FROM nginx:alpine

# # 拷贝自定义的 Nginx 配置文件
# COPY nginx.conf /etc/nginx/nginx.conf

# # 拷贝本地的 dist 包到 Nginx 静态文件目录
# COPY dist /usr/share/nginx/html

# # 暴露 Nginx 服务端口
# EXPOSE 80
