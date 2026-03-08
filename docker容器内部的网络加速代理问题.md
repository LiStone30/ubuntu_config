你想在Docker容器内配置代理，让从GitHub拉取项目等网络操作也能走加速代理，这个需求很常见。核心思路是**给容器配置网络代理**，有两种实用方案：临时生效（单次容器）和永久生效（所有容器），你可以根据需求选择。

### 方案1：临时生效（单次运行容器时配置）
适合只需要在某一次运行容器时使用代理的场景，直接在`docker run`命令中通过`-e`参数注入代理环境变量：

```bash
# 核心命令模板（替换成你的代理地址）
sudo docker run -it --rm \
  -e http_proxy=http://172.17.0.1:7897 \
  -e https_proxy=http://172.17.0.1:7897 \
  -e no_proxy=localhost,127.0.0.1,192.168.0.0/16 \
  pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime /bin/bash


sudo docker run -it --rm \
  -e http_proxy=http://127.0.0.1:7897 \
  -e https_proxy=http://127.0.0.1:7897 \
  -e no_proxy=localhost,127.0.0.1,192.168.0.0/16 \
  --network host \  # 关键！让容器能访问宿主机的代理端口（WSL2/本地代理必加）
  你的镜像名称 /bin/bash



# 示例：运行Ubuntu容器并配置代理
sudo docker run -it --rm \
  -e http_proxy=http://127.0.0.1:7897 \
  -e https_proxy=http://127.0.0.1:7897 \
  -e no_proxy=localhost,127.0.0.1 \
  --network host \
  pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime /bin/bash
```

进入容器后，测试代理是否生效：
```bash
# 容器内执行，能快速返回结果说明代理生效
curl -I https://github.com
curl google.com
curl https://ipinfo.io/ip
```

有一点 apt 命令 如何使得加速代理起效


### 方案2：通用的方案（不用 --network host）；但存在clash-verge 软件的只监听127.0.0.1的问题，导致 docker容器的网络 无法连接
--network host 虽然简单，但会让容器失去网络隔离性（容器的端口直接占用宿主机端口）。更规范的做法是：用宿主机的局域网 IP 替代 127.0.0.1，步骤如下：


#### 步骤1：获取宿主机的局域网IP
在主系统（宿主机）执行：
```bash
# 查看宿主机的局域网IP（通常是 eth0 或 wlan0 网卡的 inet 地址）
ip addr | grep -E 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | grep -v 'docker' | awk '{print $2}' | cut -d/ -f1
```
输出示例：`192.168.31.85`（这是宿主机在局域网中的真实IP）。

#### 步骤2：用局域网IP配置容器代理（无需 `--network host`）
```bash
sudo docker run -it --rm \
  -e http_proxy=http://192.168.31.85:7897 \  # 替换成你的宿主机局域网IP
  -e https_proxy=http://192.168.31.85:7897 \
  -e no_proxy=localhost,127.0.0.1,192.168.0.0/16 \
  nvidia/cuda:12.2.2-devel-ubuntu22.04
```

### 验证容器内代理是否生效
进入容器后执行以下命令，能快速返回结果说明代理生效：
```bash
# 测试访问GitHub（容器内执行）
curl -I https://github.com
# 测试git克隆（容器内执行）
git clone https://github.com/git/git.git  # 看克隆速度是否提升
```


`apt` 工具的代理配置优先级：
1. 专属配置文件（`/etc/apt/apt.conf` 或 `/etc/apt/apt.conf.d/*.conf`）> 
2. 命令行参数（`apt -o Acquire::http::Proxy=...`）> 
3. 系统环境变量（`http_proxy`/`https_proxy`）

简单说：`apt` 不“认”容器内的 `http_proxy` 环境变量，必须单独配置。

### 解决方案（两种方式，按需选择）
#### 方式1：临时生效（单次apt命令）
在容器内执行 `apt` 时，通过命令行参数指定代理，适合临时装包：
```bash
# 容器内执行（替换成你的代理IP+端口，比如192.168.31.85:7897）
apt update -o Acquire::http::Proxy="http://192.168.31.85:7897" -o Acquire::https::Proxy="http://192.168.31.85:7897"
apt install -y git -o Acquire::http::Proxy="http://192.168.31.85:7897" -o Acquire::https::Proxy="http://192.168.31.85:7897"
```

#### 方式2：永久生效（容器内所有apt命令）
在容器内创建 `apt` 专属的代理配置文件，后续所有 `apt` 命令都会自动走代理：
```bash
# 容器内执行（一步配置，永久生效）
echo 'Acquire::http::Proxy "http://192.168.31.85:7897";' > /etc/apt/apt.conf.d/99proxy
echo 'Acquire::https::Proxy "http://192.168.31.85:7897";' >> /etc/apt/apt.conf.d/99proxy

# 之后直接执行apt即可走代理
apt update
apt install -y git
```
