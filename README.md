# 🐧 Termux-Docker-CN 

> 🇨🇳 本项目是 [Zeioth/termux-docker](https://github.com/Zeioth/termux-docker) 的中国特供优化版。专为**中国大陆网络环境**和**新手用户**设计，让你在安卓手机上也能轻松运行 Docker 容器！

---

## ✅ 项目亮点

本项目在原版基础上做了以下四大核心调整与优化：

1. **🚀 极速安装体验**  
   所有软件源替换为**清华大学开源镜像站**，大幅提升 Alpine Linux 和 Docker 的下载与安装速度，避免卡顿、失败。

2. **💪 性能默认配置调整**  
   启动脚本 `startqemu.sh`与 配置文件 `config.env` 中默认分配了**更多 CPU(6核) 核心与内存(8GB)、硬盘空间(20G)**（默认 2 核 + 1GB + 4G），适合运行轻量级容器服务。若设备性能有限，可自行编辑调整。

3. **🌐 Docker镜像加速器**  
   安装时，自动完成对daemon.json的配置，保证Docker镜像拉取顺利

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
```bash
passwd
```

---

#### 🌐 登录方式（二选一）

#### 方式一：使用 SSH 连接

虚拟机启动后，**另开一个 Termux 窗口**，执行：

```bash
~/alpine/ssh2qemu.sh
```

---

#### 方式二：直接在 QEMU 控制台操作

启动 `startqemu.sh` 后，Termux 窗口将直接进入虚拟机控制台，可直接输入用户名密码登录。

---

> 💡 **温馨提示**：无论使用哪种方式登录，操作的都是同一个虚拟机系统，数据完全同步。

---

## 🐳 如何使用 Docker？

在虚拟机内，你可以像在普通 Linux 服务器上一样使用 Docker，如果什么都不会建议前往B大去静修。
你可以使用以下命令验证Docker是否能够正常运行：

```bash
docker run hello-world
```    

---

### 🖥️ 使用 Portainer（可视化容器管理）

```bash
docker run -d \
  -p 8000:8000 \
  -p 9000:9000 \
  --name=portainer \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/docker-volumes/portainer:/home \
  portainer/portainer-ce \
  && echo "✅ Portainer 已启动！请在浏览器打开：http://localhost:9000"
```

> 🌐 如果你想从**局域网其他设备访问**，请将 `localhost` 替换为你的手机在局域网中的 IP 地址，例如：  
> `http://192.168.1.100:9000`

单行复制版：
```bash
docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v ~/docker-volumes/portainer:/data portainer/portainer-ce && echo "✅ Portainer 启动成功！请访问 → http://localhost:9000"
```

---

### ☸️ 使用 Kubernetes（轻量级集群）

```bash
docker run -it \
  --entrypoint /bin/sh \
  -p 6443:6443 \
  -p 2379:2380 \
  -p 10250:10250 \
  -p 10259:10259 \
  -p 10257:10257 \
  -p 30001:32767 \
  -v ~/docker-volumes/kubernetes:/home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  alpine/k8s:1.24.12
```

> ⚠️ 注意：此容器需交互式运行（`-it`），后台运行不会自动启动服务。适合学习和调试。

单行复制版：
```bash
docker run -it --entrypoint /bin/sh -p 6443:6443 -p 2379:2380 -p 10250:10250 -p 10259:10259 -p 10257:10257 -p 30001:32767 -v ~/docker-volumes/kubernetes:/home -v /var/run/docker.sock:/var/run/docker.sock alpine/k8s:1.24.12
```

---

### 📊 使用 Prometheus（监控数据采集）

```bash
# 请先创建配置文件 prometheus.yml
# 示例配置：https://github.com/prometheus/prometheus/blob/main/documentation/examples/prometheus.yml

docker run -d \
  -p 9090:9090 \
  -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
  --name=prometheus \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/docker-volumes/prometheus:/home \
  prom/prometheus \
  && echo "✅ Prometheus 已启动！访问：http://localhost:9090"
```

> 📝 请务必将 `/path/to/prometheus.yml` 替换为你实际存放配置文件的路径！


单行复制版：
```bash
mkdir -p ~/docker-volumes/prometheus && echo "global: scrape_interval: 15s scrape_configs: - job_name: 'prometheus' static_configs: - targets: ['localhost:9090']" > ~/docker-volumes/prometheus/prometheus.yml && docker run -d -p 9090:9090 --name=prometheus --restart=always -v ~/docker-volumes/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml -v ~/docker-volumes/prometheus:/prometheus prom/prometheus && echo "✅ Prometheus 启动成功！请访问 → http://localhost:9090"
```

---

### 📈 使用 Grafana（数据可视化面板）

```bash
docker run -d \
  -p 3000:3000 \
  --name=grafana \
  --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/docker-volumes/grafana:/home \
  grafana/grafana-oss:8.5.22 \
  && echo "✅ Grafana 已启动！访问：http://localhost:3000"
```

> 默认登录：admin / admin（首次登录会要求修改密码）

单行复制版：
```bash
docker run -d -p 3000:3000 --name=grafana --restart=always -v ~/docker-volumes/grafana:/var/lib/grafana grafana/grafana-oss:8.5.22 && echo "✅ Grafana 启动成功！请访问 → http://localhost:3000 (默认账号: admin/admin)"
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

### Q8：简单解释一下技术架构？
> `setup.sh` → 使用 QEMU 创建 Alpine Linux 虚拟机 → 自动安装 Docker → 你可以在 VM 中运行任何 Docker 容器。  
> Portainer = 可视化管理面板  
> Kubernetes = 容器编排（学习用）  
> Prometheus + Grafana = 监控 + 可视化

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
