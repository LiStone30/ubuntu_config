# 随便选一个基础镜像
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

# 安装 curl（必须）
RUN apt update && apt install -y curl

# ======================
# 测试代理是否生效（关键！）
# ======================
RUN curl https://ipinfo.io/ip
RUN curl google.com