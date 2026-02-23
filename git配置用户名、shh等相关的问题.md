你想在 Ubuntu 系统中完成 Git 的基础配置，包括设置用户名、邮箱，以及配置 SSH 密钥来实现免密访问 Git 仓库（如 GitHub/GitLab/Gitee），我会一步步教你完成整个配置流程。

### 一、基础配置：设置 Git 用户名和邮箱
这是 Git 的全局配置，会应用到你所有的 Git 仓库，首先打开 Ubuntu 的终端（快捷键 `Ctrl+Alt+T`），执行以下命令：

```bash
# 配置全局用户名（替换成你的名字，比如 "Zhang San"）
git config --global user.name "LiStone30"

# 配置全局邮箱（替换成你的 Git 仓库绑定的邮箱，比如 "zhangsan@example.com"）
git config --global user.email "listone307@gmail.com"

# 验证配置是否生效
git config --global --list
```

执行验证命令后，终端会输出类似以下内容，说明配置成功：
```
user.name=Your Name
user.email=listone307@gmail.com
```

### 二、配置 SSH 密钥（核心：实现免密访问 Git 仓库）
SSH 密钥用于 Git 仓库的身份验证，避免每次拉取/推送代码都输入账号密码，步骤如下：

#### 1. 检查是否已有 SSH 密钥（避免重复生成）
```bash
ls -la ~/.ssh
```
如果输出中有 `id_rsa`（私钥）和 `id_rsa.pub`（公钥），说明已有密钥，可直接跳到步骤 4；如果没有，继续下一步。

#### 2. 生成 SSH 密钥
执行以下命令，替换为你配置 Git 时用的邮箱：
```bash
ssh-keygen -t rsa -b 4096 -C "listone307@gmail.com"
```
执行后会出现以下提示：
- `Enter file in which to save the key (/home/你的用户名/.ssh/id_rsa):`：直接按回车，使用默认路径。
- `Enter passphrase (empty for no passphrase):`：可选设置密钥密码（建议留空，免密更方便；如果设置，每次用 SSH 都会要求输入）。
- `Enter same passphrase again:`：再次输入密码（留空则直接回车）。

生成成功后，`~/.ssh` 目录下会出现 `id_rsa`（私钥，切勿泄露）和 `id_rsa.pub`（公钥，可公开）。

#### 3. 启动 SSH 代理并添加私钥（确保密钥生效）
```bash
# 启动 SSH 代理
eval "$(ssh-agent -s)"

# 添加私钥到代理（默认路径，无需修改）
ssh-add ~/.ssh/id_rsa
```
如果提示 `Identity added: /home/你的用户名/.ssh/id_rsa (listone307@gmail.com)`，说明添加成功。

#### 4. 复制 SSH 公钥（用于配置到 Git 平台）
执行以下命令复制公钥内容：
```bash
cat ~/.ssh/id_rsa.pub
```
终端会输出一串以 `ssh-rsa` 开头、你的邮箱结尾的字符串，**全选复制**（快捷键 `Ctrl+Shift+C`）。

#### 5. 将公钥配置到 Git 平台（以 GitHub 为例）
1. 登录 GitHub，点击右上角头像 → `Settings` → 左侧 `SSH and GPG keys`。
2. 点击 `New SSH key`，填写：
   - `Title`：自定义名称（如 "Ubuntu 主机"）。
   - `Key`：粘贴刚才复制的公钥字符串。
3. 点击 `Add SSH key` 完成配置。

#### 6. 验证 SSH 连接（测试是否配置成功）
以 GitHub 为例，执行：
```bash
ssh -T git@github.com
```
首次连接会提示 `Are you sure you want to continue connecting (yes/no/[fingerprint])?`，输入 `yes` 回车。

如果输出 `Hi 你的GitHub用户名! You've successfully authenticated, but GitHub does not provide shell access.`，说明 SSH 配置完全成功。

### 三、补充说明（避坑要点）
1. **不同 Git 平台的 SSH 测试命令**：
   - GitLab：`ssh -T git@gitlab.com`
   - Gitee（码云）：`ssh -T git@gitee.com`
2. **如果 SSH 连接失败**：
   - 检查 `~/.ssh` 目录权限：执行 `chmod 700 ~/.ssh` 和 `chmod 600 ~/.ssh/id_rsa`（权限错误会导致 SSH 验证失败）。
   - 检查防火墙/网络：确保 Ubuntu 能访问 Git 平台的 SSH 端口（22 端口）。
3. **局部配置（针对单个仓库）**：
   如果需要为某个仓库单独设置用户名/邮箱（覆盖全局配置），进入仓库目录后执行：
   ```bash
   git config user.name "Local Name"
   git config user.email "local_email@example.com"
   ```
4. 能通过 HTTPS 访问 GitHub，但 SSH 连接 22 端口超时，这是非常常见的网络限制问题（比如运营商 / 防火墙屏蔽了 22 端口），并非你配置错误，我会教你两种解决方案。
   查看当前远程地址（确认是 SSH 地址）
git remote -v

# 修改为 HTTPS 地址（替换 用户名/仓库名）
git remote set-url origin https://github.com/你的用户名/你的仓库名.git

# 验证修改结果
git remote -v


### 总结
1. Git 基础配置核心是 `git config --global` 设置用户名和邮箱，验证用 `git config --global --list`。
2. SSH 配置关键步骤：生成密钥 → 启动代理并添加私钥 → 复制公钥到 Git 平台 → 验证连接。
3. 权限问题是 SSH 配置最常见的坑，需确保 `~/.ssh` 目录权限为 700，私钥权限为 600。

完成以上配置后，你就可以在 Ubuntu 上通过 SSH 协议免密操作 Git 仓库了。