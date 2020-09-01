function [outfilename,fr] = FirstFrameFaceDet(infilename,handles)
%��һ�������ο�֡
% Create a cascade detector object.
addpath(genpath('.'));
global infilename;
 
 
infilename='output2.avi';
% Read a video frame and run the detector. data\cdd.mp4
vidFile =  fullfile('data', infilename);
outfilename = [infilename(1:end-4),'_1st.avi'];
outName =  fullfile('result',outfilename);
 
 
vid = VideoReader(vidFile);
fr = round(vid.FrameRate);
len = vid.NumFrames;
 
 
%%����ļ�����
vidOut = VideoWriter(outName);
vidOut.FrameRate = 20;
open(vidOut)
 
 
videoFileReader = vision.VideoFileReader(vidFile);
videoFrame      = step(videoFileReader);
imshow(videoFrame);
%drawnow
 
 
%�ֶ����ѡ������bbox�ĸ������ֱ��Ӧ���ú����Ͻ�������ԭͼ��λ�ã����ú�ͼ���͸�
bbox=[300 300 250 180];
 
 
boxInserter  = vision.ShapeInserter('BorderColor','Custom',...
    'CustomBorderColor',[255 0 0],'LineWidth',3);
videoOut_chest = step(boxInserter, videoFrame,bbox);
%videoOut_chest = step(boxInserter, videoOut_chest,bbox_right);
figure(1),imshow(videoOut_chest,'border','tight');title('Detected image');
 
 
%%��һ֡ͼ��ü�
faceImage    = imcrop(videoFrame,bbox);
%    axes(handles.axes4);
    imshow(faceImage);
    drawnow
writeVideo(vidOut,im2uint8(faceImage));
h=waitbar(0,'��ʼ���...','Name','���ڸ���...');
%�ڶ������ü�����֡
n=1;
% Track the bbox over successive video frames until the video is finished.
while ~isDone(videoFileReader)
    n=n+1;
    % Extract the next video frame
    videoFrame = step(videoFileReader);
    % Insert a bounding box around the object being tracked
    % videoOut = step(boxInserter, videoFrame, bbox);
    faceImage    = imcrop(videoFrame,bbox);
    % Display the annotated video frame using the video player object
    % step(videoPlayer, faceImage);
    writeVideo(vidOut,im2uint8(faceImage));
    h=waitbar(0.05+n*(0.85/len),h,[num2str(floor(100*(0.05+n*(0.85/len)))),'%']);
end
 
 
% Release resources
close(vidOut);
h=waitbar(0.9,h,[num2str(90),'%']);
release(videoFileReader);
h=waitbar(1,h,[num2str(1),'%']);
clear vid;
close(h)
 %axes(handles.axes3);
    cla
 %axes(handles.axes4);
    cla
drawnow


