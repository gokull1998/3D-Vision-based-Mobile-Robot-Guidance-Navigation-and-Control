clc;
clear all;
close all;
%filePath = fullfile(fileparts(which('PathPlanningExample')),'data','exampleMaps.mat');
%load(filePath)
simpleMap=false(80);
map = robotics.BinaryOccupancyGrid(simpleMap,1)
%%
x1=input('enter the x coordinate of the start point : ');
y1=input('enter the y coordinate of the start point : ');
x2=input('enter the x coordinate of the stop point : ');
y2=input('enter the y coordinate of the stop point : ');
start = [ x1 y1 ];
curr_x = x1;
curr_y = y1;
stop = [ x2 y2 ];
target_x = x2;
target_y = y2;
act_diff_x = abs(x2-x1);
act_diff_y = abs(y2-y1);
if(act_diff_x > act_diff_y )
    decider = act_diff_x;
else
    decider = act_diff_y;
end
for i=1:decider
    change_x=target_x-curr_x;
  if(change_x>0)
      curr_x = curr_x + 1;
  else
      if(change_x<0)
      curr_x = curr_x - 1;
      end
  end
    change_y=target_y-curr_y;
  if(change_y>0)
      curr_y = curr_y + 1;
  else 
      if(change_y<0)
      curr_y = curr_y - 1;
      end
  end
  curr = [ curr_x curr_y ];
  occval = getOccupancy(map,curr);
  if(occval==1)
      break;
  end
  setOccupancy(map,curr,1);
  pause(0.001);
  show(map);
end      
%occval = getOccupancy(map,start);
