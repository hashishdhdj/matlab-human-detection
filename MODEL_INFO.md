# YOLOv5 模型信息

由于YOLOv5s.onnx模型文件较大（约28MB），无法直接上传至GitHub仓库。您需要自行下载并添加到项目中。

## 下载YOLOv5模型

您可以从以下位置下载YOLOv5模型：

1. 官方YOLOv5仓库: https://github.com/ultralytics/yolov5
2. ONNX模型格式: https://github.com/ultralytics/yolov5/releases

## 模型文件要求

- 文件名: `yolov5s.onnx`
- 位置: 将下载的模型文件放在项目根目录下

## 支持包要求

除了模型文件，您还需要安装以下MATLAB支持包：

1. Deep Learning Toolbox Converter for ONNX Model Format

您可以通过以下命令安装该支持包：
```matlab
matlab.addons.supportpackage.internal.explorer.showSupportPackages('ONNXCONVERTER', 'tripwire')
```

或者通过MATLAB主页 -> 附加功能 -> 获取附加功能，搜索"ONNX"进行安装。