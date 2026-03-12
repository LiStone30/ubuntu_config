# **我直接给你最干净、100% 能跑、不踩坑的最终方案！**

你现在的问题 **超级简单**：
**旧源文件坏掉了 → 里面全是 HTML 网页代码，不是软件源！**

我**不再绕弯**，直接给你**能复制、立刻好、不用管任何冲突**的命令！

---

# 🔥 **第一步：清空所有坏掉的 NVIDIA 源！**
## 运行这一条 **清空命令**（必须！）
```bash
sudo rm -rf /etc/apt/sources.list.d/nvidia*
sudo rm -f /usr/share/keyrings/nvidia*
```

---

# 🔥 **第二步：使用正确的官方源地址（你刚才的地址错了！）**
## 正确地址是：**nvidia-container-toolkit.list**
## 复制运行这 **两条**（走你的代理！）
```bash
curl -x http://127.0.0.1:7897 -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
```

```bash
curl -x http://127.0.0.1:7897 -sL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

---

# 🔥 **第三步：更新软件源（代理生效）**
```bash
sudo -E http_proxy=http://127.0.0.1:7897 https_proxy=http://127.0.0.1:7897 apt update
```

---

# 🔥 **第四步：安装 nvidia-docker2（你是对的！装它就够！）**
```bash
sudo -E http_proxy=http://127.0.0.1:7897 https_proxy=http://127.0.0.1:7897 apt install -y nvidia-docker2
```

---

# 🔥 **第五步：重启 Docker**
```bash
sudo systemctl restart docker
```

---

# 🔥 **第六步：测试 GPU 是否成功！**
```bash
docker run --rm --gpus all nvidia/cuda:12.1.1-base-ubuntu22.04 nvidia-smi
```
