
clear all;
close all
clc;

videoReader = vision.VideoFileReader('car_video.avi');  


videoPlayer = vision.VideoPlayer;
fgPlayer = vision.VideoPlayer;


foregroundDetector = vision.ForegroundDetector('NumGaussians', 3,'NumTrainingFrames', 50);


for i = 1:75
    videoFrame = step(videoReader);
    foreground = step(foregroundDetector,videoFrame);
end

figure;
imshow(videoFrame);
title('Input Frame');
figure;
imshow(foreground);
title('Foreground');


cleanForeground = imopen(foreground, strel('Disk',1));
figure;

subplot(1,2,1);imshow(foreground);title('Original Foreground');

subplot(1,2,2);imshow(cleanForeground);title('Clean Foreground');


blobAnalysis = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
    'AreaOutputPort', false, 'CentroidOutputPort', false, ...
    'MinimumBlobArea', 150);


while  ~isDone(videoReader)
    
    videoFrame = step(videoReader);
    
   
    foreground = step(foregroundDetector,videoFrame);
   
    cleanForeground = imopen(foreground, strel('Disk',1));
            
    
    bbox = step(blobAnalysis, cleanForeground);

    
    result = insertShape(videoFrame, 'Rectangle', bbox, 'Color', 'yellow');

    
    numCars = size(bbox, 1);
    text = sprintf('Detected Vehicles = %d',numCars);
    result = insertText(result, [10 10], numCars, 'BoxOpacity', 1, ...
        'FontSize', 16);


  
    step(videoPlayer, result);
    step(fgPlayer,cleanForeground);

    
end


release(videoPlayer);
release(videoReader);
release(fgPlayer);
delete(videoPlayer); 
delete(fgPlayer);
