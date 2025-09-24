clc;
clear all;
close all;

%{
load('fivepointsandangles.mat');    % load workspace
initial_img=k100_0_90;            % initial image as acquired by robot 
%}

% Initial definition of variables 

% Occupancy Grid

length_map=4; % input(' Enter the length of the arena (m) : ');
breadth_map=4; % input(' Enter the breadth of the arena (m): ');
cellspermeter=40;
cmpercell=100/cellspermeter;
map = robotics.BinaryOccupancyGrid(length_map,breadth_map,cellspermeter);

% Robot position 
x_pos = 0.5;
y_pos = 0.5;
heading_angle=0;
curr_pose = [ x_pos y_pos ];

% Setting Target
xt=input('enter the x coordinate of the target point : ');
yt=input('enter the y coordinate of the target point : ');
tar_pose = [ xt yt ];

% Image acquisition

depthVid=videoinput('kinect','2','Depth_640x480');
depthVid.FramesPerTrigger = Inf;
start(depthVid)
flag = 1;
while (flag)                 % update flag at the end 
    initial_img=getdata(depthVid,1);
    size_img = size(initial_img);   % size of image ( row,col )
    flipped_img=flip(initial_img,2);    % to undo lateral inversion by row elements reversing

    % limit the range to 80-120 cms
    range_img=zeros(size_img(1,1),size_img(1,2));
for i=1:size_img(1,1)
    for j=1:size_img(1,2)
        if ((flipped_img(i,j)>=806)&&(flipped_img(i,j)<=1228))         
            range_img(i,j)=flipped_img(i,j);
        else
            range_img(i,j)=0;
        end
    end
end
% imtool(range_img);      % range limited image


%{
FLOOR SEGMENTATION BY AVERAGE METHOD
binary_img=imbinarize(range_img); 
imtool(binary_img);     %  without opening ( morphological )
for i=1:480
    average_value(i)=mean(binary_img(i,:));
    for j=1:640
    if((average_value(i)<=0.1)||(average_value(i)>=0.9))
        binary_img(i,j)=0;
    end
    end
end
% imtool(binary_img);    % after removing floor
se=strel('cube',9);
im_opened = imopen(binary_img,se);
%}


col_var = {};
for j = 1:size_img(2)
    col_var = [col_var,var(range_img(1:size_img(1),j))];
end

for j = 1:640
    if col_var{j} > 1.4e+05
        result_col(1:size_img(1),j) = range_img(1:size_img(1),j);
    else
        result_col(1:size_img(1),j) = 0;
    end
end

row_var = {};
for j = 1:size_img(1)
    row_var = [row_var,var(range_img(j,1:size_img(2)))];
end

for j = 1:480
    if row_var{j} > 1.7e+05
        result_row(j,1:size_img(2)) = range_img(j,1:size_img(2));
    else
        result_row(j,1:size_img(2)) = 0;
    end
end

segmented_img = result_col & result_row;
% imtool(segmented_img);      % after segmented 


stats_centroid = regionprops(segmented_img,'centroid');      % getting centroid value 
centroid=cell2mat(struct2cell(stats_centroid));
stats_bb = regionprops(segmented_img,'BoundingBox');
b_box=cell2mat(struct2cell(stats_bb));
size_b_box = (size(b_box,2));


% INCLUDE AFTER GETTING VIDEO FEED 
if(size_b_box)
tot_obst = size_b_box/4;
for a=1:tot_obst
    term=1+((a-1)*4);
    left(a)=round(b_box(1,term));                     % error if no obstacle 
    right(a)=round(b_box(1,term)+b_box(1,term+2));
    obst_breadth=right(a)-left(a);
    
    for i=1:480
        for j=1:640
            if(segmented_img(i,j)==0)
            range_img(i,j)=0;
            end
        end
    end
% imtool(range_img);         % after segmentation
%%
[r,c,v]=find(range_img);
pix_depth=mean(v);          % average value of depth
cm_depth=pix2cmdepth(pix_depth);
pix_breadth=max(c)-min(c);
pix_height=max(r)-min(r);
[cm_breadth,cm_height] = dim_pix2cm(cm_depth,pix_breadth,pix_height);
% calculate errors in dimensions - it adds up

%% working with occupancy grid
% define robot parameters
% x_pos=1.00;      % initial values 
% y_pos=0.00;
% theta=pi/2;    % measured from x axis - angle of orientation of robot 
m_depth=cm_depth/100;
m_breadth=cm_breadth/100;
m_height=cm_height/100;

