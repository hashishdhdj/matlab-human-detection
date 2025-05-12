%% YOLOv5函数封装信息
% 本文件解释了yolov5fcn.m文件的用途和使用方法
%
% yolov5fcn.m是由YOLOv5 ONNX模型转换生成的MATLAB函数文件
% 由于原始文件较大（约68KB），因此在GitHub仓库中不提供完整的代码
% 用户需要自行通过importONNXFunction函数生成此文件
%
% 生成方法:
% params = importONNXFunction('./yolov5s.onnx', 'yolov5fcn');
% 
% 此函数接受一个输入图像，并返回三个特征图，这三个特征图
% 需要通过后处理（在detect.m和main.m中实现）转换为检测结果
%
% 输入参数:
% - img: dlarray类型的输入图像，大小为1*3*H*W，取值范围[0,1]
% - params: 通过importONNXFunction生成的模型参数
%
% 输出参数:
% - 三个特征图，分别对应YOLOv5的三个检测头输出
%
% 使用示例:
% >> params = importONNXFunction('./yolov5s.onnx', 'yolov5fcn');
% >> img = imread('test.jpg');
% >> img = imresize(img, [640, 640]);
% >> img = rescale(img, 0, 1);
% >> img = permute(img, [3,1,2]);
% >> img = dlarray(reshape(img, [1, size(img)]));
% >> [out1, out2, out3] = yolov5fcn(img, params);
%
% 详细的使用方法请参考detect.m和main.m文件