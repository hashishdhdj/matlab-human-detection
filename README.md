# MATLAB人类检测程序

基于MATLAB的人类检测程序，支持YOLOv5模型和摄像头实时检测。

## 功能特点

- 支持摄像头实时人脸检测
- 支持图片文件人脸检测
- 使用YOLOv5模型进行目标检测
- 提供图像浏览和结果保存功能
- 自动处理各种异常情况，包括摄像头连接问题和内存不足

## 文件说明

- `main.m` - 主程序入口，包含GUI界面和用户交互代码
- `yolov5fcn.m` - YOLOv5函数封装
- `detect.m` - 目标检测实现
- `checkToolbox.m` - 工具箱检查工具
- `coco.names` - COCO数据集类别名称
- `yolov5s.onnx` - YOLOv5s模型文件

## 系统要求

- MATLAB 2020b或更高版本
- Computer Vision Toolbox
- Deep Learning Toolbox
- Deep Learning Toolbox Converter for ONNX Model Format (支持包)

## 使用方法

1. 运行`main.m`启动程序
2. 点击"浏览图片"选择图像文件或直接使用摄像头
3. 点击"开始检测"进行人脸检测
4. 检测完成后可以点击"保存结果"保存结果图像

## 注意事项

- 如果遇到内存不足问题，程序会自动调整图像尺寸
- 如果遇到摄像头连接问题，可以使用图片浏览功能
- 确保已安装所需的工具箱和支持包，可以运行`checkToolbox.m`进行检查