#!/bin/bash
export WAYLAND_DISPLAY=wayland-0
export XDG_RUNTIME_DIR=/run/user/1000

# Dashboard URL
URL="http://192.168.10.100:27721/"

# Chromium 啟動參數 (針對 Raspberry Pi 優化)
CHROMIUM_FLAGS=(
    --kiosk
    --ozone-platform=wayland
    --noerrdialogs
    --disable-infobars
    --force-device-scale-factor=0.88
    # 隱藏滾動條
    --enable-features=OverlayScrollbar
    --hide-scrollbars
    # 記憶體優化 (Pi 3 只有 1GB RAM)
    --disable-gpu
    --disable-software-rasterizer
    --disable-dev-shm-usage
    --disable-background-networking
    --disable-sync
    --disable-translate
    --disable-features=TranslateUI
    --no-first-run
    --no-default-browser-check
    --process-per-site
    --disable-extensions
    # JavaScript 記憶體限制
    --js-flags="--max-old-space-size=256"
)

kill_browser() {
    # 先嘗試正常終止
    pkill -TERM chromium 2>/dev/null
    sleep 1
    # 如果還在運行，強制終止
    if pgrep chromium > /dev/null; then
        pkill -9 chromium 2>/dev/null
        sleep 1
    fi
    # 確保所有相關進程都被終止
    pkill -9 -f "chromium" 2>/dev/null
    sleep 1
}

start_browser() {
    # 清理一些快取記憶體 (需要在 sudoers 設定免密碼)
    sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1 || true

    # 啟動瀏覽器
    chromium "${CHROMIUM_FLAGS[@]}" "$URL" &
}

case "$1" in
    refresh)
        wtype -k F5
        ;;
    restart)
        kill_browser
        start_browser
        ;;
    stop)
        kill_browser
        ;;
    status)
        if pgrep chromium > /dev/null; then
            echo "Chromium is running"
            echo "Memory usage:"
            ps aux | grep chromium | grep -v grep | awk '{sum+=$6} END {print sum/1024 " MB"}'
        else
            echo "Chromium is not running"
        fi
        ;;
    *)
        echo "Usage: kiosk.sh {refresh|restart|stop|status}"
        ;;
esac
