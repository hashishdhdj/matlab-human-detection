% MultiObjectTrackerKLT实现使用Kanade-Lucas-Tomasi (KLT)算法跟踪多个对象。
% tracker = MultiObjectTrackerKLT()创建多对象跟踪器。
%
% MultiObjectTrackerKLT属性:
%   PointTracker - vision.PointTracker对象
%   Bboxes       - 对象边界框
%   BoxIds       - 与每个边界框关联的ID
%   Points       - 所有对象的跟踪点
%   PointIds     - 与每个点关联的ID
%   NextId       - 下一个对象将使用这个ID
%   BoxScores    - 表示对象是否丢失的指标
%
% MultiObjectTrackerKLT方法:
%   addDetections - 添加检测到的边界框
%   track         - 跟踪对象
%
% 原始代码来源: https://github.com/abhishekdutta/multiple_face_detection

classdef MultiObjectTrackerKLT < handle
    properties
        % PointTracker: vision.PointTracker对象
        PointTracker; 
        
        % Bboxes: M×4矩阵，格式为[x y w h]的对象边界框
        Bboxes = [];
        
        % BoxIds: M×1数组，包含与每个边界框关联的ID
        BoxIds = [];
        
        % Points: M×2矩阵，包含所有对象的跟踪点
        Points = [];
        
        % PointIds: M×1数组，包含与每个点关联的对象ID
        % 该数组跟踪哪个点属于哪个对象。
        PointIds = [];
        
        % NextId: 下一个新对象将使用这个ID
        NextId = 1;
        
        % BoxScores: M×1数组。低分表示我们可能已经丢失该对象。
        BoxScores = [];
    end
    
    methods
        %------------------------------------------------------------------
        function this = MultiObjectTrackerKLT()
        % 构造函数
            this.PointTracker = ...
                vision.PointTracker('MaxBidirectionalError', 2);
        end
        
        %------------------------------------------------------------------
        function addDetections(this, I, bboxes)
        % addDetections 添加检测到的边界框
        % addDetections(tracker, I, bboxes)添加检测到的边界框。
        % tracker是MultiObjectTrackerKLT对象，I是当前帧，
        % bboxes是一个M×4的数组，格式为[x y w h]的边界框。
        % 该方法确定检测是属于现有对象，还是一个全新的对象。
            for i = 1:size(bboxes, 1)
                % 确定检测是否属于现有对象之一
                boxIdx = this.findMatchingBox(bboxes(i, :));
                
                if isempty(boxIdx)
                    % 这是一个全新的对象
                    this.Bboxes = [this.Bboxes; bboxes(i, :)];
                    points = detectMinEigenFeatures(I, 'ROI', bboxes(i, :));
                    points = points.Location;
                    this.BoxIds(end+1) = this.NextId;
                    idx = ones(size(points, 1), 1) * this.NextId;
                    this.PointIds = [this.PointIds; idx];
                    this.NextId = this.NextId + 1;
                    this.Points = [this.Points; points];
                    this.BoxScores(end+1) = 1;
                    
                else % 该对象已存在
                    
                    % 删除匹配的框
                    currentBoxScore = this.deleteBox(boxIdx);
                    
                    % 替换为新框
                    this.Bboxes = [this.Bboxes; bboxes(i, :)];
                    
                    % 重新检测点。这是我们替换点的方式，
                    % 因为在跟踪过程中点不可避免地会丢失。
                    points = detectMinEigenFeatures(I, 'ROI', bboxes(i, :));
                    points = points.Location;
                    this.BoxIds(end+1) = boxIdx;
                    idx = ones(size(points, 1), 1) * boxIdx;
                    this.PointIds = [this.PointIds; idx];
                    this.Points = [this.Points; points];                    
                    this.BoxScores(end+1) = currentBoxScore + 1;
                end
            end
            
            % 确定哪些对象不再被跟踪
            minBoxScore = -2;
            this.BoxScores(this.BoxScores < 3) = ...
                this.BoxScores(this.BoxScores < 3) - 0.5;
            boxesToRemoveIds = this.BoxIds(this.BoxScores < minBoxScore);
            while ~isempty(boxesToRemoveIds)
                this.deleteBox(boxesToRemoveIds(1));
                boxesToRemoveIds = this.BoxIds(this.BoxScores < minBoxScore);
            end
            
            % 更新点跟踪器
            if this.PointTracker.isLocked()
                this.PointTracker.setPoints(this.Points);
            else
                this.PointTracker.initialize(this.Points, I);
            end
        end
                
        %------------------------------------------------------------------
        function track(this, I)
        % TRACK 跟踪对象
        % TRACK(tracker, I)在帧I中跟踪对象。tracker是
        % MultiObjectTrackerKLT对象，I是当前视频帧。
        % 该方法更新点和对象边界框。
            [newPoints, isFound] = this.PointTracker.step(I);
            this.Points = newPoints(isFound, :);
            this.PointIds = this.PointIds(isFound);
            generateNewBoxes(this);
            if ~isempty(this.Points)
                this.PointTracker.setPoints(this.Points);
            end
        end
    end
    
    methods(Access=private)        
        %------------------------------------------------------------------
        function boxIdx = findMatchingBox(this, box)
        % 确定新检测属于哪个跟踪对象（如果有）
            boxIdx = [];
            for i = 1:size(this.Bboxes, 1)
                area = rectint(this.Bboxes(i,:), box);                
                if area > 0.2 * this.Bboxes(i, 3) * this.Bboxes(i, 4) 
                    boxIdx = this.BoxIds(i);
                    return;
                end
            end           
        end
        
        %------------------------------------------------------------------
        function currentScore = deleteBox(this, boxIdx)            
        % 删除对象
            this.Bboxes(this.BoxIds == boxIdx, :) = [];
            this.Points(this.PointIds == boxIdx, :) = [];
            this.PointIds(this.PointIds == boxIdx) = [];
            currentScore = this.BoxScores(this.BoxIds == boxIdx);
            this.BoxScores(this.BoxIds == boxIdx) = [];
            this.BoxIds(this.BoxIds == boxIdx) = [];
            
        end
        
        %------------------------------------------------------------------
        function generateNewBoxes(this)  
        % 从跟踪点获取每个对象的边界框
            oldBoxIds = this.BoxIds;
            oldScores = this.BoxScores;
            this.BoxIds = unique(this.PointIds);
            numBoxes = numel(this.BoxIds);
            this.Bboxes = zeros(numBoxes, 4);
            this.BoxScores = zeros(numBoxes, 1);
            for i = 1:numBoxes
                points = this.Points(this.PointIds == this.BoxIds(i), :);
                newBox = getBoundingBox(points);
                this.Bboxes(i, :) = newBox;
                this.BoxScores(i) = oldScores(oldBoxIds == this.BoxIds(i));
            end
        end 
    end
end

%--------------------------------------------------------------------------
function bbox = getBoundingBox(points)
x1 = min(points(:, 1));
y1 = min(points(:, 2));
x2 = max(points(:, 1));
y2 = max(points(:, 2));
bbox = [x1 y1 x2 - x1 y2 - y1];
end