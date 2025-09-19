## DESCRIPTION:
## 此脚本用于在 Termux 中一键安装运行在 QEMU 虚拟机内的 Alpine Linux (预装 Docker)。
## 专为中国大陆网络环境优化，使用清华大学镜像源加速安装。
## 注意：如需重新安装，请手动删除 INSTALL_DIR 目录。

# 设置安装目录 (可自定义)
INSTALL_DIR="$HOME/alpine"

# 安装 Termux 依赖包
pkg install -y expect wget qemu-utils qemu-common qemu-system-x86_64-headless openssh

# 创建并进入安装目录
mkdir -p "$INSTALL_DIR" && cd "$INSTALL_DIR"

# 从 GitHub 仓库下载所有必需文件
# 环境配置文件
curl -L "https://raw.githubusercontent.com/2532316972/Termux-Docker-CN/main/alpine/config.env" > "$INSTALL_DIR/config.env"
# SSH 连接虚拟机脚本
curl -L "https://raw.githubusercontent.com/Zeioth/termux-docker/main/alpine/ssh2qemu.sh" > "$INSTALL_DIR/ssh2qemu.sh"
# 启动虚拟机脚本
curl -L "https://raw.githubusercontent.com/2532316972/Termux-Docker-CN/main/alpine/startqemu.sh" > "$INSTALL_DIR/startqemu.sh"
# 核心自动化安装脚本
curl -L "https://raw.githubusercontent.com/Zeioth/termux-docker/main/alpine/installqemu.expect" > "$INSTALL_DIR/installqemu.expect"
# 下载已为中国用户配置好的 answerfile 
curl -L "https://raw.githubusercontent.com/2532316972/Termux-Docker-CN/main/alpine/answerfile" > "$INSTALL_DIR/answerfile"
# 下载映射端口管理器
curl -L "https://raw.githubusercontent.com/2532316972/Termux-Docker-CN/main/alpine/qemu_port_manager.sh" > "$INSTALL_DIR/qemu_port_manager.sh"

# 为便捷脚本添加可执行权限
chmod +x "$INSTALL_DIR/ssh2qemu.sh"
chmod +x "$INSTALL_DIR/startqemu.sh"
chmod +x "$INSTALL_DIR/qemu_port_manager.sh"


# 加载环境变量并启动自动化安装
. "$INSTALL_DIR/config.env"
expect -f "$INSTALL_DIR/installqemu.expect"

echo "=============================================="
echo "安装完成！"
echo "启动虚拟机: ~/alpine/startqemu.sh"
echo "连接虚拟机: ~/alpine/ssh2qemu.sh"
echo "端口管理器: ~/alpine/qemu_port_manager.sh"
echo "=============================================="
