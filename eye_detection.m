%% 眼睛检测脚本
% 此脚本演示如何检测人脸中的眼睛
% 需要Computer Vision System Toolbox

% 清除工作区
clear all;
close all;
clc;

try
    % 创建面部检测器
    faceDetector = vision.CascadeObjectDetector();
    
    % 创建眼睛检测器
    eyeDetector = vision.CascadeObjectDetector('EyePairBig');
    
    % 设置是否使用摄像头
    useCamera = true;
    
    if useCamera
        try
            % 尝试打开摄像头
            cam = webcam();
            
            % 创建图像显示窗口
            figure('Name', '实时眼睛检测', 'NumberTitle', 'off');
            
            while true
                % 获取当前帧
                img = snapshot(cam);
                
                % 检测人脸
                faceBox = step(faceDetector, img);
                
                % 显示结果
                imshow(img);
                hold on;
                
                % 处理每个检测到的人脸
                for i = 1:size(faceBox, 1)
                    % 绘制人脸边界框
                    rectangle('Position', faceBox(i, :), 'LineWidth', 3, 'LineStyle', '-', 'EdgeColor', 'r');
                    text(faceBox(i, 1), faceBox(i, 2)-10, 'Person', 'FontSize', 12, 'Color', 'red');
                    
                    % 提取人脸区域
                    faceImage = imcrop(img, faceBox(i, :));
                    
                    % 在人脸区域内检测眼睛
                    eyeBox = step(eyeDetector, faceImage);
                    
                    % 如果检测到眼睛，在原图中显示
                    if ~isempty(eyeBox)
                        % 转换坐标到原始图像
                        eyeBox(:, 1) = eyeBox(:, 1) + faceBox(i, 1) - 1;
                        eyeBox(:, 2) = eyeBox(:, 2) + faceBox(i, 2) - 1;
                        
                        % 绘制眼睛边界框
                        for j = 1:size(eyeBox, 1)
                            rectangle('Position', eyeBox(j, :), 'LineWidth', 2, 'LineStyle', '--', 'EdgeColor', 'g');
                            text(eyeBox(j, 1), eyeBox(j, 2)-5, 'Eyes', 'FontSize', 10, 'Color', 'green');
                        end
                    end
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
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', '图像文件 (*.jpg, *.png, *.bmp)'}, '选择图像文件');
        
        if filename ~= 0
            img = imread(fullfile(pathname, filename));
            
            % 检测人脸
            faceBox = step(faceDetector, img);
            
            % 显示结果
            figure('Name', '眼睛检测结果', 'NumberTitle', 'off');
            imshow(img);
            hold on;
            
            % 处理每个检测到的人脸
            for i = 1:size(faceBox, 1)
                % 绘制人脸边界框
                rectangle('Position', faceBox(i, :), 'LineWidth', 3, 'LineStyle', '-', 'EdgeColor', 'r');
                text(faceBox(i, 1), faceBox(i, 2)-10, 'Person', 'FontSize', 12, 'Color', 'red');
                
                % 提取人脸区域
                faceImage = imcrop(img, faceBox(i, :));
                
                % 在人脸区域内检测眼睛
                eyeBox = step(eyeDetector, faceImage);
                
                % 如果检测到眼睛，在原图中显示
                if ~isempty(eyeBox)
                    % 转换坐标到原始图像
                    eyeBox(:, 1) = eyeBox(:, 1) + faceBox(i, 1) - 1;
                    eyeBox(:, 2) = eyeBox(:, 2) + faceBox(i, 2) - 1;
                    
                    % 绘制眼睛边界框
                    for j = 1:size(eyeBox, 1)
                        rectangle('Position', eyeBox(j, :), 'LineWidth', 2, 'LineStyle', '--', 'EdgeColor', 'g');
                        text(eyeBox(j, 1), eyeBox(j, 2)-5, 'Eyes', 'FontSize', 10, 'Color', 'green');
                    end
                end
            end
            
            hold off;
            
            % 保存结果
            saveas(gcf, 'eye_detection_result.jpg');
            disp('检测结果已保存为 eye_detection_result.jpg');
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
        '眼睛检测错误');
    
    % 在命令窗口显示详细错误信息
    fprintf(2, '错误详情:\n%s\n', getReport(e));
end