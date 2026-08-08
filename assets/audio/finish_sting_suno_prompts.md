# 出锅庆祝音效 · Suno 生成提示词

> 目标文件：`assets/audio/finish_sting.mp3`
> 代码已按文件名引用（`lib/services/finish_feedback.dart`），生成后放入此目录即可，缺失时 App 静默降级（只有震动+动效），不会报错。

## 音效结构（与震动鼓点对帧）

震动模式是「哒(轻) → 哒(中) → 咚!(重)」三段鼓点，音效请生成对应的
**「蒸汽嗤声 → 编钟/马林巴上扬 → 锣声定音」** 三段结构，总时长 **2~2.5 秒**：

| 时间 | 声音 | 震动 | 动效 |
|------|------|------|------|
| 0.0s | 蒸汽嗤声起（白噪声质感） | 哒 · 轻 | 金色闪光 + 冲击波扩散 |
| 0.3s | 编钟/木琴三音上扬 | 哒 · 中 | 蒸汽金粒子飘散 |
| 0.6s | 锣声/暖钟声定音（大调终止） | 咚! · 重 | 印章砸落定格 |
| 0.6s+ | 自然衰减尾音 | — | 整体淡出 |

## Suno 使用要点

1. 开 **Instrumental**（无人声），Model 选最新版
2. 生成后用剪辑软件裁到 2~2.5 秒、响度归一化到 -14 LUFS 左右
3. 导出 MP3（128kbps 足够），重命名为 `finish_sting.mp3` 放进 `assets/audio/`
4. 多生成几版挑最「暖」的 — 这是厨房，不是电竞房

## 提示词（复制到 Style 输入框）

### 方案 A · 中式温暖（推荐，最贴主题）

```
short celebratory cooking completion sting, gentle steam hiss opening, warm bamboo wind chimes and guzheng glissando rising, soft Chinese gong hit resolving on a bright major chord, cozy kitchen atmosphere, heartwarming and satisfying, acoustic folk instruments, clean dry mix, 2 seconds, instrumental sound effect, no vocals, no drums
```

### 方案 B · 游戏成就音（更「爽」）

```
tiny game achievement fanfare, soft riser whoosh into glockenspiel and marimba three-note ascending motif, ends with warm bell ding on major chord, satisfying mission-complete jingle, bright and sparkly, tight reverb tail, 2 to 3 seconds stinger, instrumental, no vocals
```

### 方案 C · 治愈蒸汽系（最轻柔）

```
cozy ASMR reward sound effect, soft steam burst layered with warm felt piano notes and a subtle harp arpeggio, gentle wooden lid thump as the final hit, calming and deeply satisfying, lo-fi warmth, 2 to 3 seconds, instrumental, no vocals
```

### 方案 D · 川话人声彩蛋（可选第二文件）

如果想玩彩蛋，可以生成一条人声版，重命名为 `finish_sting_vocal.mp3`，手动替换试听：

```
Style: cheerful short vocal sting, warm middle-aged Chinese woman happily calling out in sing-song rising tone, Sichuan dialect flavor, cozy kitchen reverb, a cappella, 2 seconds
Lyrics: 出锅咯～！巴适！
```

> 注意：人声版要手动改代码引用或在设置里加开关，默认请先用纯音乐版 A/B/C。
