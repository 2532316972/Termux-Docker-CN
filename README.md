# 🐧 Termux-Docker-CN

> 🇨🇳 本项目是 [Zeioth/termux-docker](https://github.com/Zeioth/termux-docker) 的中国特供优化版。专为**中国大陆网络环境**和**新手用户**设计，主要目标是让你能够将自己的旧安卓手机也能够运行 Docker 容器，充分利用旧手机剩余价值！

---

## ✅ 项目亮点

本项目在原版基础上做了以下四大核心调整与优化：

1.  **🚀 极速安装体验**
    *   **智能网络配置**：通过 DHCP **自动获取** IP，避免静态 IP 配置冲突。
    *   **稳定 DNS 解析**：预设 `8.8.8.8` 和 `114.114.114.114` 作为 DNS 服务器，确保域名解析成功。
    *   **国内镜像加速**：全面使用**清华大学镜像源**，大幅提升 Alpine Linux 和 Docker 的下载与安装速度，告别卡顿与失败。

2.  **💪 强劲性能默认配置**
    *   启动脚本 `startqemu.sh` 与配置文件 `config.env` 中默认分配了**更多 CPU(8核)、内存(11GB)及硬盘空间(20G)**（原版为 2 核 + 1GB + 4G），。若设备性能有限，可随时自行编辑调整。

3.  **🌐 一些缓解措施**
    *   **配置 Docker 镜像加速**：安装过程中，脚本会自动配置 `daemon.json` 文件，以缓解 Docker 镜像拉取速度慢、失败率高的问题。
    *   **挂载共享目录**：对 `startqemu.sh` 文件优化运行逻辑，配置挂载文件夹参数。

4.  **🧩 小白友好端口管理器**
    *   新增 `qemu_port_manager.sh` 脚本，让你无需理解复杂的 QEMU 启动参数，即可通过交互式菜单轻松管理端口映射。支持：
        *   ✅ **添加**端口映射
        *   ✅ **删除**指定映射
        *   ✅ 一键**恢复**默认配置

---

# 🚀 快速开始

## **第一步：安装 Termux 并初始化环境**

### **1.1 从官方渠道下载并安装 Termux**

为确保安全与应用版本最新，请务必从官方 GitHub Releases 页面下载 APK 文件进行安装。

🔗 **官方下载地址**：[https://github.com/termux/termux-app/releases](https://github.com/termux/termux-app/releases)

> ⚠️ **安全提醒**：
> 请**不要**从任何第三方应用商店或不明网盘链接下载 Termux。这些渠道的版本可能被篡改、植入恶意代码或版本过旧，导致无法正常使用。

安装完成后，打开 Termux 应用，你将看到一个简洁的 Linux 终端界面。

### **1.2 更新软件源并升级基础系统（关键步骤！）**

首次打开 Termux 后，**必须**执行以下命令，以确保所有工具链为最新状态，避免后续安装失败。

```bash
pkg update && pkg upgrade -y
```

---

## **第二步：一键安装 Docker 虚拟机环境**

在 Termux 终端中，复制并执行以下命令，启动全自动安装流程。

```bash
curl -o setup.sh https://raw.githubusercontent.com/2532316972/termux-docker-CN/main/setup.sh && chmod 755 ./setup.sh && ./setup.sh
```

> 💡 **安装提示**：
> *   整个过程完全自动化，无需任何手动干预。
> *   所需时间取决于你的设备性能和网络状况，请耐心等待。
> *   若安装失败，大概率是网络问题导致无法从GitHub上拉取sh文件。请尝试**清除 Termux 应用数据**后，连接代理/换镜像源后重试。

---

## **第三步：启动并登录虚拟机**

### **3.1 启动虚拟机**

安装完成后，执行以下命令即可启动 Alpine Linux 虚拟机：

```bash
~/alpine/startqemu.sh
```

> ⏳ **耐心等待**：首次启动过程可能需要一些时间来完成初始化，请耐心等待，直到屏幕上出现 `alpine login:` 的登录提示符。

### **3.2 登录凭证**

以下凭证适用于所有登录方式：

*   **用户名**：`root`
*   **密　码**：`MyAlpine@2025!`

> 💡 登录成功后，你可以使用 `passwd` 命令修改默认密码，方便进行登入。

### **3.3 登录方式（二选一）**

#### **方式一：QEMU 控制台直接登录 **

执行 `~/alpine/startqemu.sh` 后，当前 Termux 窗口将直接转为虚拟机的控制台。看到 `alpine login:` 提示后，直接输入用户名和密码（输入密码时屏幕上不会显示字符，这是正常现象），然后按回车即可登录。

#### **方式二：SSH 客户端登录 **

SSH 提供了更稳定、更强大的远程管理体验。

1.  **首次配置**：
    首先，你需要通过**方式一**登录虚拟机，然后执行以下命令，开启 SSH 服务的密码登录功能：
    ```bash
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/g; s/#PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config && rc-service sshd restart
    ```

2.  **连接虚拟机**：
    配置完成后，在 Termux 主程序中**新开一个会话窗口**，然后执行：
    ```bash
    ssh -p 2222 root@localhost
    ```
    输入密码后即可登录。

> 🌐 **局域网访问**：
> 如果你想从同一局域网下的其他设备（如电脑、平板）连接虚拟机，只需将 `localhost` 替换为**运行 Termux 的手机的 IP 地址**即可。例如，若手机 IP 为 `192.168.1.100`，则连接命令为：
> `ssh -p 2222 root@192.168.1.100`

---

# 🐳 Docker 使用指南

成功登录虚拟机后，你就可以像在任何标准 Linux 服务器上一样使用 Docker 了。

### **验证 Docker 是否正常运行**

你可以执行以下命令来确定docker是否正常运行：

```bash
docker run hello-world
```

### **🖥️ 可视化管理：安装 DPanel Lite 面板**

对于不熟悉命令行的用户，我们推荐安装 DPanel Lite，一个专为个人内网设计的轻量级、中文图形化容器管理面板。

在**虚拟机内**执行以下单行命令即可一键部署：

```bash
mkdir -p ~/docker-volumes/dpanel && docker run -d --name dpanel --restart=always -p 8807:8080 -e APP_NAME=dpanel -v /var/run/docker.sock:/var/run/docker.sock -v ~/docker-volumes/dpanel:/dpanel registry.cn-hangzhou.aliyuncs.com/dpanel/dpanel:lite && echo "🎉 DPanel Lite 启动成功！请在浏览器访问 → http://localhost:8807"
```

> 🌐 **访问地址**：
> *   **手机本地访问**：`http://localhost:8807`
> *   **局域网其他设备访问**：将 `localhost` 替换为手机的 IP 地址，例如 `http://192.168.1.100:8807`。

---

# 🛠️ 进阶技巧与优化

### **⚡ 共享文件夹自动挂载**

在 **Alpine Linux 虚拟机内**，执行以下命令安装nano编辑器：

```bash
apk add nano
```

执行以下命令，编辑用户配置文件：

```bash
nano ~/.profile
```

在文件中粘贴以下所有内容：

```bash
# ========== 登录时自动挂载 QEMU 共享文件夹 ==========
# 检查共享文件夹是否已挂载，避免重复操作
if ! mountpoint -q /shared; then
    echo "⏳ 正在挂载 Termux 共享文件夹，请稍候..."

    # 确保挂载点存在
    mkdir -p /shared

    # 加载必需的内核模块 (静默模式)
    modprobe 9pnet_virtio >/dev/null 2>&1
    modprobe 9p >/dev/null 2>&1

    # 尝试挂载，内置 3 次重试机制
    MAX_TRIES=3
    TRY_COUNT=0
    while [ $TRY_COUNT -lt $MAX_TRIES ]; do
        if mount -t 9p -o trans=virtio,version=9p2000.L shared /shared; then
            echo "✅ 共享文件夹挂载成功！"
            break
        else
            TRY_COUNT=$((TRY_COUNT + 1))
            if [ $TRY_COUNT -eq $MAX_TRIES ]; then
                echo "❌ 共享文件夹挂载失败，请检查 QEMU 配置。"
            else
                echo "第 $TRY_COUNT 次尝试失败，3秒后重试..."
                sleep 3
            fi
        fi
    done
else
    echo "✅ 共享文件夹已挂载。"
fi
# ========== 挂载脚本结束 ==========
```

**保存与生效**：

1.  按 `Ctrl + X` 准备退出。
2.  按 `Y` 确认保存修改。
3.  按 `Enter` 确认文件名，完成保存。

**测试效果**：
使用`source ~/.profile`重新加载配置文件。你将看到脚本输出的挂载提示信息。最后，通过 `ls -l /shared/` 命令检查共享目录内容，确认挂载成功。

---

# ❓ 常见问题 (FAQ)

**Q1: 所有命令都在哪里执行？**
> **A1:** 本文档中命令都应在 **Termux 应用**的主终端界面中执行。`docker` 相关命令则需要在**登录虚拟机之后**执行。

**Q2: 为什么我无法从外部访问容器暴露的端口？**
> **A2:** 这是因为 QEMU 虚拟机需要明确的端口映射配置。什么？不会配置？没关系，我们已为您准备了傻瓜式管理工具。请在 **Termux** 中（不是虚拟机内）执行以下命令，并根据菜单提示添加您需要的端口映射：
> ```bash
> ~/alpine/qemu_port_manager.sh
> ```

**Q3: 这个项目需要 Root 手机吗？**
> **A4:** ❌ **完全不需要！** 本项目基于 QEMU 虚拟机技术，在标准的安卓系统环境下即可运行，无需任何 Root 权限。

**Q4: 容器需要每次手动启动吗？**
> **A5:** ❌ **不需要！** 所有示例中的 `docker run` 命令均包含了 `--restart=always` 参数。这意味着只要虚拟机正在运行，Docker 服务启动后，这些容器就会自动恢复运行。

**Q5: 如何让容器的数据永久保存，不因重启丢失？**
> **A6:** 通过使用 `-v` 参数挂载数据卷（Volume），将容器内的重要数据目录映射到虚拟机的文件系统上。例如：
> ```bash
> -v ~/docker-volumes/some-app:/app/data
> ```
> 上述命令会将容器的 `/app/data` 目录持久化保存在**虚拟机内**的 `~/docker-volumes/some-app` 目录下，确保数据安全。

**Q6: 这个项目还会更新维护吗？**
> **A7:** 随缘更新，精力有限。但项目核心功能已相当稳定，况且也无需我进行操心。

---

## 🎁 结语

现在，你已拥有一个运行在安卓手机上的“迷你服务器”，成功让你的旧手机再次发光发热。无论是用于技术学习、应用开发，还是搭建个人云服务，Termux-Docker-CN 都将是你最得力、最贴心的伙伴！

> 📱 **让你的安卓手机，即刻变身生产力工具！**

---

### **再次致谢**
本项目仅为优化与改进，离不开原作者的无私贡献。
📚 **原版项目地址**：[https://github.com/Zeioth/termux-docker](https://github.com/Zeioth/termux-docker)

---

**Happy Docker! 🐧🐳📱**

> ---
>
> *文档撰写与重构：2532316972*
>
> *最后更新：2025年9月22日*
>
> *适用人群：Termux 新手、Docker 爱好者、移动开发与学习者*
