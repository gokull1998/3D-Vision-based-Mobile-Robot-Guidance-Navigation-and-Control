clc;
close all;
clear all;
obj = videoinput('winvideo', 2, 'YUY2_640x480');
obj.FramesPerTrigger = Inf;
obj.ReturnedColorspace = 'rgb';
start(obj)
for r=1:1:500
data=getdata(obj,1);
%%Reading and Converting Image
%read=imread('ul1.bmp');
%h=rgb2gray(read);
bw=im2bw(data,(145/256));
bwc=imcomplement(bw);
[maxRow,maxCol]=size(bwc);
%%Finding White Pixels ( Finger )
[j,k]=find(bwc);            % j=ROW vector; k=COLUMN vector of all white pixels 
%%Finding Extreme Vectors
bottom_frowindex=find(j==maxRow);
top_frowindex=find(j==min(j));
left_fcolindex=find(k==min(k));
right_fcolindex=find(k==max(k));
bottom_frow=k(bottom_frowindex);
top_frow=k(top_frowindex);
left_fcol=j(left_fcolindex);
right_fcol=j(right_fcolindex);
%%Finding starting point of finger from left (need not be fingertip)(x1,y1)
x1=min(k);                  % least value of column index gives us the starting point of the finger
y1=median(left_fcol);       % row value of the correspoinding x1
%%FInding (x4,y4)
x4=max(k);                  % highest column index
y4=median(right_fcol);      % row value of corresponding x4
%%Orientation and Calculation 
if (~isempty(intersect(bottom_frow,top_frow)))
    x3=(min(top_frow)+max(top_frow))/2;
    x=floor(x3);
    y3=min(j)+(0.5*(max(top_frow)-min(top_frow)));
    y=floor(y3);
    imshow(data);
    hold on;
    plot(x,y,'r*');
    hold on;
elseif ((min(bottom_frow)-x1)>0)
   x3=(x1+min(top_frow))/2;
   y3=(y1+min(j))/2;
   x=floor(x3);
   y=floor(y3);
   imshow(data);
   hold on;
   plot(x,y,'r*');
   hold on;
elseif (min(bottom_frow)==x1)
   x3=(x4+min(top_frow))/2;
   y3=(y4+min(j))/2;
   x=floor(x3);
   y=floor(y3);
   imshow(data);
   hold on;
   plot(x,y,'r*');
   hold on;
end
%imshow(bwc);
%hold on;
pause(0.0001);
end
stop(obj);
flushdata(obj);