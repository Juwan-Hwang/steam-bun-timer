# 蒸馒头计时器 · Steam Bun Timer

> 面向中式面食制作的免手操作、多流程并行、数据驱动的计时应用。
> 为双手忙碌的厨房场景而设计——手上沾着面、耳边是灶火声、同时盯着几盆面。

## 核心特性

### 🍞 多流程并行看板

- 同时管理 1\~6 个批次，卡片按紧急程度自动排序
- **烧水与发酵尾部并行**：发酵剩 3 分钟时自动提醒烧水，两段倒计时同卡双行显示
- 颜色即状态：蓝（进行中）→ 黄（即将到点）→ 红（需要操作）→ 绿（完成）

### 👆 免手操作四层冗余

| 层级 | 方案 | 说明 |
|---|---|---|
| 一 | 自动排程 + 动作节点确认 | 纯等待阶段自动推进，只在动手节点需确认一次 |
| 二 | 蓝牙物理按钮 | BLE HID 遥控器，配对即键盘，复用按键监听 |
| 三 | 音量键快捷确认 | 上下键都等同「确认 / 停止响铃」，零成本高可靠 |
| 四 | 语音指令（V2） | 四川话 KWS，固定词集，识别失败震动降级 |

### 🔔 厨房级提醒可靠性

- 全屏红色闪烁 + 最大音量铃声 + 川话语音播报（分段录音拼接）
- 前台服务保活 + AlarmManager 精确闹钟兜底
- 崩溃 / 重启恢复：关键时间戳持久化到 SQLite，重启后自动重建倒计时
- 权限检查清单页：通知 / 精确闹钟 / 电池优化 / 定位，逐项状态灯

### 📊 数据自动沉淀

- 记录每个关键动作的**时间戳**（非计时读数），时长由时间戳相减得出
- 低置信度标记：响应超时自动打标，可过滤污染数据
- 评价系统：正好 / 还不够（续时循环）/ 发过了
- 气温采集：发酵时调用天气 API，失败降级为空不阻塞
- 一键导出 CSV，供离线分析

### 🎨 精准微调三件套

- **+1 / −1 大按钮**：随时可点，按了立刻生效
- **大跨度滑动条**：区间内线性映射，手背即可拖动
- **数字键盘**：长按 1 秒激活，防误触，精确输入任意时长

## 预置模板

| 品种 | 工序链 |
|---|---|
| 白馒头 | 发酵 30min →（并行）烧水 5min → 蒸制 15min → 焖制 5min → 揭锅 |
| 甜馒头 | 发酵 28min → 烧水 5min → 蒸制 15min → 焖制 5min → 揭锅 |
| 小馒头 | 发酵 40min → 烧水 5min → 蒸制 15min → 焖制 5min → 揭锅 |
| 饼子 | 翻面 4min → 出锅 4min（支持「再来一锅」快捷重启） |

## 技术栈

| 层级 | 选型 |
|---|---|
| 跨平台框架 | Flutter 3.x (Dart) |
| UI / 状态管理 | Material 3 + Riverpod |
| 本地存储 | SQLite (Drift) + shared_preferences |
| 后台计时 | Foreground Service + AlarmManager |
| 语音播报 | 预录音频分段拼接（audioplayers） |
| 语音识别 (V2) | sherpa-onnx KWS（框架已就绪） |
| 气温采集 | 和风天气 API + Geolocator |
| 屏幕控制 | wakelock_plus（常亮 / 防烧屏微移） |

## 项目结构

```
lib/
├── main.dart                         入口：服务初始化 + 崩溃恢复
├── theme/app_tokens.dart             Zephyr Design System → Flutter ThemeData
├── models/
│   ├── recipe.dart                   4 种预置模板 + 工序节点定义
│   └── batch.dart                    批次状态机：并行步骤 / 焖制计时 / 续时日志
├── data/database.dart                Drift SQLite：批次记录 / 模板 / 习惯值 + CSV 导出
├── utils/
│   ├── number_pool.dart              编号回收复用
│   └── season_util.dart              季节计算 + 气温分桶
├── services/
│   ├── announcement_player.dart      川话播报：分段录音拼接
│   ├── trigger_source.dart           触发源抽象：音量键 / 蓝牙
│   ├── weather_service.dart          和风天气 API + 降级
│   ├── foreground_task_handler.dart  MethodChannel：前台服务 / 精确闹钟 / 权限
│   ├── reminder_manager.dart         提醒管理器 + 全屏闪烁覆盖层
│   ├── batch_persistence.dart        崩溃恢复：JSON 持久化 + 重建
│   ├── screen_controller.dart        屏幕常亮 / 防烧屏微移
│   ├── habit_default_service.dart    V2 习惯默认值
│   └── voice_command_service.dart    V2 KWS 框架 + 震动降级
├── providers/app_providers.dart      全功能状态机：并行 / 超时 / 低置信度 / 入库
├── widgets/
│   ├── batch_card.dart               并行双行 / 滑动条 / 数字键盘 / 长按取消
│   ├── time_slider.dart              大号滑动条 + 区间分档
│   └── number_pad.dart               数字键盘 + 长按 1 秒激活
└── screens/
    ├── dashboard_screen.dart         主看板：排序 / 全屏提醒 / 音量键 / 语音
    ├── recipe_select_screen.dart     模板选择 + V2 习惯默认值提示
    ├── settings_screen.dart          全设置项
    ├── permission_checklist_screen.dart  权限检查清单（状态灯）
    └── data_export_screen.dart       CSV 导出 UI
```

## 工序状态机

```
开始发酵 → [发酵倒计时] → 发酵评价（正好/还不够/发过了）
                                    ↓ 还不够
                              续时循环 ←─────┘
                                    ↓ 正好/发过了
              [发酵剩3min] → 该烧水了（并行）→ 烧水倒计时
                                                    ↓
                                            该上锅了 → 蒸制倒计时
                                                            ↓
                                                    该关火了 → 焖制（静默5min）
                                                                    ↓
                                                            可以揭锅了 → 揭锅完成
```

## 版本路线

| 版本 | 内容 | 状态 |
|---|---|---|
| V1 | 核心可用：看板 / 并行 / 川话播报 / 保活 / 崩溃恢复 / 音量键 / 数据采集 | ✅ 已实现 |
| V2 | 免触增强：语音指令 KWS / 习惯默认值 | ✅ 已实现 |
| V3 | 数据应用：气温-发酵时长模型 / iOS 适配 | 📋 待数据积累 |

## 快速开始

```bash
# 安装依赖
flutter pub get

# 生成 Drift 代码
dart run build_runner build --delete-conflicting-outputs

# 运行
flutter run

# 构建 APK
flutter build apk --release
```

### 川话播报音频

在 `assets/audio/` 目录放入 12 条短音频（详见 `lib/services/announcement_player.dart` 中的文案清单）：

| 段 | 内容 | 条数 |
|---|---|---|
| 数字段 | 1号 / 2号 / 3号 | 3 |
| 品种段 | 白馒头 / 甜馒头 / 小馒头 / 饼子 | 4 |
| 动作段 | 该烧水了 / 该上锅了 / 发酵好了 / 该关火了 / 可以揭锅了 | 5 |

## 设计原则

- **上手零门槛**：一切操作做减法，一次确认能完成绝不让点两次
- **免手优先**：先问「能不能不碰屏幕」，再问「能不能少碰屏幕」
- **本地优先**：语音与数据全部本地处理，离线可用、无流量、保护隐私
- **数据是长期资产**：记录真实完成时长，字段第一天备齐
- **温度即变量**：气温作为发酵时间波动的主因和未来模型的核心特征

## License

MIT
