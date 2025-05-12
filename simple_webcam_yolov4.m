%% 摄像头YOLOv4实时目标检测
% 此脚本使用YOLOv4预训练模型进行实时摄像头目标检测
% 需要Deep Learning Toolbox和Computer Vision Toolbox
% 
% 基于MATLAB官方YOLOv4实现: https://github.com/matlab-deep-learning/pretrained-yolo-v4

clear all;
close all;
clc;

try
    % 检查所需工具箱
    hasDLT = license('test', 'Deep_Learning_Toolbox');
    hasCV = license('test', 'Video_and_Image_Blockset') || ...
            license('test', 'Computer_Vision_System_Toolbox');
    
    if ~hasDLT || ~hasCV
        error('缺少必要的工具箱: Deep Learning Toolbox 或 Computer Vision Toolbox');
    end
    
    % 下载并加载YOLOv4-tiny预训练模型
    modelName = 'tiny-yolov4-coco';
    disp('正在加载YOLOv4-tiny预训练模型...');
    
    if ~exist(modelName, 'file')
        % 如果模型不存在，下载预训练模型
        websave([modelName '.zip'], ['https://ssd.mathworks.com/supportfiles/vision/data/' modelName '.zip']);
        unzip([modelName '.zip']);
    end
    
    % 加载模型
    net = importONNXNetwork([modelName '.onnx'], 'OutputLayerType', 'classification');
    
    % 获取类别名称
    classNames = getCOCOClassNames();
    
    % 初始化摄像头
    try
        cam = webcam();
        hasCamera = true;
    catch
        hasCamera = false;
        warning('无法连接摄像头，将使用示例图像');
    end
    
    % 创建显示窗口
    f = figure('Name', 'YOLOv4实时目标检测', 'NumberTitle', 'off', ...
        'Position', [100 100 800 600], 'Resize', 'on');
    
    if hasCamera
        % 实时检测循环
        disp('正在运行实时检测... 按ESC键退出');
        
        while ishandle(f)
            % 获取当前帧
            img = snapshot(cam);
            
            % 预处理图像
            inputSize = [416 416];
            img_resized = imresize(img, inputSize);
            
            % 图像预处理
            img_normalized = im2single(img_resized);
            
            % 运行网络前向传播
            [boxes, scores, labels] = detectObjects(net, img_normalized, classNames, 0.5, 0.5);
            
            % 将检测结果映射回原始图像尺寸
            scale = [size(img, 2)/inputSize(2), size(img, 1)/inputSize(1), ...
                     size(img, 2)/inputSize(2), size(img, 1)/inputSize(1)];
            boxes = bboxresize(boxes, scale);
            
            % 显示结果
            img = insertObjectAnnotation(img, 'rectangle', boxes, labels, ...
                'FontSize', 18, 'LineWidth', 3, 'TextBoxOpacity', 0.6);
            
            imshow(img);
            title(sprintf('检测到 %d 个目标', numel(labels)), 'FontSize', 14);
            
            % 检查按键
            k = waitforbuttonpress;
            if k
                key = get(f, 'CurrentCharacter');
                if key == char(27) % ESC键
                    break;
                end
            end
            
            drawnow;
        end
        
        % 释放摄像头
        clear cam;
    else
        % 示例图像检测
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp', '图像文件 (*.jpg, *.png, *.bmp)'}, '选择图像文件');
        
        if file ~= 0
            img = imread(fullfile(path, file));
            
            % 预处理图像
            inputSize = [416 416];
            img_resized = imresize(img, inputSize);
            
            % 图像预处理
            img_normalized = im2single(img_resized);
            
            % 运行网络前向传播
            [boxes, scores, labels] = detectObjects(net, img_normalized, classNames, 0.5, 0.5);
            
            % 将检测结果映射回原始图像尺寸
            scale = [size(img, 2)/inputSize(2), size(img, 1)/inputSize(1), ...
                     size(img, 2)/inputSize(2), size(img, 1)/inputSize(1)];
            boxes = bboxresize(boxes, scale);
            
            % 显示结果
            img = insertObjectAnnotation(img, 'rectangle', boxes, labels, ...
                'FontSize', 18, 'LineWidth', 3, 'TextBoxOpacity', 0.6);
            
            imshow(img);
            title(sprintf('检测到 %d 个目标', numel(labels)), 'FontSize', 14);
            
            % 保存结果
            saveas(f, 'yolo_detection_result.jpg');
            disp('检测结果已保存为 yolo_detection_result.jpg');
        end
    end
    
