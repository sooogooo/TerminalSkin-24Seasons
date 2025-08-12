#!/bin/bash

# 二十四节气终端配色管理脚本
# 作者：Amazon Q
# 版本：1.0

CONFIG_FILE="$HOME/.solar_terms_colors.conf"
CURRENT_THEME_FILE="$HOME/.current_solar_term"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# 二十四节气数组
declare -a SOLAR_TERMS=(
    "立春" "雨水" "惊蛰" "春分" "清明" "谷雨"
    "立夏" "小满" "芒种" "夏至" "小暑" "大暑"
    "立秋" "处暑" "白露" "秋分" "寒露" "霜降"
    "立冬" "小雪" "大雪" "冬至" "小寒" "大寒"
)

# 季节对应的emoji
declare -A SEASON_EMOJI=(
    ["立春"]="🌱" ["雨水"]="🌧️" ["惊蛰"]="⚡" ["春分"]="🌸" ["清明"]="🌿" ["谷雨"]="🌾"
    ["立夏"]="🌞" ["小满"]="🌾" ["芒种"]="🌾" ["夏至"]="☀️" ["小暑"]="🔥" ["大暑"]="🌡️"
    ["立秋"]="🍂" ["处暑"]="🍃" ["白露"]="💧" ["秋分"]="🍁" ["寒露"]="🍂" ["霜降"]="❄️"
    ["立冬"]="❄️" ["小雪"]="🌨️" ["大雪"]="⛄" ["冬至"]="🌙" ["小寒"]="🧊" ["大寒"]="🥶"
)

