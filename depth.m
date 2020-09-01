close all;  
% Read and Rectify Images
[A,map] = imread('corridor.png');  %read image
Xleft = imcrop(A,[0 0 672 376]);              
Xright = imcrop(A,[672 0 1344 376]); 
Xright = imresize(Xright,[376 672]);
set(0,'defaultFigurePosition',[100,100,1000,500]);    %修改图形图像位置的默认设置
set(0,'defaultFigureColor',[1 1 1])    %修改图形背景颜色的设置 
rectangle('Position',[0 0 672 376])    %显示图像剪切区域
subplot(121),imshow(Xleft);    
rectangle('Position',[673 0 1344 376]) 
subplot(122),imshow(Xright);   
% imwrite(Xleft,'left8.png');
% imwrite(Xright,'right8.png');
[imageLeftRect, imageRightRect] = ...
    rectifyStereoImages(Xleft, Xright, stereoParams);
figure;
imshow(stereoAnaglyph(imageLeftRect, imageRightRect));
title('Rectified Image');
%% Compute Disparity
imageLeftGray  = rgb2gray(imageLeftRect);
imageRightGray = rgb2gray(imageRightRect);
    
disparityMap = disparitySGM(imageLeftGray, imageRightGray);
figure;
imshow(disparityMap, [0, 64]);
title('Disparity Map');
colormap jet
colorbar
%% Reconstruct the 3-D Scene
points3D = reconstructScene(disparityMap, stereoParams);

% Convert to meters and create a pointCloud object
points3D = points3D ./ 1000;
ptCloud = pointCloud(points3D, 'Color', imageLeftRect);

% Create a streaming point cloud viewer
player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
    'VerticalAxisDir', 'down');

% Visualize the point cloud
view(player3D, ptCloud);

%% Detect People in the Left Image
% Create the people detector object. Limit the minimum object size for speed.
peopleDetector = vision.PeopleDetector('MinSize', [166 83]);

% Detect people.
bboxes = peopleDetector.step(imageRightGray);

%% Determine The Distance of Each Person to the Camera
% Find the centroids of detected people.
centroids = [round(bboxes(:, 1) + bboxes(:, 3) / 2), ...
    round(bboxes(:, 2) + bboxes(:, 4) / 2)];

% Find the 3-D world coordinates of the centroids.
centroidsIdx = sub2ind(size(disparityMap), centroids(:, 2), centroids(:, 1));
X = points3D(:, :, 1);
Y = points3D(:, :, 2);
Z = points3D(:, :, 3);
centroids3D = [X(centroidsIdx)'; Y(centroidsIdx)'; Z(centroidsIdx)'];

% Find the distances from the camera in meters.
dists = sqrt(sum(centroids3D .^ 2));
    
% Display the detected people and their distances.
labels = cell(1, numel(dists));
for i = 1:numel(dists)
    labels{i} = sprintf('%0.2f meters', dists(i));
end
figure;
imshow(insertObjectAnnotation(imageRightRect, 'rectangle', bboxes, labels));
title('Detected People');