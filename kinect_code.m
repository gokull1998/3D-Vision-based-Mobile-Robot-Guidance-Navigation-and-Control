%%
clc;
clear all;
close all;
info=imaqhwinfo('kinect')
info.DeviceInfo(1)
vid=videoinput('kinect','1','RGB_640x480');
%%
vid.ReturnedColorspace = 'grayscale';
%preview(vid);
image=getsnapshot(vid);
imtool(image)
%%
clc;
close all;
info=imaqhwinfo('kinect')
info.DeviceInfo(2)
depthVid=videoinput('kinect','2','Depth_640x480');
depthImage=getsnapshot(depthVid);
imtool(depthImage);
