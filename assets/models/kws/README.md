# Sherpa-ONNX KWS 模型

## 模型文件说明

本目录放置 sherpa-onnx 关键词识别（KWS）模型文件。

## 模型来源

模型来源：https://huggingface.co/csukuangfj2/sherpa-onnx-apk/tree/main/kws/1.13.4

从 APK `sherpa-onnx-1.13.4-arm64-v8a-kws-zh-wenetspeech-zipformer.apk` 中提取

## 模型文件列表

- **encoder-epoch-99-avg-1-chunk-16-left-64.onnx** - 编码器模型
- **decoder-epoch-99-avg-1-chunk-16-left-64.onnx** - 解码器模型
- **joiner-epoch-99-avg-1-chunk-16-left-64.onnx** - Joiner 模型
- **tokens.txt** - 词表文件
- **keywords.txt** - 关键词定义文件

## 模型信息

- 模型类型：Zipformer Transducer
- 训练数据：WenetSpeech（中文）
- 模型大小：约 30MB
- 采样率：16kHz

## 预置关键词

当前模型预置以下唤醒词：
- 你好军哥
- 蛋哥蛋哥
- 小爱同学
- 你好问问
- 小艺小艺
- 小米小米
- 林美丽
- 你好西西

## 自定义关键词

如需自定义关键词，需要重新训练模型或使用其他支持自定义关键词的模型。

## 注意事项

- 模型文件较大（约 30MB），首次构建时会打包进 APK
- 如果不需要语音功能，可以删除 `sherpa_onnx` 依赖
- 语音功能默认关闭，需要在设置中开启
