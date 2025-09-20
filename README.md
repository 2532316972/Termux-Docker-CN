# 🐧 Termux-Docker-CN 

> 🇨🇳 本项目是 [Zeioth/termux-docker](https://github.com/Zeioth/termux-docker) 的中国特供优化版。专为**中国大陆网络环境**和**新手用户**设计，让你在安卓手机上也能轻松运行 Docker 容器！

---

## ✅ 项目亮点

本项目在原版基础上做了以下四大核心调整与优化：

1. **🚀 极速安装体验**  
   用 DHCP **自动获取** IP，避免静态 IP 配置冲突。使用 **8.8.8.8 和 114.114.114.114** 作为 DNS 服务器，确保域名解析。使用**清华大学的镜像源**下载软件包，速度飞快，大幅提升 Alpine Linux 和 Docker 的下载与安装速度，避免卡顿、失败。

2. **💪 性能默认配置调整**  
   启动脚本 `startqemu.sh`与 配置文件 `config.env` 中默认分配了**更多 CPU(6核) 核心与内存(8GB)、硬盘空间(20G)**（默认 2 核 + 1GB + 4G），适合运行轻量级容器服务。若设备性能有限，可自行编辑调整。

3. **🌐 Docker镜像加速器**  
   安装时，自动完成对`daemon.json`的配置，加速保证Docker镜像拉取顺利

4. **🧩 小白友好端口管理器**  
   新增 `qemu_port_manager.sh` 脚本，支持：
   - ✅ 添加端口映射
   - ✅ 删除指定映射
   - ✅ 恢复默认配置  
   无需手动编辑 QEMU 启动参数，小白也能轻松管理！

---

## 📱 快速开始（三步走）

---

## 📱 第一步：安装 Termux 并初始化环境

### 1.1 从官方渠道下载安装 Termux

请从官方 GitHub Releases 页面下载最新版 APK：

🔗 [https://github.com/termux/termux-app/releases](https://github.com/termux/termux-app/releases)

> ⚠️ **安全提醒**：  
> 请勿从不明第三方市场（如某些“应用商店”或网盘链接）下载 Termux，以防植入恶意代码或使用过期/篡改版本。  

安装完成后，打开 Termux 应用，你会看到一个 Linux 终端界面。

---

### 1.2 更新包管理器并升级基础系统（关键步骤！）

首次启动 Termux 后，请**立即执行以下两条命令**：

```bash
pkg update && pkg upgrade -y
```

📌 **作用说明**：

- `pkg update`：从官方源拉取最新的软件包列表（相当于刷新“应用商店”）。
- `pkg upgrade -y`：将 Termux 系统内所有已安装的基础包（如 `bash`, `coreutils`, `curl` 等）升级到最新版本，修复潜在 Bug，提升稳定性。

---

### 第二步：一键安装虚拟机环境

在 Termux 中执行以下命令：

```bash
curl -o setup.sh https://raw.githubusercontent.com/2532316972/termux-docker-CN/main/setup.sh && chmod 755 ./setup.sh && ./setup.sh
```

> 💡 若安装失败，可能是网络问题，请尝试：
> - 清除Termux软件数据后重试
> - 检查是否使用了代理或科学上网

安装过程全自动，无需干预，安装需要较长时间（取决于网络和设备性能）。

---

### 🚀 第三步：启动虚拟机 & 登录系统

安装完成后，请执行以下命令启动虚拟机：

```bash
~/alpine/startqemu.sh
```

> ⏳ 首次启动可能需要较长时间，请耐心等待，直到看到 QEMU 控制台输出或提示符。

---

#### 📌 登录凭证（适用于所有登录方式）

- **用户名**：`root`
- **密码**：`MyAlpine@2025!`

> ✅ 登录成功后，在虚拟机的命令行中可以使用以下命令修改登录密码：
> ```bash
> passwd
> ```
> 按提示输入新密码即可

---

#### 🖥️ 操作方式说明

执行 `startqemu.sh` 后，当前 Termux 窗口将**直接进入 QEMU 虚拟机的控制台界面**。你无需切换窗口或使用其他工具，直接在此界面输入用户名和密码即可登录并开始使用。

> 💡 **重要提示**：所有 Docker 操作都必须在登录此虚拟机控制台后执行。Termux 主环境本身不包含 Docker，它只是一个运行虚拟机的“宿主平台”。

---

## 🐳 如何使用 Docker？

在虚拟机内，你可以像在普通 Linux 服务器上一样使用 Docker，如果什么都不会建议前往B大去静修。
你可以使用以下命令验证Docker是否能够正常运行：

```bash
docker run hello-world
```    

---

### 🖥️ 使用 DPanel Lite（轻量级可视化容器管理面板）

> ✅ 专为个人内网使用设计，无需绑定 80/443 端口，更轻量、更简洁。  
> 📱 在手机浏览器中即可管理所有 Docker 容器、镜像、网络和卷，中文面版。

```bash
docker run -d \
  --name dpanel \
  --restart=always \
  -p 8807:8080 \
  -e APP_NAME=dpanel \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/docker-volumes/dpanel:/dpanel \
  registry.cn-hangzhou.aliyuncs.com/dpanel/dpanel:lite \
  && echo "✅ DPanel 已启动！请在浏览器打开：http://localhost:8807"
```

> 🌐 如果你想从**局域网其他设备访问**，请将 `localhost` 替换为你的手机在局域网中的 IP 地址，例如：  
> `http://192.168.1.100:8807`

单行复制版：
```bash
mkdir -p ~/docker-volumes/dpanel && docker run -d --name dpanel --restart=always -p 8807:8080 -e APP_NAME=dpanel -v /var/run/docker.sock:/var/run/docker.sock -v ~/docker-volumes/dpanel:/dpanel registry.cn-hangzhou.aliyuncs.com/dpanel/dpanel:lite && echo "🎉 DPanel Lite 启动成功！访问 → http://localhost:8807"
```

---

## ❓ 常见问题（FAQ）

### Q1：在哪里执行这些命令？
> 所有命令均在 **Termux** 中执行。安装 Termux 后，它就是一个 Linux 终端模拟器。

---

### Q2：为什么 Portainer/K8s 启动失败？
> 请确保你**已成功登录虚拟机**，并在虚拟机内执行 `docker` 命令。Docker 是安装在虚拟机里的，不是 Termux 里！

---

### Q3：项目还在维护吗？
> 随缘吧，精力有限，也无需我操心。

---

### Q4：需要 Root 权限吗？
> ❌ **完全不需要！** 本项目基于 QEMU 虚拟机，无需 Root。

---

### Q5：每次都要手动启动容器吗？
> ❌ 不需要！所有示例均包含 `--restart=always`，只要虚拟机启动，容器会自动运行。

---

### Q6：如何让容器数据持久化？
> 使用 `-v` 参数挂载卷（Volume）。例如：
> ```bash
> -v ~/docker-volumes/portainer:/home
> ```
> 数据会保存在虚拟机内的 `~/docker-volumes/` 目录下，**不是 Termux 的目录**，重启不丢失！

---

### Q7：为什么我无法访问到docker部署的容器？
> 因为你没有修改虚拟机启动脚本的端口映射。
> 什么？你不会？
> 没关系，我们为你准备了傻瓜式工具，请使用：
> ```bash
>  ~/alpine/qemu_port_manager.sh
> ```
> 来使用端口管理器进行增加或删除端口

---


## 🎁 结语

现在，你已拥有一个运行在手机上的“迷你服务器”，支持 Docker、Portainer、K8s、Prometheus、Grafana 等主流工具。无论是学习、开发、还是搭建个人服务，Termux-Docker-CN 都是你最贴心的伙伴！

> 📱 让你的安卓手机，变身生产力工具！

---

## 由衷感谢作者的无私贡献
📚 原版项目：https://github.com/Zeioth/termux-docker

---

**Happy Docker! 🐧🐳📱**

--- 

> 文档撰写：2532316972  
> 最后更新：2025年9月20日   
> 适用人群：Termux 新手、Docker 爱好者、移动开发学习者
