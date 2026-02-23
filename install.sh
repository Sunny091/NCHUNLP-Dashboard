#!/bin/bash

set -e

echo "=== Dashboard Kiosk 安裝腳本 ==="
echo ""

# 檢測套件管理器並安裝套件
install_packages() {
    echo "[1/3] 安裝所需套件..."

    if command -v apt &> /dev/null; then
        # Debian/Ubuntu
        sudo apt update
        sudo apt install -y chromium-browser wtype
    elif command -v dnf &> /dev/null; then
        # Fedora
        sudo dnf install -y chromium wtype
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        sudo pacman -S --noconfirm chromium wtype
    elif command -v zypper &> /dev/null; then
        # openSUSE
        sudo zypper install -y chromium wtype
    else
        echo "警告: 無法識別套件管理器，請手動安裝 chromium 和 wtype"
        return 1
    fi

    echo "套件安裝完成"
}

# 設定 autostart
setup_autostart() {
    echo "[2/3] 設定開機自動啟動..."

    AUTOSTART_DIR="$HOME/.config/autostart"
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    # 建立 autostart 目錄
    mkdir -p "$AUTOSTART_DIR"

    # 複製 desktop 檔案
    cp "$SCRIPT_DIR/autostart/browser.desktop" "$AUTOSTART_DIR/"
    chmod 644 "$AUTOSTART_DIR/browser.desktop"

    echo "已複製 browser.desktop 到 $AUTOSTART_DIR/"
}

# 安裝控制腳本
install_kiosk_script() {
    echo "[3/3] 安裝控制腳本..."

    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

    # 複製腳本到 /usr/local/bin
    sudo cp "$SCRIPT_DIR/kiodk.sh" /usr/local/bin/kiosk.sh
    sudo chmod 755 /usr/local/bin/kiosk.sh

    echo "已安裝 kiosk.sh 到 /usr/local/bin/"
}

# 主程式
main() {
    install_packages
    echo ""
    setup_autostart
    echo ""
    install_kiosk_script
    echo ""
    echo "=== 安裝完成 ==="
    echo ""
    echo "重新開機後將自動啟動 Dashboard"
    echo "使用 'kiosk.sh {refresh|restart|stop}' 控制瀏覽器"
}

main
