%% 多人脸检测与跟踪
% 自动检测并跟踪摄像头视频流中的多个人脸
% 基于Kanade-Lucas-Tomasi (KLT)算法
%
% 原始代码来源: https://github.com/abhishekdutta/multiple_face_detection
% 经过修改和中文注释

clear classes;

%% 初始化摄像头、人脸检测器和KLT对象跟踪器
try
    vidObj = webcam;
    
    % 创建级联对象检测器（默认检测人脸）
    faceDetector = vision.CascadeObjectDetector(); 
    tracker = MultiObjectTrackerKLT;
    
    %% 获取一帧用于获取帧大小信息
    frame = snapshot(vidObj);
    frameSize = size(frame);
    
    %% 创建视频播放器实例
    vidPlayer = figure('Name', '多人脸检测与跟踪', 'NumberTitle', 'off', 'Position', [200 100 frameSize(2)+30 frameSize(1)+30]);
    
    %% 迭代直到成功检测到人脸
    bboxes = [];
    while isempty(bboxes)
        framergb = snapshot(vidObj);
        frame = rgb2gray(framergb);
        bboxes = faceDetector.step(frame);
    end
    tracker.addDetections(frame, bboxes);
    
    %% 循环运行直到窗口关闭
    frameNumber = 0;
    keepRunning = true;
    disp('按Ctrl-C退出...');
    
    % 创建显示面板
    imh = subplot(1,1,1);
    
    while keepRunning && ishandle(vidPlayer)
        % 获取当前帧
        framergb = snapshot(vidObj);
        frame = rgb2gray(framergb);
        
        if mod(frameNumber, 10) == 0
            % 每10帧重新检测人脸
            %
            % 注意：人脸检测比调整图像大小更消耗资源，
            % 我们可以通过在降采样帧上重新获取人脸来加速实现：
            bboxes = 2 * faceDetector.step(imresize(frame, 0.5));
            if ~isempty(bboxes)
                tracker.addDetections(frame, bboxes);
            end
        else
            % 跟踪人脸
            tracker.track(frame);
        end
        
        % 显示边界框和跟踪点
        displayFrame = insertObjectAnnotation(framergb, 'rectangle', ...
            tracker.Bboxes, tracker.BoxIds, 'Color', 'red', 'LineWidth', 2);
        displayFrame = insertMarker(displayFrame, tracker.Points, '+', 'Color', 'green', 'Size', 5);
        
        % 在窗口中显示
        imshow(displayFrame, 'Parent', imh);
        title(imh, sprintf('检测到 %d 个人脸', numel(tracker.BoxIds)), 'FontSize', 12);
        drawnow;
        
        frameNumber = frameNumber + 1;
        
        % 检查按键，如果按下ESC则退出
        k = waitforbuttonpress;
        if k
            key = get(vidPlayer, 'CurrentCharacter');
            if key == char(27) % ESC键
                keepRunning = false;
            end
        end
    end
    
    %% 清理资源
    clear vidObj;
    close(vidPlayer);
    disp('程序已退出');
    
catch e
    % 显示友好的错误信息
    errordlg({sprintf('错误: %s', e.message), '', ...
        '可能的原因:', ...
        '1. 未安装Computer Vision System Toolbox', ...
        '2. 摄像头无法访问', ...
        '3. 内存不足'}, ...
        '多人脸检测与跟踪错误');
    
    fprintf(2, '错误详情:\n%s\n', getReport(e));
end