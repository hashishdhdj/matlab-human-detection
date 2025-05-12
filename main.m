%% 基于YOLOv5的人类检测程序
% 这个程序实现了以下功能：
% 1. 从摄像头或图片文件中检测人类
% 2. 基于YOLOv5模型进行目标检测
% 3. 提供图像浏览和保存结果功能
%
% 改进历史：
% - 修复了DeviceFormats字段不存在的错误，添加了多种备选字段处理
% - 添加了自动切换到静态图片模式的功能，解决内存不足和超时问题
% - 添加了图像浏览和结果保存功能
% - 添加了对ONNX支持包的检查

% 基于YOLOv5的摄像头人类检测程序
clear all;
close all;

% 检查是否安装了ONNX Converter支持包
try
    % 尝试使用一个ONNX相关的函数
    if ~exist('importONNXFunction', 'file')
        error('未安装ONNX支持包');
    end
catch
    % 显示安装提示对话框
    errordlg({'检测到缺少Deep Learning Toolbox Converter for ONNX Model Format支持包。', ...
        '', ...
        '请按照以下步骤安装：', ...
        '1. 在MATLAB命令窗口输入:', ...
        '   matlab.addons.supportpackage.internal.explorer.showSupportPackages(''ONNXCONVERTER'', ''tripwire'')', ...
        '', ...
        '2. 或者点击MATLAB主页 -> 附加功能 -> 获取附加功能，搜索"ONNX"并安装', ...
        '', ...
        '安装完成后请重新运行此程序。'}, ...
        '缺少必要支持包');
    
    % 创建一个简单窗口显示错误信息
    figure('Name', '缺少ONNX支持包', 'NumberTitle', 'off', 'Position', [100, 100, 500, 300]);
    uicontrol('Style', 'text', 'String', '缺少Deep Learning Toolbox Converter for ONNX Model Format支持包', ...
        'Position', [20, 200, 460, 50], 'FontSize', 12);
    uicontrol('Style', 'text', 'String', '请在MATLAB中执行以下命令安装：', ...
        'Position', [20, 170, 460, 30], 'FontSize', 10);
    uicontrol('Style', 'text', 'String', 'matlab.addons.supportpackage.internal.explorer.showSupportPackages(''ONNXCONVERTER'', ''tripwire'')', ...
        'Position', [20, 140, 460, 30], 'FontSize', 9);
    uicontrol('Style', 'text', 'String', '或者点击MATLAB主页 -> 附加功能 -> 获取附加功能，搜索"ONNX"并安装', ...
        'Position', [20, 100, 460, 30], 'FontSize', 10);
    uicontrol('Style', 'pushbutton', 'String', '退出', ...
        'Position', [200, 30, 100, 40], 'FontSize', 12, 'Callback', 'close(gcf)');
    
    % 不继续执行程序
    return;
end

% 声明全局变量，使回调函数可以访问
global useCustomImage customImagePath mainFig hAxes statusText lastDetectedImage

% 添加图片浏览功能
useCustomImage = false;
customImagePath = '';

% 创建主窗口
mainFig = figure('Name', '人类检测程序', 'NumberTitle', 'off', 'Position', [100, 100, 800, 600]);

% 创建图像浏览按钮
uicontrol('Parent', mainFig, 'Style', 'pushbutton', 'String', '浏览图片', ...
    'Position', [10, 560, 100, 30], 'Callback', @browseImage);

% 创建开始检测按钮
uicontrol('Parent', mainFig, 'Style', 'pushbutton', 'String', '开始检测', ...
    'Position', [120, 560, 100, 30], 'Callback', @startDetection);

% 创建保存结果按钮
uicontrol('Parent', mainFig, 'Style', 'pushbutton', 'String', '保存结果', ...
    'Position', [230, 560, 100, 30], 'Callback', @saveResults);

% 创建帮助按钮
uicontrol('Parent', mainFig, 'Style', 'pushbutton', 'String', '帮助', ...
    'Position', [10, 10, 50, 30], 'Callback', @showHelp);

% 创建状态栏
statusText = uicontrol('Parent', mainFig, 'Style', 'text', 'String', '就绪', ...
    'Position', [340, 560, 450, 30], 'HorizontalAlignment', 'left');

% 创建显示区域
hAxes = axes('Parent', mainFig, 'Position', [0.1, 0.1, 0.8, 0.7]);

% 创建全局变量来存储检测结果
global lastDetectedImage;
lastDetectedImage = [];

% 初始化一个空图像
emptyImg = zeros(480, 640, 3, 'uint8');
imshow(emptyImg, 'Parent', hAxes);
title('请选择图片或使用摄像头进行检测', 'FontSize', 12);
drawnow;

% 等待用户交互
uiwait(mainFig);

% 回调函数和辅助函数请参见完整代码
% 由于GitHub上传限制，代码已简化
% 完整代码请参考本地文件