#!/bin/bash

set -e

echo "=== Dashboard Kiosk 安裝腳本 ==="
echo ""

# 檢查並安裝所需套件
install_packages() {
    echo "[1/3] 檢查所需套件..."

    PACKAGES_TO_INSTALL=""

    # 檢查 chromium 是否已安裝
    if command -v chromium &> /dev/null || command -v chromium-browser &> /dev/null; then
        echo "✓ Chromium 已安裝"
    else
        echo "✗ Chromium 未安裝，將進行安裝"
        PACKAGES_TO_INSTALL="chromium"
    fi

    # 檢查 wtype 是否已安裝
    if command -v wtype &> /dev/null; then
        echo "✓ wtype 已安裝"
    else
        echo "✗ wtype 未安裝，將進行安裝"
        PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL wtype"
    fi

    # 如果沒有需要安裝的套件，直接返回
    if [ -z "$PACKAGES_TO_INSTALL" ]; then
        echo "所有套件已就緒"
        return 0
    fi

    # 安裝缺少的套件
    echo "安裝: $PACKAGES_TO_INSTALL"

    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y $PACKAGES_TO_INSTALL
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y $PACKAGES_TO_INSTALL
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm $PACKAGES_TO_INSTALL
    else
        echo "警告: 無法識別套件管理器，請手動安裝: $PACKAGES_TO_INSTALL"
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

    # 複製腳本到 ~/kiosk.sh
    sudo cp "$SCRIPT_DIR/kiosk.sh" ~/kiosk.sh
    sudo chmod 755 ~/kiosk.sh

    echo "已安裝 kiosk.sh 到 ~/kiosk.sh"
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
