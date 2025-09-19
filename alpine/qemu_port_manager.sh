#!/data/data/com.termux/files/usr/bin/bash

# ============================================================================
# QEMU 端口映射管理器 (v5.0)
# 功能: 管理 QEMU 虚拟机端口映射规则，支持添加、删除、恢复配置

# --- 全局配置 ---
readonly TARGET_SCRIPT="$HOME/alpine/startqemu.sh"
readonly BACKUP_DIR="$HOME/alpine/backups"

# 备份文件定义
readonly GOLDEN_BACKUP="$BACKUP_DIR/startqemu.golden.sh"
readonly LAST_MODIFIED_BACKUP="$BACKUP_DIR/startqemu.last_modified.sh"
readonly TEMP_BACKUP="$BACKUP_DIR/startqemu.tmp"

# --- 初始化全局变量 ---
declare -i PORT_COUNT=0
declare -a PORTS_HOST=()
declare -a PORTS_GUEST=()
declare -a PORTS_FULL=()

# ============================================================================
# 函数: 初始化备份系统
# 作用: 创建备份目录，若黄金备份不存在则基于当前脚本创建
# 返回: 0 成功, 1 失败
# ============================================================================
init_backup_system() {
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        echo "📁 已创建备份目录: $BACKUP_DIR"
    fi

    # 若黄金备份不存在，则从当前脚本创建
    if [ ! -f "$GOLDEN_BACKUP" ]; then
        if [ -f "$TARGET_SCRIPT" ]; then
            cp "$TARGET_SCRIPT" "$GOLDEN_BACKUP"
            echo "✅ 已创建黄金原版备份: $GOLDEN_BACKUP"
        else
            echo "❌ 错误: 找不到目标脚本 '$TARGET_SCRIPT'，无法创建黄金备份。"
            return 1
        fi
    fi
    return 0
}

