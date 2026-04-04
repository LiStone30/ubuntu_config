Ubuntu 24.04 Git 完整配置文档（用户设置+SSH免密+远程关联）

本文档详细记录 Ubuntu 24.04 系统下 Git 的完整配置流程，包括 Git 安装、全局用户身份设置、SSH 密钥生成与配置、远程仓库关联，以及免密提交配置，确保后续提交/拉取代码无需重复输入密码。

一、前提：安装 Git（若未安装）

Ubuntu 24.04 可能默认未安装 Git，执行以下命令完成安装，确保后续操作正常进行。

sudo apt update
sudo apt install git -y

安装完成后，可通过 git --version命令验证安装是否成功，出现版本号即表示安装完成。

二、设置 Git 全局用户和邮箱（核心步骤）

配置全局用户身份，是 Git 提交代码时的身份标识，所有本地仓库提交都会默认使用该配置，无需单独为每个仓库设置。

2.1 执行配置命令

# 替换为你的姓名或 Git 用户名（如 GitHub 用户名）
git config --global user.name "Your Name"

# 替换为你注册 Git 平台（GitHub/GitLab）的邮箱
git config --global user.email "your_email@example.com"

# （可选）设置 Git 默认分支为 main（现代 Git 标准分支名，避免默认 master 分支）
git config --global init.defaultBranch main

2.2 验证配置生效

执行以下命令，查看全局配置信息，确认用户名和邮箱配置正确：

git config --global --list

输出结果中，若出现 user.name=你的用户名 和 user.email=你的邮箱，即表示配置成功。

三、生成并配置 SSH Key（实现免密提交）

默认情况下，Git 远程关联若使用 HTTPS 协议，每次提交/拉取都需要输入账号密码，配置 SSH Key 后，可通过 SSH 协议关联远程仓库，彻底实现免密交互。推荐使用更安全的 ed25519 密钥，兼容所有主流 Git 平台（GitHub、GitLab 等）。

3.1 生成 SSH 密钥对

# 推荐：生成 ed25519 密钥（更安全、高效，优先选择）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 备选：生成 4096 位 RSA 密钥（兼容性更好，适合旧版 Git 平台）
# ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

执行命令后，会出现三次提示，全部按回车键即可：

- 提示“Enter file in which to save the key”：默认保存路径为 ~/.ssh/id_ed25519（ed25519 密钥）或 ~/.ssh/id_rsa（RSA 密钥），直接回车沿用默认路径。

- 提示“Enter passphrase”：密码短语，直接回车留空（留空即可实现完全免密，若设置密码短语，每次使用密钥仍需输入该短语）。

- 提示“Enter same passphrase again”：再次确认密码短语，同样回车留空。

密钥生成完成后，会在 ~/.ssh 目录下生成两个文件：私钥（id_ed25519 或 id_rsa，不可泄露）和公钥（id_ed25519.pub 或 id_rsa.pub，用于配置到 Git 平台）。

3.2 启动 SSH 代理并添加私钥

生成密钥后，需要启动 SSH 代理，并将私钥添加到代理中，确保系统能识别密钥，步骤如下：

# 启动 SSH 代理（临时生效，重启系统后需重新执行）
eval "$(ssh-agent -s)"

# 添加 ed25519 私钥到代理（若用 RSA 密钥，替换为 ~/.ssh/id_rsa）
ssh-add ~/.ssh/id_ed25519

执行后无报错，即表示私钥添加成功。

3.3 复制公钥内容

需要将公钥内容复制到 Git 平台（GitHub/GitLab），执行以下命令查看并复制公钥：

# 查看 ed25519 公钥内容（若用 RSA 密钥，替换为 id_rsa.pub）
cat ~/.ssh/id_ed25519.pub

复制输出结果的全部内容（从 ssh-ed25519 开始，到末尾的邮箱结束，不要遗漏任何字符）。

3.4 将公钥添加到 Git 平台（以 GitHub 为例）

1. 打开 GitHub 官网，登录你的账号，点击右上角头像，选择「Settings」（设置）。

2. 在左侧菜单中，找到「SSH and GPG keys」（SSH 和 GPG 密钥），点击「New SSH key」（新建 SSH 密钥）。

