model = "./yolov5s.onnx";
customYoloV5FcnName = 'yolov5fcn';
inputSize = [640,640];
throushHold = 0.3;
nmsThroushHold = 0.5;
outs = cell(3,1); % 3个检测head输出
classesNames = categorical(readlines("coco.names"));
colors = randi(255,length(classesNames),3);
params = importONNXFunction(model,customYoloV5FcnName);


image = imread('images/2.jpg');  % 修改为你需要识别的图片路径
imshow(image);
title('原始图像');

[H,W,~] = size(image);

% 图像预处理
img = imresize(image, inputSize);
img = rescale(img, 0, 1);  % 转换到[0,1]
img = permute(img, [3,1,2]);  % 改变维度顺序为 [C,H,W]
img = dlarray(reshape(img, [1, size(img)])); % n*c*h*w，[0,1],RGB顺序
if canUseGPU()
    img = gpuArray(img);
end

t1 = tic;
[outs{:}] = feval(customYoloV5FcnName, img, params, ...
    'Training', false, ...
    'InputDataPermutation', 'none', ...
    'OutputDataPermutation', 'none');  % 预测图像
fprintf('yolov5预测耗时：%.2f 秒\n', toc(t1));

outFeatures = yolov5Decode(outs, H, W);

%% 阈值过滤+NMS处理


scores = outFeatures(:, 5);
% 阈值过滤：只保留大于阈值的框
validIdxs = scores > throushHold;
outFeatures = outFeatures(validIdxs, :); 

% 提取边界框和对应的类别信息
allBBoxes = outFeatures(:, 1:4);
[maxScores, indxs] = max(outFeatures(:, 6:end), [], 2);
allScores = maxScores;
allLabels = classesNames(indxs);

% 如果存在有效边界框，则进行NMS非极大值抑制
if ~isempty(allBBoxes)
    [bboxes, nmsScores, labels] = selectStrongestBboxMulticlass(allBBoxes, allScores, allLabels, ...
        'RatioType', 'Min', 'OverlapThreshold', nmsThroushHold);
    annotations = string(labels) + ": " + string(nmsScores);
    % 获取类别ID并为每个类别分配颜色
    [~, ids] = ismember(labels, classesNames);
    color = colors(ids, :);
    image = insertObjectAnnotation(image, 'rectangle', bboxes, cellstr(annotations), ...
        'Color', color, 'LineWidth', 3);
end

% 显示结果图像
imshow(image);
title('检测结果图像');


function outPutFeatures = yolov5Decode(featuremaps, oriHight, oriWidth, anchors)
    arguments
        featuremaps (:,1) cell
        oriHight (1,1) double
        oriWidth (1,1) double
        anchors (:,2) double = [10,13; 16,30; 33,23;...
            30,61; 62,46; 59,119;...
            116,90; 156,198; 373,326]
    end
    %% yolov5*.onnx known params
    inputSize = 640;  % 输入网络图像大小，正方形图像输入
    na = 3;           % 每个检测head对应anchor的数量
    nc = 80;          % coco类别数量

    %% decode
    scaledX = inputSize./oriWidth;
    scaledY = inputSize./oriHight;
    outPutFeatures = [];
    numberFeaturemaps = length(featuremaps);

    for i = 1:numberFeaturemaps
        currentFeatureMap = featuremaps{i};  % bs*[(4+1+nc)*na]*h*w大小
        currentAnchors = anchors(na*(i-1)+1:na*i, :);  % na*2
        numY = size(currentFeatureMap, 3);
        numX = size(currentFeatureMap, 4);
        stride = inputSize ./ numX;

        % reshape currentFeatureMap到有意义的维度，bs*[(4+1+nc)*na]*h*w --> h*w*(5+nc)*na*bs
        % --> bs*na*h*w*(5+nc),最终的维度方式与yolov5官网兼容
        bs = size(currentFeatureMap, 1);
        h = numY;
        w = numX;
        disp(size(currentFeatureMap));
        currentFeatureMap = reshape(currentFeatureMap, bs, 5 + nc, na, h, w);  % bs*(5+nc)*na*h*w
        currentFeatureMap = permute(currentFeatureMap, [1, 3, 4, 5, 2]);  % bs*na*h*w*(5+nc)

        [~,~,yv,xv] = ndgrid(1:bs, 1:na, 0:h-1, 0:w-1);  % yv, xv大小都为bs*na*h*w，注意顺序，后面做加法维度标签要对应
        gridXY = cat(5, xv, yv);  % 第5维上扩展，大小为bs*na*h*w*2, x,y从1开始的索引
        currentFeatureMap = sigmoid(currentFeatureMap);  % yolov5是对所有值进行归一化，与yolov3/v4不同
        currentFeatureMap(:,:,:,:,1:2) = (2 * currentFeatureMap(:,:,:,:,1:2) - 0.5 + gridXY) .* stride;  % 大小为bs*na*h*w*2,预测对应xy
        anchor_grid = reshape(currentAnchors, 1, na, 1, 1, 2);  % 此处anchor_grid大小为1*na*1*1*2，方便下面相乘
        currentFeatureMap(:,:,:,:,3:4) = (currentFeatureMap(:,:,:,:,3:4) * 2).^2 .* anchor_grid;  % 大小为bs*na*h*w*2

        if nc == 1
            currentFeatureMap(:,:,:,:,6) = 1;
        end
        currentFeatureMap = reshape(currentFeatureMap, bs, [], 5 + nc);  % bs*N*(5+nc)

        if isempty(outPutFeatures)
            outPutFeatures = currentFeatureMap;
        else
            outPutFeatures = cat(2, outPutFeatures, currentFeatureMap);  % bs*M*(5+nc)
        end
    end

    %% 坐标转换到原始图像上
    % [cx, cy, w, h]，yolov5.onnx基准图像大小（1*3*640*640）----> [x, y, w, h], 坐标基于原始图像大小（1*3*oriHight*oriWidth）

    outPutFeatures = extractdata(outPutFeatures);  % bs*M*(5+nc), 为[x_center, y_center, w, h, Pobj, p1, p2,..., pn]
    outPutFeatures(:,:,[1,3]) = outPutFeatures(:,:,[1,3]) ./ scaledX;  % x_center, width
    outPutFeatures(:,:,[2,4]) = outPutFeatures(:,:,[2,4]) ./ scaledY;  % y_center, height
    outPutFeatures(:,:,1) = outPutFeatures(:,:,1) - outPutFeatures(:,:,3) / 2;  % x
    outPutFeatures(:,:,2) = outPutFeatures(:,:,2) - outPutFeatures(:,:,4) / 2;  % y

    outPutFeatures = squeeze(outPutFeatures);  % 如果是单张图像检测，则输出大小为M*(5+nc)，否则是bs*M*(5+nc)
    if (canUseGPU())
        outPutFeatures = gather(outPutFeatures);  % 推送到CPU上
    end
end