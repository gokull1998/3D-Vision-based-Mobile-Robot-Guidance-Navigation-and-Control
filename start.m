clc
clear all;
close all;
map=imread('mapimage.png');
map=rgb2gray(map);
map=im2bw(map,0.30);
map=imcomplement(map);
grid = robotics.BinaryOccupancyGrid(map);
%ij = world2grid(map,xy)
inflate(grid,20)
show(grid)