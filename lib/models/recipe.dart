/// 流程模板（Recipe）和工序定义
/// 严格对应设计方案 §1.1 流程模板 和 §6 工序状态机规格
library;


/// 工序类型
enum StepType {
  /// 发酵 — 有倒计时，结束时弹评价
  fermentation,

  /// 烧水 — 有倒计时，与发酵尾部并行
  boiling,

  /// 蒸制 — 有倒计时
  steaming,

  /// 焖制 — 无倒计时、无闹钟，后台静默计时
  simmering,

  /// 翻面（饼子）— 有倒计时
  flipping,

  /// 出锅确认 — 无倒计时
  plateOut,

  /// 揭锅确认 — 无倒计时
  uncover,
}

/// 工序节点定义
/// 对应 §6 状态机表的每一行
class StepNode {
  final StepType type;
  final String label;

  /// 默认时长（分钟），null = 无倒计时
  final int? defaultDurationMinutes;

  /// 入口条件描述
  final String entryCondition;

  /// 界面按钮/状态描述
  final String uiState;

  /// 播报文案段（动作段），null = 无播报
  final String? announcementAction;

  /// 超时阈值（分钟），null = 无超时
  final int? timeoutMinutes;

  /// 超时行为描述
  final String? timeoutBehavior;

  /// 是否需要手动确认才进入下一步
  final bool requiresConfirmation;

  /// 是否为并行工序（如烧水与发酵尾部并行）
  final bool isParallel;

  /// 并行触发条件：在哪个工序剩多少分钟时启动
  final (StepType, int)? parallelTrigger;

  const StepNode({
    required this.type,
    required this.label,
    this.defaultDurationMinutes,
    required this.entryCondition,
    required this.uiState,
    this.announcementAction,
    this.timeoutMinutes,
    this.timeoutBehavior,
    this.requiresConfirmation = true,
    this.isParallel = false,
    this.parallelTrigger,
  });
}

/// 评价结果 — §4.3
enum FermentationResult {
  /// 正好 — 发酵到位
  perfect,

  /// 还不够 — 发酵不足，进入续时循环
  notEnough,

  /// 发过了 — 发酵过头
  overFermented,
}

/// 流程模板
/// 对应 §1.1 预置模板表
class Recipe {
  final String id;
  final String name;

  /// 工序链
  final List<StepNode> steps;

  /// 发酵合理区间（分钟），用于滑动条分档
  final (int, int) fermentationRange;

  /// 品种段播报文案（用于川话拼接）
  final String announcementName;

  const Recipe({
    required this.id,
    required this.name,
    required this.steps,
    required this.fermentationRange,
    required this.announcementName,
  });

  /// 白馒头模板
  static const whiteBun = Recipe(
    id: 'white_bun',
    name: '白馒头',
    announcementName: '白馒头',
    fermentationRange: (15, 45),
    steps: [
      StepNode(
        type: StepType.fermentation,
        label: '发酵',
        defaultDurationMinutes: 30,
        entryCondition: '点「开始」（记录时间戳）',
        uiState: '卡片进入发酵态（蓝）',
        requiresConfirmation: true,
      ),
      StepNode(
        type: StepType.boiling,
        label: '烧水',
        defaultDurationMinutes: 5,
        entryCondition: '发酵剩 3 min',
        uiState: '卡片显示「已开始烧水」大按钮（黄）',
        announcementAction: '该烧水了',
        timeoutMinutes: 2,
        timeoutBehavior: '2 分钟后每 30 秒间歇提醒直到确认',
        requiresConfirmation: true,
        isParallel: true,
        parallelTrigger: (StepType.fermentation, 3),
      ),
      StepNode(
        type: StepType.steaming,
        label: '蒸制',
        defaultDurationMinutes: 15,
        entryCondition: '烧水完成（并行）',
        uiState: '卡片显示「已开始蒸」大按钮（黄）',
        announcementAction: '该上锅了',
        timeoutMinutes: 2,
        timeoutBehavior: '同上',
        requiresConfirmation: true,
      ),
      StepNode(
        type: StepType.simmering,
        label: '焖制',
        defaultDurationMinutes: 5,
        entryCondition: '蒸制完成',
        uiState: '卡片显示「焖制中」（静默，无倒计时）',
        announcementAction: '该关火了',
        requiresConfirmation: false,
      ),
      StepNode(
        type: StepType.uncover,
        label: '揭锅',
        entryCondition: '焖制后母亲揭锅',
        uiState: '卡片完成态（绿）',
        announcementAction: '可以揭锅了',
        requiresConfirmation: true,
      ),
    ],
  );

