VPS自動化監控系統

項目概述

企業級VPS自動化監控解決方案 用於快速部署伺服器安全加固和全棧監控服務 包含系統硬化容器編排系統監控和可視化展示

核心特性

伺服器自動化硬化
SSH端口自定義為2222並強制密鑰認證
自動配置SELinux防火牆Fail2ban等安全組件
Docker引擎自動部署

監控系統架構

使用Docker Compose編排6個微服務容器

1 HAProxy反向代理 基於主機名路由流量到後端服務
2 Prometheus 15秒採集指標循環 存儲時序數據
3 Node-Exporter 採集主機系統指標CPU內存磁盤網路
4 cAdvisor 採集Docker容器資源消耗數據
5 Grafana 可視化Prometheus數據 預設儀表板展示
6 Cloudflared 安全隧道無需暴露公網端口

工作流程

執行setup.sh完成系統初始化
執行docker-compose up啟動所有服務
HAProxy監聽80端口根據域名轉發請求
Prometheus每15秒採集Node-Exporter和cAdvisor數據
所有監控數據存儲在prometheus-data卷保證持久化
Grafana自動加載預配置數據源和儀表板
Cloudflared建立安全隧道供外部訪問

技術棧

Linux系統管理 SELinux防火牆Fail2ban
Docker容器化 docker-compose編排
開源監控 Prometheus Grafana
網路安全 HAProxy負載均衡 Cloudflare隧道
基礎設施代碼化 Shell腳本自動化