inc = obst_breadth/(cm2pix_breadth(cm_depth, cmpercell));
for ogu=left(a):inc:right(a)
    offset=ogu-320;
    cm_offset = bre_pix2cm(cm_depth,offset);          
    m_offset=cm_offset/100;
    alpha = -(atand(cm_offset/cm_depth));
    image_m=x_pos+(m_depth*cos(heading_angle));
    image_n=y_pos+(m_depth*sin(heading_angle));
    obst_dist=(((m_depth)^2)+((m_offset)^2))^0.5;
    x_add=obst_dist*cosd(heading_angle+alpha);
    y_add=obst_dist*sind(heading_angle+alpha);
    obst_x=x_pos+x_add;
    obst_y=y_pos+y_add;
    mn = [ obst_x obst_y ];
    setOccupancy(map,mn,1);                     % DO NOT put inflate here! 
end

%{
l_offset = left-320;          % shows error when there is no obstacle
cm_l_offset = bre_pix2cm(cm_depth,l_offset);
m_l_offset=cm_l_offset/100;
l_alpha = -(atan(cm_l_offset/cm_depth));             % angle of obstacle centre from image centre
image_lm=x_pos+(m_depth*cos(theta));
image_ln=y_pos+(m_depth*sin(theta));
obst_l_dist=(((m_depth)^2)+((m_l_offset)^2))^0.5;
x_ladd=obst_l_dist*cos(theta+l_alpha);
y_ladd=obst_l_dist*sin(theta+l_alpha);
obst_lx=x_pos+x_ladd;
obst_ly=y_pos+y_ladd;
mn_l = [ obst_lx obst_ly ];
setOccupancy(map,mn_l,1);

r_offset = right-320;          % shows error when there is no obstacle
cm_r_offset = bre_pix2cm(cm_depth,r_offset);
m_r_offset=cm_r_offset/100;
r_alpha = -(atan(cm_r_offset/cm_depth));             % angle of obstacle centre from image centre
image_rm=x_pos+(m_depth*cos(theta));
image_rn=y_pos+(m_depth*sin(theta));
obst_r_dist=(((m_depth)^2)+((m_r_offset)^2))^0.5;
x_radd=obst_r_dist*cos(theta+r_alpha);
y_radd=obst_r_dist*sin(theta+r_alpha);
obst_rx=x_pos+x_radd;
obst_ry=y_pos+y_radd;
mn_r = [ obst_rx obst_ry ];
setOccupancy(map,mn_r,1);
%}

% show(map);

end          % end of occupancy grid updation loop
end
% Path Planning 

dec_turn = min(xt,yt);

% works perfectly for 1st quadrant including X+ and Y+ axes

if (( x_pos < dec_turn )&&( y_pos < dec_turn ))               % same row/col singularity
    theta = atand((dec_turn-y_pos)/(dec_turn-x_pos));
    
elseif (( x_pos < dec_turn )&&( y_pos > dec_turn ))
    theta = 360 + atand((dec_turn-y_pos)/(dec_turn-x_pos));
    
elseif (( x_pos > dec_turn )&&( y_pos < dec_turn ))
    theta = 90 + atand((dec_turn-y_pos)/(dec_turn-x_pos));
    
elseif (( x_pos > dec_turn )&&( y_pos > dec_turn ))
    theta = atand((dec_turn-y_pos)/(dec_turn-x_pos));
    
end

curr_loc_grid = world2grid(map,curr_pose(:,1:2));       % pose updated from odometry
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
    % pause(0.01);
    % show(map);
    % disp(curr_loc_grid);
    
    curr_pose = grid2world(map,curr_loc_grid);
    
    flag1 = mean(curr_pose==[ dec_turn-0.0125 dec_turn-0.0125 ]);   % workspace constant
    
    % disp(curr_pose);
    if(flag1)
        if( curr_loc_grid(:,2) < tar_col )
            theta = 0;
        elseif ( curr_loc_grid(:,2) > tar_col )
            theta = 180;
        elseif ( curr_loc_grid(:,1) < tar_row )
            theta = 270;
        elseif ( curr_loc_grid(:,1) > tar_row )
            theta = 90;
        end
    end
    flag = mean(curr_loc_grid~=tar_loc_grid) ;
             % end of path planning loop


end          % end of main loop 

stop(depthVid);
flushdata(depthVid);
