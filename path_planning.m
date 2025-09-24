clc;
clear all;
close all;
length_map=4; % input(' Enter the length of the arena (m) : ');
breadth_map=4; % input(' Enter the breadth of the arena (m): ');
cellspermeter=40;
cmpercell=100/cellspermeter;
map = robotics.BinaryOccupancyGrid(length_map,breadth_map,cellspermeter);
x_pos=input('enter the x coordinate of the current point : ');
y_pos=input('enter the y coordinate of the current point : ');
% tc=input('enter the heading angle at current point : ');
xt=input('enter the x coordinate of the target point : ');
yt=input('enter the y coordinate of the target point : ');
% tt=input('enter the heading angle at current point : '); 
curr_pose = [ x_pos y_pos ];       % metrics
tar_pose = [ xt yt ];        % metrics

dec_turn = min(xt,yt);

% works perfectly for 1st quadrant including X+ and Y+ axes

if (( x_pos < dec_turn )&&( y_pos < dec_turn ))               % same row/col singularity
    angle = atan((dec_turn-y_pos)/(dec_turn-x_pos));
elseif (( x_pos < dec_turn )&&( y_pos > dec_turn ))
    angle = 2*pi + atan((dec_turn-y_pos)/(dec_turn-x_pos));
elseif (( x_pos > dec_turn )&&( y_pos < dec_turn ))
    angle = pi + atan((dec_turn-y_pos)/(dec_turn-x_pos));
elseif (( x_pos > dec_turn )&&( y_pos > dec_turn ))
    angle = pi + atan((dec_turn-y_pos)/(dec_turn-x_pos));
end

curr_loc_grid = world2grid(map,curr_pose(:,1:2));
tar_loc_grid = world2grid(map,tar_pose(:,1:2));
% met_percell = cmpercell/100;
% col_cells=(xt-xc)/met_percell;
% row_cells=(yt-yc)/met_percell;
% x in world = col in grid, y in world = row in grid 
% x min to max = col min to max, y min to max = row max to min
curr_row = curr_loc_grid(:,1);
curr_col = curr_loc_grid(:,2);
% curr_or = curr_loc(:,3);
tar_row = tar_loc_grid(:,1);
tar_col = tar_loc_grid(:,2);
% tar_or = tar_loc(:,3);
%{
inc_row=(tar_row-curr_row)/abs(tar_row-curr_row);
inc_col=(tar_col-curr_col)/abs(tar_col-curr_col);
if(curr_row<=tar_row)
    inc_row = 1;
else 
    inc_row =-1;
end
if(curr_col<=tar_col)
    inc_col = 1;
else 
    inc_col =-1;
end
%}
flag=1;
while flag 
    if(curr_col<tar_col)
        curr_col=curr_col+1;
    elseif(curr_col>tar_col)
        curr_col=curr_col-1;
    end
    if(curr_row<tar_row)
        curr_row=curr_row+1;
    elseif(curr_row>tar_row)
        curr_row=curr_row-1;
    end
    curr_loc_grid=[ curr_row curr_col ];
    occval = getOccupancy(map,curr_loc_grid,'grid');
    if(occval==1)
        break;
    end
    setOccupancy(map,curr_loc_grid,1,'grid');
    pause(0.01);
    show(map);
    % disp(curr_loc_grid);
    curr_pose = grid2world(map,curr_loc_grid);
    flag1 = mean(curr_pose==[ dec_turn-0.0125 dec_turn-0.0125 ]);   % workspace constant
    % disp(curr_pose);
    if(flag1)
        if( curr_loc_grid(:,2) < tar_col )
            angle = 0;
        elseif ( curr_loc_grid(:,2) > tar_col )
            angle = pi;
        elseif ( curr_loc_grid(:,1) < tar_row )
            angle = 3*pi/2;
        elseif ( curr_loc_grid(:,1) > tar_row )
            angle = pi/2;
        end
    end
    flag = mean(curr_loc_grid~=tar_loc_grid) ;
end                     % end of path planning loop


       
   
    
 
          
    
        
    