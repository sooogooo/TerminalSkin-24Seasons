#!/bin/bash

# 二十四节气主题安装脚本

echo "🌸 正在安装二十四节气终端主题系统..."

# 创建符号链接到 /usr/local/bin（需要sudo权限）
if command -v sudo >/dev/null 2>&1; then
    echo "正在创建全局命令链接..."
    sudo ln -sf "$HOME/solar_terms_theme.sh" /usr/local/bin/jieqi
    echo "✅ 已创建全局命令 'jieqi'"
else
    echo "⚠️  无sudo权限，跳过全局命令创建"
fi

# 添加别名到bashrc
if ! grep -q "alias jieqi=" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# 二十四节气主题命令别名" >> ~/.bashrc
    echo "alias jieqi='$HOME/solar_terms_theme.sh'" >> ~/.bashrc
    echo "alias 节气='$HOME/solar_terms_theme.sh'" >> ~/.bashrc
    echo "✅ 已添加命令别名到 ~/.bashrc"
fi

# 创建桌面快捷方式（如果是桌面环境）
if [[ -n "$DISPLAY" ]] && [[ -d "$HOME/Desktop" ]]; then
    cat > "$HOME/Desktop/节气主题.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=二十四节气主题
Name[en]=Solar Terms Theme
Comment=中国二十四节气终端配色主题
Comment[en]=Chinese 24 Solar Terms Terminal Theme
Exec=gnome-terminal -- bash -c '$HOME/solar_terms_theme.sh --list; read -p "按回车键继续..."'
Icon=preferences-desktop-theme
Terminal=false
Categories=Utility;
EOF
    chmod +x "$HOME/Desktop/节气主题.desktop"
    echo "✅ 已创建桌面快捷方式"
fi

echo ""
echo "🎉 安装完成！"
echo ""
echo "📖 使用方法："
echo "  jieqi --help      # 查看帮助"
echo "  jieqi --list      # 列出所有节气"
echo "  jieqi --auto      # 自动设置当前节气"
echo "  jieqi 立春        # 设置立春主题"
echo "  节气 --random     # 随机选择节气主题"
echo ""
echo "🔄 请运行以下命令使别名生效："
echo "  source ~/.bashrc"
echo ""
echo "或者重新打开终端窗口。"
