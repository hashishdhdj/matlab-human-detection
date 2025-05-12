%% 简单人脸检测 - 基于Viola-Jones算法
% 此脚本使用MATLAB内置的vision.CascadeObjectDetector类实现人脸检测
% 需要Computer Vision System Toolbox

% 清除工作区
clear all;
close all;
clc;

try
    % 创建面部检测器对象
    faceDetector = vision.CascadeObjectDetector();
    
    % 设置是否使用摄像头
    useCamera = true;
    
    if useCamera
        try
            % 尝试打开摄像头
            cam = webcam();
            
            % 创建图像显示窗口
            figure('Name', '实时人脸检测', 'NumberTitle', 'off');
            
            while true
                % 获取当前帧
                img = snapshot(cam);
                
                % 检测人脸
                bbox = step(faceDetector, img);
                
                % 显示结果
                imshow(img);
                hold on;
                
                % 绘制检测到的人脸边界框
                for i = 1:size(bbox, 1)
                    rectangle('Position', bbox(i, :), 'LineWidth', 3, 'LineStyle', '-', 'EdgeColor', 'r');
                    text(bbox(i, 1), bbox(i, 2)-10, 'Person', 'FontSize', 12, 'Color', 'red');
                end
                
                hold off;
                drawnow;
                
                % 按ESC键退出
                k = waitforbuttonpress;
                if k
                    key = get(gcf, 'CurrentCharacter');
                    if key == char(27) % ESC键
                        break;
                    end
                end
            end
            
            % 释放摄像头
            clear cam;
            
        catch cameraError
            % 摄像头出错时使用静态图像
            warning('摄像头无法使用: %s\n使用静态图像代替', cameraError.message);
            useCamera = false;
        end
    end
    
    % 如果不使用摄像头或摄像头出错，则使用静态图像
    if ~useCamera
        % 读取示例图片
        % 用户可以修改为自己的图片路径
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', '图像文件 (*.jpg, *.png, *.bmp)'}, '选择图像文件');
        
        if filename ~= 0
            img = imread(fullfile(pathname, filename));
            
            % 检测人脸
            bbox = step(faceDetector, img);
            
            % 显示结果
            figure('Name', '人脸检测结果', 'NumberTitle', 'off');
            imshow(img);
            hold on;
            
            % 绘制检测到的人脸边界框
            for i = 1:size(bbox, 1)
                rectangle('Position', bbox(i, :), 'LineWidth', 3, 'LineStyle', '-', 'EdgeColor', 'r');
                text(bbox(i, 1), bbox(i, 2)-10, 'Person', 'FontSize', 12, 'Color', 'red');
            end
            
            hold off;
            
            % 保存结果
            saveas(gcf, 'face_detection_result.jpg');
            disp('检测结果已保存为 face_detection_result.jpg');
        else
            disp('未选择任何图像文件');
        end
    end
    
catch e
    % 如果出现错误，显示友好的错误信息
    errordlg({['错误: ' e.message], '', ...
        '可能原因:', ...
        '1. 缺少Computer Vision System Toolbox', ...
        '2. 摄像头硬件问题', ...
        '3. 静态图像格式不支持'}, ...
        '人脸检测错误');
    
    % 在命令窗口显示详细错误信息
    fprintf(2, '错误详情:\n%s\n', getReport(e));
end