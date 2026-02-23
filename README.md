# Dashboard Kiosk

實驗室 Dashboard 自動顯示系統，開機後自動以 Chromium Kiosk 模式開啟網頁。

針對 Raspberry Pi 3 優化，解決記憶體不足與長時間運行穩定性問題。

## 環境需求

- Raspberry Pi 3 (或其他 Linux 設備)
- Wayland 桌面環境
- Chromium 瀏覽器
- wtype (Wayland 鍵盤模擬工具)

## 安裝

執行初始化腳本：

```bash
chmod +x install.sh
./install.sh
```

腳本會自動：
1. 安裝所需套件 (chromium, wtype)
2. 將 autostart 設定檔複製到 `~/.config/autostart/`
3. 安裝控制腳本到 `/usr/local/bin/`

## 使用方式

### 自動啟動

重新開機後，系統會自動以 Kiosk 模式開啟 Chromium 並顯示 Dashboard。

### 手動控制

```bash
# 重新整理頁面 (F5)
kiosk.sh refresh

# 重啟瀏覽器
kiosk.sh restart

# 關閉瀏覽器
kiosk.sh stop

# 查看狀態與記憶體使用量
kiosk.sh status
```

## Raspberry Pi 優化

### 已套用的優化

腳本已針對 Pi 3 的 1GB RAM 限制進行優化：
- 隱藏滾動條 (`--hide-scrollbars`)
- 禁用 GPU 加速（Pi 3 支援不佳）
- 限制 JavaScript 記憶體使用 (256MB)
- 禁用不必要的功能（同步、翻譯、擴充套件等）
- 使用 `pkill -9` 強制終止凍結的進程
- 重啟時清理系統快取

### 設定定期自動重啟（建議）

由於 Chromium 長時間運行會有記憶體洩漏問題，建議設定 cron 每天自動重啟：

```bash
# 編輯 crontab
crontab -e

# 加入以下行（每天凌晨 4 點重啟瀏覽器）
0 4 * * * /usr/local/bin/kiosk.sh restart
```

### 設定免密碼清理快取（可選）

為了讓重啟時能清理系統快取，可設定 sudoers：

```bash
sudo visudo

# 加入以下行（將 pi 換成你的使用者名稱）
pi ALL=(ALL) NOPASSWD: /usr/bin/tee /proc/sys/vm/drop_caches
```

### 增加 Swap（可選）

如果經常遇到記憶體不足：

```bash
# 編輯 swap 設定
sudo nano /etc/dphys-swapfile

# 將 CONF_SWAPSIZE 改為 512 或 1024
CONF_SWAPSIZE=512

# 重啟 swap 服務
sudo systemctl restart dphys-swapfile
```

## 設定說明

### Dashboard URL

預設 URL: `http://192.168.10.100:27721/`

如需修改，請編輯 `kiodk.sh` 中的 `URL` 變數。

### 縮放比例

預設縮放比例為 0.88，可調整 `--force-device-scale-factor` 參數。

## 檔案結構

```
dashboard/
├── README.md           # 說明文件
├── install.sh          # 安裝腳本
├── kiodk.sh            # 控制腳本
└── autostart/
    └── browser.desktop # 自動啟動設定檔
```

## 故障排除

### 瀏覽器無法重啟

檢查進程是否完全終止：
```bash
ps aux | grep chromium
# 如果還有殘留進程，手動強制終止
sudo pkill -9 chromium
```

### 查看記憶體使用

```bash
free -h
kiosk.sh status
```

### SSH 重啟時環境變數問題

確保 `WAYLAND_DISPLAY` 和 `XDG_RUNTIME_DIR` 設定正確。如果使用者 UID 不是 1000，請修改 `kiodk.sh` 中的 `XDG_RUNTIME_DIR` 路徑。
