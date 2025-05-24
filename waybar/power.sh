#!/usr/bin/bash

# 检查所需命令是否存在
check_commands() {
    local missing=()
    for cmd in hyprctl wofi systemctl; do
        if ! command -v $cmd &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        notify-send "电源菜单错误" "缺少必要命令: ${missing[*]}"
        exit 1
    fi
}

# 显示电源菜单
show_menu() {
    local options=(
        "󰌾 锁屏"
        "󰤄 睡眠"
        "󰿅 退出"
        "⏻ 关机"
        "⭮ 重启"
        "󰜺 取消"
    )
    
    # 使用 wofi 显示菜单
    choice=$(printf '%s\n' "${options[@]}" | wofi --dmenu \
        --prompt="选择电源操作" \
        --width=600 \
        --height=280)
    
    case "$choice" in
        "󰌾 锁屏")
            lock_screen
            ;;
        "󰤄 睡眠")
            suspend_system
            ;;
        "󰿅 退出")
            exit_session
            ;;
        "⏻ 关机")
            shutdown_system
            ;;
        "⭮ 重启")
            reboot_system
            ;;
        *)
            exit 0
            ;;
    esac
}

# 锁屏功能
lock_screen() {
    if command -v hyprlock &> /dev/null; then
        hyprlock
    else
        notify-send "锁屏失败" "未找到 Hyprlock" -u critical
    fi
}

# 睡眠/挂起
suspend_system() {
    local confirm=$(echo -e "取消\n确认睡眠" | wofi --dmenu --height=160 --width=600 --prompt="确认休眠系统?")
    [[ "$confirm" != "确认睡眠" ]] && return
    
    if command -v systemctl &> /dev/null; then
        systemctl suspend
    else
        zzz
    fi
}

# 退出 Hyprland 会话
exit_session() {
    local confirm=$(echo -e "取消\n确认退出" | wofi --dmenu --height=160 --width=600 --prompt="确认退出 Hyprland?")
    [[ "$confirm" != "确认退出" ]] && return
    
    hyprctl dispatch exit
}

# 重启系统
reboot_system() {
    local confirm=$(echo -e "取消\n确认重启" | wofi --dmenu --height=160 --width=600 --prompt="确认重启系统?")
    [[ "$confirm" != "确认重启" ]] && return
    
    systemctl reboot
}

# 关机
shutdown_system() {
    local confirm=$(echo -e "取消\n确认关机" | wofi --dmenu --height=160 --width=600 --prompt="确认关闭系统?")
    [[ "$confirm" != "确认关机" ]] && return
    
    systemctl poweroff
}

# 主执行流程
check_commands
show_menu
