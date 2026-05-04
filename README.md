VPS自动化监控系统

项目概述

这是一个企业级VPS自动化监控解决方案项目，用于快速部署安全加固和全栈监控服务。包括服务器硬化、容器编排、系统监控、可视化展示和安全隧道接入。

核心特性

服务器自动化硬化
- SSH安全配置迁移到自定义端口2222提高安全性
- 密钥认证强制策略移除弱密码认证
- SELinux策略自动管理适配非标准SSH端口
- Firewalld动态防火墙规则自动配置
- Fail2ban入侵防御带永久IP黑名单机制
- Docker引擎自动部署容器化应用栈

全栈监控架构

系统采用微服务架构共包含6大核心组件

1 HAProxy反向代理层
充当所有服务的入口网关
基于主机名虚拟主机路由流量到不同后端
prometheus.lab-hc.cloud → Prometheus服务9090端口
grafana.lab-hc.cloud → Grafana服务3000端口
cadvisor.lab-hc.cloud → cAdvisor容器监控8080端口

2 Prometheus时序数据库
核心监控指标收集引擎
15秒间隔周期性采集各采集器数据
存储于容器共享卷prometheus-data保证数据持久化
从三个数据源采集指标

3 Node-Exporter系统监控
采集主机操作系统级别指标
CPU内存磁盘网络等系统资源使用情况
运行于host网络命名空间确保准确获取系统信息

4 cAdvisor容器监控
Google开发的容器资源监控工具
实时采集Docker容器CPU内存网络IO等详细指标
15秒间隔采集周期优化性能和精度平衡
禁用加速器CPU拓扑等非必需指标减少开销

5 Grafana数据可视化
基于Prometheus数据源构建可视化仪表板
自动化预配置数据源和仪表板定义
Docker-containers.json展示容器实时监控数据
Node-exporter.json展示主机系统监控数据
支持多用户认证管理访问控制

6 Cloudflared安全隧道
Cloudflare内网穿透解决方案
通过HTTP2隧道协议建立到Cloudflare边缘节点的安全连接
无需暴露公网端口实现远程访问
使用GitHub Secrets管理敏感的隧道令牌

流程架构图

用户访问
    ↓
Cloudflared隧道
    ↓
HAProxy反向代理 端口80
    ↓
╔════════════════════════════════════════╗
║      基于主机名的路由规则             ║
╚════════════════════════════════════════╝
    ↙              ↓              ↖
Prometheus    Grafana        cAdvisor
9090端口       3000端口       8080端口
    ↓
┌─────────────────────────────────────┐
│  Prometheus 15s采集指标循环          │
└─────────────────────────────────────┘
    ↙              ↓              ↖
Node-Exporter cAdvisor Prometheus自身
采集主机指标    采集容器指标   监控系统状态
    ↓
┌──────────────────────────────────┐
│ Prometheus时序数据库存储         │
│ prometheus-data共享卷            │
└──────────────────────────────────┘
    ↓
Grafana数据查询与可视化
    ↓
┌──────────────────────────────────┐
│ 预配置仪表板展示                  │
│ docker-containers.json            │
│ node-exporter.json                │
└──────────────────────────────────┘

数据流向说明

1 数据采集阶段
Node-Exporter通过host进程命名空间采集真实主机信息
cAdvisor读取cgroup接口采集容器资源消耗
Prometheus定时爬取两者暴露的metrics端点

2 数据存储阶段
所有时序数据存入prometheus-data共享卷
采用TSDB格式支持长期历史数据查询
Docker容器重启后数据完全保留

3 数据展示阶段
Grafana启动时自动加载预配置数据源
连接到Prometheus查询历史指标数据
根据仪表板JSON定义生成交互式图表

4 访问控制阶段
用户通过Cloudflared隧道安全访问内网服务
HAProxy根据请求主机名进行流量转发
支持多个虚拟主机并行服务

存储结构说明

prometheus-data 时序指标数据持久化存储
grafana-data Grafana用户配置和仪表板数据
grafana/dashboards 预定义仪表板JSON模板文件
grafana/provisioning 自动化预配置定义文件

配置工作流

执行setup.sh脚本完成初始化
- AlmaLinux系统更新与base工具包安装
- 安全组件Firewalld Fail2ban安装
- Docker及docker-compose-plugin部署
- SELinux策略SSH端口绑定

执行docker-compose启动服务栈
- 拉取所有容器镜像
- 挂载配置文件和数据卷
- 建立monitor-net桥接网络连接
- 容器自动重启确保高可用

项目应用价值

生产环境实用性强
- 自动化减少人工配置时间
- 全面的监控覆盖系统和容器两个层面
- 安全隧道避免直接端口暴露
- 持久化存储支持长期数据分析

简历展现力度强
- 涵盖Linux系统管理SELinux防火墙等知识
- 容器技术Docker Compose实战经验
- 开源监控栈Prometheus Grafana应用
- 网络和安全知识HAProxy Cloudflare隧道
- Shell脚本编写自动化能力
- 基础设施代码化IaC理念体现