# ============================================================================
# 函数: 解析并列出当前所有端口映射
# 作用: 从 TARGET_SCRIPT 中提取所有 hostfwd 规则并格式化输出
# 返回: 0 成功（有端口）, 1 失败或无端口
# ============================================================================
list_current_ports() {
    if [ ! -f "$TARGET_SCRIPT" ]; then
        echo "❌ 错误: 找不到目标脚本 '$TARGET_SCRIPT'。"
        return 1
    fi

    # 提取包含网络设备配置的行（-netdev user,id=n1...）
    local netdev_line
    netdev_line=$(grep -o '\-netdev user,id=n1[^\\]*' "$TARGET_SCRIPT" | head -n 1)
    if [ -z "$netdev_line" ]; then
        echo "❌ 错误: 未能在脚本中找到 -netdev 配置行。"
        return 1
    fi

    # 清空端口数组
    PORT_COUNT=0
    unset PORTS_HOST
    unset PORTS_GUEST
    unset PORTS_FULL

    echo "📋 当前已映射的端口列表:"
    echo "编号 | 宿主机端口 -> 虚拟机端口"
    echo "-----|-------------------------"

    # 提取所有 hostfwd=tcp::... 规则
    IFS=$'\n' read -rd '' -a hostfwd_rules <<< "$(echo "$netdev_line" | grep -o 'hostfwd=tcp::[^,]*')"

    for rule in "${hostfwd_rules[@]}"; do
        if [ -n "$rule" ]; then
            local ports_part=${rule#hostfwd=tcp::}
            ((PORT_COUNT++))

            if [[ "$ports_part" == *-* ]]; then
                # 处理端口范围映射（如 8000-8000::8000-9000）
                local host_range=${ports_part%%::*}
                local guest_range=${ports_part##*::}
                echo "$PORT_COUNT | $host_range -> $guest_range (范围)"
                PORTS_HOST[$PORT_COUNT]=$host_range
                PORTS_GUEST[$PORT_COUNT]=$guest_range
                PORTS_FULL[$PORT_COUNT]=$ports_part
            else
                # 处理单端口映射（如 2222:22）
                local host_port=${ports_part%:*}
                local guest_port=${ports_part#*:}
                echo "$PORT_COUNT | $host_port -> $guest_port"
                PORTS_HOST[$PORT_COUNT]=$host_port
                PORTS_GUEST[$PORT_COUNT]=$guest_port
                PORTS_FULL[$PORT_COUNT]=$ports_part
            fi
        fi
    done

    if [ $PORT_COUNT -eq 0 ]; then
        echo "📭 暂无任何端口映射。"
        return 1
    fi

    return 0
}

# ============================================================================
# 函数: 添加端口映射
# 参数: $1 - 端口映射规则（支持简单模式如 "3000" 或高级模式如 "2222-:22"）
# 返回: 0 成功, 1 失败
# ============================================================================
add_port() {
    local input=$1

    if [ -z "$input" ]; then
        echo "❌ 错误: 未指定端口映射规则。"
        echo "ℹ️  用法1 (简单模式): 输入单个端口号，如 '3000'"
        echo "ℹ️  用法2 (高级模式): 输入完整映射，如 '2222-:22' 或 '8000-8000::8000-9000'"
        return 1
    fi

    if [ ! -f "$TARGET_SCRIPT" ]; then
        echo "❌ 错误: 找不到目标脚本 '$TARGET_SCRIPT'。"
        return 1
    fi

    # 创建临时备份以防操作失败
    cp "$TARGET_SCRIPT" "$TEMP_BACKUP"

    local mapping_rule
    if [[ "$input" == *":"* ]]; then
        # 高级模式：用户自定义完整映射
        mapping_rule="$input"
        echo "📌 检测到高级模式: $mapping_rule"
    else
        # 简单模式：自动映射宿主机端口到同名虚拟机端口
        if ! [[ "$input" =~ ^[0-9]+$ ]]; then
            echo "❌ 错误: 简单模式下，端口号必须是数字。"
            rm "$TEMP_BACKUP" 2>/dev/null
            return 1
        fi
        mapping_rule="${input}-:${input}"
        echo "📌 使用简单模式: $mapping_rule"
    fi

    # 尝试在 9000 端口后插入（推荐锚点），否则追加到行末
    if grep -q "hostfwd=tcp::9000-:9000" "$TARGET_SCRIPT"; then
        sed -i "s/\(hostfwd=tcp::9000-:9000\)/\1,hostfwd=tcp::${mapping_rule}/" "$TARGET_SCRIPT"
    else
        sed -i "s/\(-netdev user,id=n1[^,]*\)/\1,hostfwd=tcp::${mapping_rule}/" "$TARGET_SCRIPT"
    fi

    if [ $? -eq 0 ]; then
        echo "✅ 成功: 已将端口映射 '$mapping_rule' 添加到 $TARGET_SCRIPT。"
        rm "$TEMP_BACKUP" 2>/dev/null
        echo "🔄 请重启 QEMU 虚拟机以使更改生效。"
        return 0
    else
        echo "❌ 失败: 修改脚本时发生错误。"
        echo "🔄 正在从临时备份恢复..."
        cp "$TEMP_BACKUP" "$TARGET_SCRIPT"
        rm "$TEMP_BACKUP" 2>/dev/null
        return 1
    fi
}

# ============================================================================
# 函数: 移除端口映射
# 参数: $1 - 要删除的端口编号，逗号分隔（如 "1,3,5"）
# 返回: 0 成功, 1 失败
# ============================================================================
remove_ports() {
    local choices=$1

    if [ -z "$choices" ]; then
        echo "❌ 错误: 未指定要删除的端口编号。"
        return 1
    fi

    # 创建临时备份
    cp "$TARGET_SCRIPT" "$TEMP_BACKUP"

    IFS=',' read -ra choice_array <<< "$choices"

    # 逆序删除，避免索引偏移
    for (( i=${#choice_array[@]}-1; i>=0; i-- )); do
        local choice=${choice_array[$i]}

        # 校验编号有效性
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "$PORT_COUNT" ]; then
            echo "⚠️  警告: 无效的编号 '$choice'，已跳过。"
            continue
        fi

        local rule_to_remove="hostfwd=tcp::${PORTS_FULL[$choice]}"

        if grep -q "$rule_to_remove" "$TEMP_BACKUP"; then
            # 删除规则（处理前导/后导逗号）
            sed -i "s/,$rule_to_remove//g; s/$rule_to_remove,//g; s/$rule_to_remove//g" "$TEMP_BACKUP"
            echo "🗑️  已移除端口映射: ${PORTS_HOST[$choice]} -> ${PORTS_GUEST[$choice]}"
        else
            echo "⚠️  警告: 未能在脚本中找到编号为 '$choice' 的规则，可能已被其他操作删除。"
        fi
    done

    # 应用修改
    cp "$TEMP_BACKUP" "$TARGET_SCRIPT"
    rm "$TEMP_BACKUP" 2>/dev/null

    echo "✅ 端口移除操作完成。"
    echo "🔄 请重启 QEMU 虚拟机以使更改生效。"
    return 0
}

# ============================================================================
# 函数: 恢复黄金原版配置
# 作用: 将脚本恢复为首次运行管理器时的状态
# 返回: 0 成功, 1 失败
# ============================================================================
restore_golden() {
    if [ ! -f "$GOLDEN_BACKUP" ]; then
        echo "❌ 错误: 找不到黄金原版备份 '$GOLDEN_BACKUP'。"
        return 1
    fi

    if [ ! -f "$TARGET_SCRIPT" ]; then
        echo "❌ 错误: 找不到目标脚本 '$TARGET_SCRIPT'。"
        return 1
    fi

    # 备份当前配置为“最后修改版”
    cp "$TARGET_SCRIPT" "$LAST_MODIFIED_BACKUP"
    echo "✅ 已备份当前配置为 '最后修改版'。"

    # 恢复黄金原版
    cp "$GOLDEN_BACKUP" "$TARGET_SCRIPT"
    echo "✅ 成功: 已恢复到黄金原版设置。"
    echo "🔄 请重启 QEMU 虚拟机以使更改生效。"
    return 0
}

# ============================================================================
# 函数: 从最后修改版恢复
# 作用: 恢复上一次“恢复原版”前的配置
# 返回: 0 成功, 1 失败
# ============================================================================
restore_last_modified() {
    if [ ! -f "$LAST_MODIFIED_BACKUP" ]; then
        echo "❌ 错误: 找不到 '最后修改版' 备份 '$LAST_MODIFIED_BACKUP'。"
        echo "ℹ️  您可能尚未执行过 '恢复原版' 操作。"
        return 1
    fi

    if [ ! -f "$TARGET_SCRIPT" ]; then
        echo "❌ 错误: 找不到目标脚本 '$TARGET_SCRIPT'。"
        return 1
    fi

    # 临时备份当前状态
    cp "$TARGET_SCRIPT" "$TEMP_BACKUP"

    # 恢复最后修改版
    cp "$LAST_MODIFIED_BACKUP" "$TARGET_SCRIPT"
    echo "✅ 成功: 已从 '最后修改版' 恢复配置。"
    echo "🔄 请重启 QEMU 虚拟机以使更改生效。"
    return 0
}

# ============================================================================
# 函数: 显示主菜单
# ============================================================================
show_menu() {
    clear
    echo "=================================="
    echo "      QEMU 端口管理器 (v5.0)      "
    echo "=================================="
    echo "1. 添加新端口映射"
    echo "2. 移除现有端口映射"
    echo "3. 恢复原版设置"
    echo "4. 从最后修改版恢复"
    echo "5. 退出"
    echo "----------------------------------"
    echo -n "请选择操作 [1-5]: "
}

# ============================================================================
# 主程序入口
# ============================================================================

# 初始化备份系统（关键：确保黄金备份存在）
init_backup_system || {
    echo "⚠️  备份系统初始化失败，部分功能可能受限。"
    sleep 3
}

# 主循环
while true; do
    show_menu
    read -r choice

    case $choice in
        1)
            clear
            echo "=== 📥 添加新端口映射 ==="
            echo -n "请输入要映射的端口号 (例如: 3000 或 2222-:22): "
            read -r port
            add_port "$port"
            echo
            echo -n "按回车键返回主菜单..."
            read -r
            ;;
        2)
            clear
            echo "=== 🗑️  移除现有端口映射 ==="
            if ! list_current_ports; then
                echo
                echo -n "按回车键返回主菜单..."
                read -r
                continue
            fi
            echo
            echo "请输入要删除的端口编号，用逗号分隔 (例如: 1,3,5): "
            echo -n "您的选择: "
            read -r selections
            remove_ports "$selections"
            echo
            echo -n "按回车键返回主菜单..."
            read -r
            ;;
        3)
            clear
            echo "=== 🔄 恢复原版设置 ==="
            echo "此操作将把 'startqemu.sh' 恢复到您首次运行本管理器时的状态。"
            echo "当前配置将被备份为 '最后修改版'，您可以通过选项 4 恢复。"
            echo -n "确认恢复吗? (y/N): "
            read -r confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                restore_golden
            else
                echo "ℹ️  已取消恢复操作。"
            fi
            echo
            echo -n "按回车键返回主菜单..."
            read -r
            ;;
        4)
            clear
            echo "=== ⏪ 从最后修改版恢复 ==="
            echo "此操作将把 'startqemu.sh' 恢复到您上一次执行 '恢复原版' 操作前的状态。"
            echo -n "确认恢复吗? (y/N): "
            read -r confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                restore_last_modified
            else
                echo "ℹ️  已取消恢复操作。"
            fi
            echo
            echo -n "按回车键返回主菜单..."
            read -r
            ;;
        5)
            echo "👋 再见！"
            exit 0
            ;;
        *)
            echo "❌ 无效选项，请输入 1-5 之间的数字。"
            sleep 2
            ;;
    esac
done