catch e
    % 如果出现错误，显示友好的错误信息
    errordlg({['错误: ' e.message], '', ...
        '可能原因:', ...
        '1. 缺少Deep Learning Toolbox或Computer Vision Toolbox', ...
        '2. 无法下载或加载预训练模型', ...
        '3. 摄像头硬件问题'}, ...
        'YOLOv4检测错误');
    
    % 在命令窗口显示详细错误信息
    fprintf(2, '错误详情:\n%s\n', getReport(e));
end

%% 辅助函数

% 获取COCO数据集类别名称
function classNames = getCOCOClassNames()
    classNames = {'person', 'bicycle', 'car', 'motorcycle', 'airplane', 'bus', ...
                 'train', 'truck', 'boat', 'traffic light', 'fire hydrant', ...
                 'stop sign', 'parking meter', 'bench', 'bird', 'cat', 'dog', ...
                 'horse', 'sheep', 'cow', 'elephant', 'bear', 'zebra', ...
                 'giraffe', 'backpack', 'umbrella', 'handbag', 'tie', ...
                 'suitcase', 'frisbee', 'skis', 'snowboard', 'sports ball', ...
                 'kite', 'baseball bat', 'baseball glove', 'skateboard', ...
                 'surfboard', 'tennis racket', 'bottle', 'wine glass', 'cup', ...
                 'fork', 'knife', 'spoon', 'bowl', 'banana', 'apple', ...
                 'sandwich', 'orange', 'broccoli', 'carrot', 'hot dog', 'pizza', ...
                 'donut', 'cake', 'chair', 'couch', 'potted plant', 'bed', ...
                 'dining table', 'toilet', 'tv', 'laptop', 'mouse', 'remote', ...
                 'keyboard', 'cell phone', 'microwave', 'oven', 'toaster', ...
                 'sink', 'refrigerator', 'book', 'clock', 'vase', 'scissors', ...
                 'teddy bear', 'hair drier', 'toothbrush'};
end

% 目标检测函数
function [boxes, scores, labels] = detectObjects(net, img, classNames, scoreThreshold, overlapThreshold)
    % 前向传播
    prediction = predict(net, img);
    
    % 解析预测结果
    numClasses = numel(classNames);
    numBBoxes = size(prediction, 1);
    
    % 提取边界框、置信度和类别概率
    boxConfidence = prediction(:, 5);
    classProbabilities = prediction(:, 6:5+numClasses);
    
    % 计算每个类别的最终分数
    scores = boxConfidence .* classProbabilities;
    
    % 查找最高分及其对应的类别
    [maxScores, classIndices] = max(scores, [], 2);
    
    % 应用分数阈值
    validDetections = maxScores > scoreThreshold;
    
    % 提取有效检测
    boxes = prediction(validDetections, 1:4);
    scores = maxScores(validDetections);
    classIndices = classIndices(validDetections);
    
    % 中心点坐标转换为左上角坐标
    boxes(:, 1) = boxes(:, 1) - boxes(:, 3)/2;
    boxes(:, 2) = boxes(:, 2) - boxes(:, 4)/2;
    
    % 应用非最大抑制
    if ~isempty(boxes)
        [selectedBBoxes, selectedScores, selectedClasses] = selectStrongestBboxMulticlass(...
            boxes, scores, classIndices, ...
            'RatioType', 'Union', ...
            'OverlapThreshold', overlapThreshold);
        
        % 转换类别索引为类别名称
        labels = cell(size(selectedClasses));
        for i = 1:numel(labels)
            classProbability = selectedScores(i);
            labels{i} = sprintf('%s: %.2f', classNames{selectedClasses(i)}, classProbability);
        end
        
        boxes = selectedBBoxes;
        scores = selectedScores;
    else
        labels = {};
    end
    
    % 防止空结果
    if isempty(boxes)
        boxes = zeros(0, 4);
        scores = zeros(0, 1);
        labels = {};
    end
end