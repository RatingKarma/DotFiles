#!/bin/bash
image_name="$(date +'%Y-%m-%d_%H-%M-%S').png"
output_file="$HOME/Pictures/$image_name"

if grim "$output_file"; then
  wl-copy < "$output_file"
  notify-send "截图已保存" "保存到 $output_file 并已复制到剪贴板"
else
  notify-send "截图失败" "无法保存截图到 $output_file"
  exit 1
fi