  /// 甜馒头模板
  static const sweetBun = Recipe(
    id: 'sweet_bun',
    name: '甜馒头',
    announcementName: '甜馒头',
    fermentationRange: (15, 45),
    steps: [
      StepNode(
        type: StepType.fermentation,
        label: '发酵',
        defaultDurationMinutes: 28,
        entryCondition: '点「开始」（记录时间戳）',
        uiState: '卡片进入发酵态（蓝）',
        requiresConfirmation: true,
      ),
      StepNode(
        type: StepType.boiling,
        label: '烧水',
        defaultDurationMinutes: 5,
        entryCondition: '发酵剩 3 min',
        uiState: '卡片显示「已开始烧水」大按钮（黄）',
        announcementAction: '该烧水了',
        timeoutMinutes: 2,
        timeoutBehavior: '2 分钟后每 30 秒间歇提醒直到确认',
        requiresConfirmation: true,
        isParallel: true,
        parallelTrigger: (StepType.fermentation, 3),
      ),
      StepNode(
        type: StepType.steaming,
        label: '蒸制',
        defaultDurationMinutes: 15,
        entryCondition: '烧水完成（并行）',
        uiState: '卡片显示「已开始蒸」大按钮（黄）',
        announcementAction: '该上锅了',
        timeoutMinutes: 2,
        timeoutBehavior: '同上',
        requiresConfirmation: true,
      ),
      StepNode(
        type: StepType.simmering,
        label: '焖制',
        defaultDurationMinutes: 5,
        entryCondition: '蒸制完成',
        uiState: '卡片显示「焖制中」（静默，无倒计时）',
        announcementAction: '该关火了',
        requiresConfirmation: false,
      ),
      StepNode(
        type: StepType.uncover,
        label: '揭锅',
        entryCondition: '焖制后母亲揭锅',
        uiState: '卡片完成态（绿）',
        announcementAction: '可以揭锅了',
        requiresConfirmation: true,
      ),
    ],
  );

  /// 小馒头模板
  static const smallBun = Recipe(
    id: 'small_bun',
    name: '小馒头',
    announcementName: '小馒头',
    fermentationRange: (20, 60),
    steps: [
      StepNode(
        type: StepType.fermentation,
        label: '发酵',
        defaultDurationMinutes: 40,
        entryCondition: '点「开始」（记录时间戳）',
        uiState: '卡片进入发酵态（蓝）',
        requiresConfirmation: true,
      ),
      StepNode(
        type: StepType.boiling,
        label: '烧水',
        defaultDurationMinutes: 5,
        entryCondition: '发酵剩 3 min',
        uiState: '卡片显示「已开始烧水」大按钮（黄）',
        announcementAction: '该烧水了',
        timeoutMinutes: 2,
        timeoutBehavior: '2 分钟后每 30 秒间歇提醒直到确认',
        requiresConfirmation: true,
        isParallel: true,
        parallelTrigger: (StepType.fermentation, 3),
      ),
      StepNode(
        type: StepType.steaming,
        label: '蒸制',
        defaultDurationMinutes: 15,
        entryCondition: '烧水完成（并行）',
        uiState: '卡片显示「已开始蒸」大按钮（黄）',
        announcementAction: '该上锅了',
        timeoutMinutes: 2,
        timeoutBehavior: '同上',
        requiresConfirmation: true,
      ),
      StepNode(
        type: StepType.simmering,
        label: '焖制',
        defaultDurationMinutes: 5,
        entryCondition: '蒸制完成',
        uiState: '卡片显示「焖制中」（静默，无倒计时）',
        announcementAction: '该关火了',
        requiresConfirmation: false,
      ),
      StepNode(
        type: StepType.uncover,
        label: '揭锅',
        entryCondition: '焖制后母亲揭锅',
        uiState: '卡片完成态（绿）',
        announcementAction: '可以揭锅了',
        requiresConfirmation: true,
      ),
    ],
  );

  /// 饼子模板
  static const flatbread = Recipe(
    id: 'flatbread',
    name: '饼子',
    announcementName: '饼子',
    fermentationRange: (0, 0),
    steps: [
      StepNode(
        type: StepType.flipping,
        label: '翻面',
        defaultDurationMinutes: 4,
        entryCondition: '点「开始」（记录时间戳）',
        uiState: '卡片进入翻面态（蓝）',
        announcementAction: '该翻面了',
        requiresConfirmation: true,
      ),
      StepNode(
        type: StepType.plateOut,
        label: '出锅',
        defaultDurationMinutes: 4,
        entryCondition: '翻面完成',
        uiState: '卡片显示「已出锅」大按钮',
        announcementAction: '可以出锅了',
        requiresConfirmation: true,
      ),
    ],
  );

  /// 全部预置模板
  static const List<Recipe> presets = [whiteBun, sweetBun, smallBun, flatbread];
}