# 获取配置值的函数
get_config_value() {
    local term="$1"
    local key="$2"
    awk -v term="[$term]" -v key="$key" '
        $0 == term { found=1; next }
        found && /^\[/ && $0 != term { found=0 }
        found && $0 ~ "^" key "=" {
            gsub("^" key "=", "")
            gsub("\"", "")
            print
            exit
        }
    ' "$CONFIG_FILE"
}

# 应用GNOME Terminal配色的函数
apply_gnome_terminal_theme() {
    local term="$1"
    
    # 获取默认配置文件ID
    local profile_id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
    
    # 获取配色信息
    local background=$(get_config_value "$term" "background")
    local foreground=$(get_config_value "$term" "foreground")
    local palette=$(get_config_value "$term" "palette")
    local cursor_bg=$(get_config_value "$term" "cursor_bg")
    local cursor_fg=$(get_config_value "$term" "cursor_fg")
    local highlight_bg=$(get_config_value "$term" "highlight_bg")
    local highlight_fg=$(get_config_value "$term" "highlight_fg")
    
    # 应用配色
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ background-color "$background"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ foreground-color "$foreground"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ use-theme-colors false
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ palette "$palette"
    
    # 设置光标颜色
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ cursor-colors-set true
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ cursor-background-color "$cursor_bg"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ cursor-foreground-color "$cursor_fg"
    
    # 设置高亮颜色
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ highlight-colors-set true
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ highlight-background-color "$highlight_bg"
    gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile_id/ highlight-foreground-color "$highlight_fg"
    
    # 保存当前主题
    echo "$term" > "$CURRENT_THEME_FILE"
}

# 更新bash提示符的函数
update_bash_prompt() {
    local term="$1"
    local description=$(get_config_value "$term" "description")
    local emoji="${SEASON_EMOJI[$term]}"
    
    # 创建临时的bashrc更新
    local temp_bashrc=$(mktemp)
    
    # 复制现有的bashrc，但移除之前的节气配置
    awk '
        /^# 二十四节气主题配置开始/ { skip=1 }
        /^# 二十四节气主题配置结束/ { skip=0; next }
        !skip { print }
    ' ~/.bashrc > "$temp_bashrc"
    
    # 添加新的节气配置
    cat >> "$temp_bashrc" << EOF

# 二十四节气主题配置开始
# 当前节气：$term $emoji
# 描述：$description

# 节气主题颜色变量
TERM_PRIMARY='\[\033[0;36m\]'    # 主色调
TERM_SECONDARY='\[\033[0;90m\]'  # 次色调
TERM_ACCENT='\[\033[0;32m\]'     # 强调色
TERM_TEXT='\[\033[0;37m\]'       # 文本色
RESET='\[\033[0m\]'              # 重置

# 节气主题提示符
if [ "\$color_prompt" = yes ]; then
    PS1="\${debian_chroot:+(\$debian_chroot)}\${TERM_SECONDARY}┌─[\${TERM_TEXT}\u\${TERM_SECONDARY}@\${TERM_TEXT}\h\${TERM_SECONDARY}]─[\${TERM_PRIMARY}\w\${TERM_SECONDARY}] $emoji \${TERM_TEXT}$term\${TERM_SECONDARY}\n└─\${TERM_ACCENT}\\\$\${RESET} "
else
    PS1='\${debian_chroot:+(\$debian_chroot)}\u@\h:\w\\\$ '
fi

# 节气欢迎信息
if [[ \$- == *i* ]]; then
    echo -e "\${TERM_SECONDARY}╭─────────────────────────────────────────────╮\${NC}"
    echo -e "\${TERM_SECONDARY}│ $emoji \${TERM_TEXT}$term - $description\${TERM_SECONDARY} │\${NC}"
    echo -e "\${TERM_SECONDARY}╰─────────────────────────────────────────────╯\${NC}"
    echo
fi

# 二十四节气主题配置结束
EOF
    
    # 替换bashrc
    mv "$temp_bashrc" ~/.bashrc
    chmod 644 ~/.bashrc
}

# 显示帮助信息
show_help() {
    echo -e "${WHITE}🌸 二十四节气终端配色管理器 🌸${NC}"
    echo
    echo -e "${YELLOW}用法：${NC}"
    echo -e "  $0 [选项] [节气名称]"
    echo
    echo -e "${YELLOW}选项：${NC}"
    echo -e "  ${GREEN}-l, --list${NC}        列出所有二十四节气"
    echo -e "  ${GREEN}-c, --current${NC}     显示当前使用的节气主题"
    echo -e "  ${GREEN}-a, --auto${NC}        根据当前日期自动设置节气主题"
    echo -e "  ${GREEN}-r, --random${NC}      随机选择一个节气主题"
    echo -e "  ${GREEN}-h, --help${NC}        显示此帮助信息"
    echo
    echo -e "${YELLOW}节气名称：${NC}"
    echo -e "  可以使用完整的节气名称，如：立春、雨水、惊蛰等"
    echo
    echo -e "${YELLOW}示例：${NC}"
    echo -e "  $0 立春          # 设置立春主题"
    echo -e "  $0 --list        # 列出所有节气"
    echo -e "  $0 --auto        # 自动设置当前节气主题"
    echo -e "  $0 --random      # 随机选择节气主题"
}

# 列出所有节气
list_solar_terms() {
    echo -e "${WHITE}🌸 二十四节气配色方案 🌸${NC}"
    echo
    
    local seasons=("春季" "夏季" "秋季" "冬季")
    local season_colors=("${GREEN}" "${RED}" "${YELLOW}" "${CYAN}")
    
    for i in {0..3}; do
        echo -e "${season_colors[$i]}${seasons[$i]}：${NC}"
        for j in {0..5}; do
            local index=$((i * 6 + j))
            local term="${SOLAR_TERMS[$index]}"
            local emoji="${SEASON_EMOJI[$term]}"
            local description=$(get_config_value "$term" "description")
            echo -e "  $emoji ${WHITE}$term${NC} - ${GRAY}$description${NC}"
        done
        echo
    done
}

# 显示当前主题
show_current_theme() {
    if [[ -f "$CURRENT_THEME_FILE" ]]; then
        local current=$(cat "$CURRENT_THEME_FILE")
        local emoji="${SEASON_EMOJI[$current]}"
        local description=$(get_config_value "$current" "description")
        echo -e "${WHITE}当前节气主题：${NC}$emoji ${GREEN}$current${NC} - ${GRAY}$description${NC}"
    else
        echo -e "${YELLOW}尚未设置节气主题${NC}"
    fi
}

# 根据日期自动设置节气
auto_set_theme() {
    local month=$(date +%-m)  # 去掉前导零
    local day=$(date +%-d)    # 去掉前导零
    local date_num=$((month * 100 + day))
    
    # 简化的节气日期判断（实际节气日期会有微调）
    local term=""
    if [[ $date_num -ge 204 && $date_num -lt 219 ]]; then term="立春"
    elif [[ $date_num -ge 219 && $date_num -lt 306 ]]; then term="雨水"
    elif [[ $date_num -ge 306 && $date_num -lt 321 ]]; then term="惊蛰"
    elif [[ $date_num -ge 321 && $date_num -lt 405 ]]; then term="春分"
    elif [[ $date_num -ge 405 && $date_num -lt 420 ]]; then term="清明"
    elif [[ $date_num -ge 420 && $date_num -lt 506 ]]; then term="谷雨"
    elif [[ $date_num -ge 506 && $date_num -lt 521 ]]; then term="立夏"
    elif [[ $date_num -ge 521 && $date_num -lt 606 ]]; then term="小满"
    elif [[ $date_num -ge 606 && $date_num -lt 621 ]]; then term="芒种"
    elif [[ $date_num -ge 621 && $date_num -lt 707 ]]; then term="夏至"
    elif [[ $date_num -ge 707 && $date_num -lt 723 ]]; then term="小暑"
    elif [[ $date_num -ge 723 && $date_num -lt 808 ]]; then term="大暑"
    elif [[ $date_num -ge 808 && $date_num -lt 823 ]]; then term="立秋"
    elif [[ $date_num -ge 823 && $date_num -lt 908 ]]; then term="处暑"
    elif [[ $date_num -ge 908 && $date_num -lt 923 ]]; then term="白露"
    elif [[ $date_num -ge 923 && $date_num -lt 1008 ]]; then term="秋分"
    elif [[ $date_num -ge 1008 && $date_num -lt 1023 ]]; then term="寒露"
    elif [[ $date_num -ge 1023 && $date_num -lt 1107 ]]; then term="霜降"
    elif [[ $date_num -ge 1107 && $date_num -lt 1122 ]]; then term="立冬"
    elif [[ $date_num -ge 1122 && $date_num -lt 1207 ]]; then term="小雪"
    elif [[ $date_num -ge 1207 && $date_num -lt 1222 ]]; then term="大雪"
    elif [[ $date_num -ge 1222 || $date_num -lt 106 ]]; then term="冬至"
    elif [[ $date_num -ge 106 && $date_num -lt 120 ]]; then term="小寒"
    elif [[ $date_num -ge 120 && $date_num -lt 204 ]]; then term="大寒"
    fi
    
    if [[ -n "$term" ]]; then
        echo -e "${GREEN}根据当前日期，自动设置为：${SEASON_EMOJI[$term]} $term${NC}"
        set_theme "$term"
    else
        echo -e "${RED}无法确定当前节气，请手动设置${NC}"
    fi
}

# 随机设置主题
random_theme() {
    local random_index=$((RANDOM % 24))
    local term="${SOLAR_TERMS[$random_index]}"
    echo -e "${GREEN}随机选择节气：${SEASON_EMOJI[$term]} $term${NC}"
    set_theme "$term"
}

# 设置主题
set_theme() {
    local term="$1"
    
    # 验证节气名称
    local valid=false
    for solar_term in "${SOLAR_TERMS[@]}"; do
        if [[ "$solar_term" == "$term" ]]; then
            valid=true
            break
        fi
    done
    
    if [[ "$valid" == false ]]; then
        echo -e "${RED}错误：'$term' 不是有效的节气名称${NC}"
        echo -e "${YELLOW}请使用 $0 --list 查看所有可用的节气${NC}"
        exit 1
    fi
    
    local emoji="${SEASON_EMOJI[$term]}"
    local description=$(get_config_value "$term" "description")
    
    echo -e "${GREEN}正在设置节气主题：$emoji $term${NC}"
    echo -e "${GRAY}$description${NC}"
    
    # 应用GNOME Terminal配色
    apply_gnome_terminal_theme "$term"
    
    # 更新bash提示符
    update_bash_prompt "$term"
    
    echo -e "${GREEN}✅ 节气主题设置完成！${NC}"
    echo -e "${YELLOW}请运行 'source ~/.bashrc' 或重新打开终端来查看效果${NC}"
}

# 主程序
main() {
    # 检查配置文件是否存在
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${RED}错误：配置文件 $CONFIG_FILE 不存在${NC}"
        exit 1
    fi
    
    # 解析命令行参数
    case "$1" in
        -h|--help)
            show_help
            ;;
        -l|--list)
            list_solar_terms
            ;;
        -c|--current)
            show_current_theme
            ;;
        -a|--auto)
            auto_set_theme
            ;;
        -r|--random)
            random_theme
            ;;
        "")
            show_help
            ;;
        *)
            set_theme "$1"
            ;;
    esac
}

# 运行主程序
main "$@"
