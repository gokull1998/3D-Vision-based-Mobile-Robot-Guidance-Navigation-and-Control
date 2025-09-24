clear all;
close all;
filename = 'depth_curve_fitting.xlsx';
A = xlsread(filename)
for i=1:21
    pix(i)=A(i,2);
    cm(i)=A(i,1);
end
