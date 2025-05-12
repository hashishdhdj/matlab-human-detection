% 检查是否安装了Computer Vision Toolbox
clear all;
close all;

% 获取已安装的工具箱信息
v = ver;
hasComputerVision = false;

% 遍历所有工具箱，查找Computer Vision Toolbox
fprintf('已安装的工具箱:\n');
fprintf('---------------------------\n');
for i = 1:length(v)
    fprintf('%s 版本 %s\n', v(i).Name, v(i).Version);
    
    % 检查是否有Computer Vision Toolbox
    if strcmp(v(i).Name, 'Computer Vision Toolbox')
        hasComputerVision = true;
    end
end
fprintf('---------------------------\n');

% 通过尝试创建对象来验证
try
    detector = vision.CascadeObjectDetector();
    fprintf('成功: 可以创建 vision.CascadeObjectDetector 对象\n');
    hasComputerVision = true;
catch ME
    fprintf('错误: 无法创建 vision.CascadeObjectDetector 对象\n');
    fprintf('错误信息: %s\n', ME.message);
    hasComputerVision = false;
end

% 显示结果
if hasComputerVision
    fprintf('\n结论: Computer Vision Toolbox 已安装并可用\n');
else
    fprintf('\n结论: Computer Vision Toolbox 未安装或不可用\n');
    fprintf('请在MATLAB中点击"主页" -> "附加功能" -> "获取附加功能" 来安装此工具箱\n');
end

% 提供备选检查方法
fprintf('\n要进一步检查，您也可以在MATLAB命令窗口中输入以下命令:\n');
fprintf('  - 检查是否存在: which vision.CascadeObjectDetector\n');
fprintf('  - 查看工具箱版本: ver(''Computer Vision Toolbox'')\n');
fprintf('  - 检查帮助文档: doc vision.CascadeObjectDetector\n');