3. 填写密钥信息：
        

  - Title（标题）：可自定义，如「Ubuntu 24.04 设备」，方便区分不同设备的密钥。

  - Key（密钥）：粘贴刚才复制的公钥内容，确保无多余空格和换行。

4. 点击「Add SSH key」（添加 SSH 密钥），完成公钥配置。

GitLab 配置类似：登录后点击头像 → 「Edit Profile」→ 「SSH Keys」，粘贴公钥后点击「Add key」即可。

3.5 测试 SSH 连接（验证配置）

配置完成后，执行以下命令测试与 Git 平台的 SSH 连接，确认密钥生效：

# 测试 GitHub 连接
ssh -T git@github.com

# 测试 GitLab 连接（若使用 GitLab，执行以下命令）
# ssh -T git@gitlab.com

首次连接会提示“Are you sure you want to continue connecting (yes/no/[fingerprint])?”，输入「yes」并回车。

若出现类似以下提示，即表示 SSH 连接成功：

Hi YourUsername! You've successfully authenticated, but GitHub does not provide shell access.

四、关联本地仓库与远程仓库（SSH 方式）

SSH 密钥配置完成后，需将本地仓库与远程仓库通过 SSH 地址关联，避免使用 HTTPS 地址（否则仍会要求输入密码），分两种场景说明：

场景 1：本地新建项目（未初始化 Git 仓库）

# 1. 进入本地项目目录（替换为你的项目路径）
cd /path/to/your/project

# 2. 初始化 Git 仓库（生成 .git 目录，完成本地仓库初始化）
git init

# 3. 关联远程仓库（使用 SSH 地址，替换为你的仓库 SSH 地址）
# 格式：git remote add origin git@github.com:用户名/仓库名.git
git remote add origin git@github.com:YourUsername/YourRepository.git

# 4. 首次提交并推送（-u 关联上游分支，后续推送可直接用 git push）
git add .  # 将本地所有文件添加到暂存区
git commit -m "Initial commit"  # 提交暂存区文件，备注可自定义
git push -u origin main  # 推送到远程 main 分支

场景 2：本地已有项目（之前用 HTTPS 关联远程）

若本地仓库之前已通过 HTTPS 地址关联远程，需将远程地址改为 SSH 地址，步骤如下：

# 1. 查看当前远程仓库地址（确认是 HTTPS 地址）
git remote -v

# 2. 将远程地址改为 SSH 地址（替换为你的仓库 SSH 地址）
git remote set-url origin git@github.com:YourUsername/YourRepository.git

# 3. 验证修改后的地址（确认已改为 git@ 开头的 SSH 地址）
git remote -v

修改完成后，后续执行 git push、git pull 即可免密操作。

五、可选：HTTPS 协议的免密方案（不推荐）

若因特殊需求必须使用 HTTPS 协议关联远程仓库，可通过 Git 凭证缓存实现免密，两种方式可选（安全性低于 SSH 密钥）：

# 方式 1：永久保存密码（明文存储在 ~/.git-credentials，不安全）
git config --global credential.helper store

# 方式 2：缓存密码 1 小时（3600 秒，超时后需重新输入，相对安全）
git config --global credential.helper 'cache --timeout=3600'

配置后，首次提交会要求输入一次账号密码，后续在有效期内无需重复输入。

六、配置完成验证

完成以上所有步骤后，验证以下效果，确保配置生效：

- 本地提交：执行 git commit 时，无需额外输入用户名和邮箱，自动使用全局配置。

- 远程交互：执行 git push、git pull 时，无需输入任何账号密码，直接完成操作。

七、常见问题排查

- SSH 连接失败：检查公钥是否完整粘贴到 Git 平台，私钥是否添加到 SSH 代理，可重新执行 ssh-add ~/.ssh/id_ed25519 尝试。

- 推送提示“permission denied”：确认 Git 平台的公钥配置正确，且远程仓库的权限（如 GitHub 仓库是否允许你的账号推送）。

- 重启系统后免密失效：需重新执行 eval "$(ssh-agent -s)" 和 ssh-add ~/.ssh/id_ed25519，或配置 SSH 代理自动启动（需额外配置）。
