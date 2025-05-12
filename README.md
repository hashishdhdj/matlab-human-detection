# MATLAB人类检测程序

基于MATLAB的人类检测程序，支持YOLOv5模型和摄像头实时检测。

## 功能特点

- 支持摄像头实时人脸检测
- 支持图片文件人脸检测
- 使用YOLOv4/v5模型或MATLAB内置的计算机视觉功能
- 支持面部特征检测（眼睛、鼻子、嘴巴）
- 支持多人脸同时跟踪
- 提供图像浏览和结果保存功能
- 自动处理各种异常情况，包括摄像头连接问题和内存不足

## 文件说明

- `main.m` - 原始主程序入口，包含GUI界面和YOLOv5集成
- `checkToolbox.m` - 工具箱检查工具
- `face_detection.m` - 简单人脸检测脚本（基于vision.CascadeObjectDetector）
- `eye_detection.m` - 眼睛检测脚本
- `human_feature_detection.m` - 综合人体特征检测脚本（人脸、眼睛、鼻子、嘴巴）
- `multiple_face_tracking.m` - 多人脸检测与跟踪（基于KLT算法）
- `MultiObjectTrackerKLT.m` - 多对象跟踪器类
- `simple_webcam_yolov4.m` - 简化版YOLOv4摄像头检测脚本
- `coco.names` - COCO数据集类别名称
- `yolov5s.onnx` - YOLOv5s模型文件（需自行下载）

## 系统要求

- MATLAB 2020b或更高版本
- Computer Vision Toolbox
- 如需YOLOv4/v5功能：Deep Learning Toolbox
- 如需YOLOv5功能：Deep Learning Toolbox Converter for ONNX Model Format (支持包)

## 使用方法

### 简单人脸检测（不需要YOLOv5）

1. 运行`face_detection.m`脚本
2. 程序将尝试打开摄像头并实时检测人脸
3. 如果摄像头不可用，将提示选择图片文件
4. 检测结果可以保存到磁盘

### 眼睛检测

1. 运行`eye_detection.m`脚本
2. 程序会检测人脸和眼睛
3. 按ESC键退出实时检测模式

### 综合人体特征检测

1. 运行`human_feature_detection.m`脚本
2. 程序会同时检测人脸、眼睛、鼻子和嘴巴
3. 各特征用不同颜色的边框和标签标记

### 多人脸检测与跟踪

1. 运行`multiple_face_tracking.m`脚本
2. 程序会实时检测和跟踪多个人脸
3. 使用KLT算法进行特征点跟踪
4. 按ESC键退出

### YOLOv4实时目标检测

1. 运行`simple_webcam_yolov4.m`脚本
2. 程序会自动下载YOLOv4-tiny预训练模型（首次运行）
3. 支持80种COCO数据集物体类别的实时检测
4. 按ESC键退出

### YOLOv5检测（需要额外配置）

1. 下载YOLOv5s.onnx模型文件并放在项目根目录
2. 运行`main.m`启动程序
3. 点击"浏览图片"选择图像文件或直接使用摄像头
4. 点击"开始检测"进行检测
5. 检测完成后可以点击"保存结果"保存结果图像

## 注意事项

- 如遇内存不足问题，程序会自动调整图像尺寸
- 如遇摄像头连接问题，可使用图片浏览功能
- 确保已安装所需的工具箱和支持包，可运行`checkToolbox.m`进行检查
- 新增的检测脚本仅需Computer Vision Toolbox，不需要深度学习工具箱
- YOLOv4/v5检测需要Deep Learning Toolbox