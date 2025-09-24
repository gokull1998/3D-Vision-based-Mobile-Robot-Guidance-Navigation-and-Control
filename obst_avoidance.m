%%
clc;
clear all;
close all;
temp=rand(2)*10;
start=temp(:,1)
stop=temp(:,2)
x=temp(1,:);
y=temp(2,:);
%filledCircle([1,1],0.5,1000,'b');    % plot(2,5,'o','MarkerSize',20);
%%
curr_x=start(1,1);
curr_y=start(2,1);
target_x=stop(1,1);
target_y=stop(2,1);
distance=(((target_x-curr_x)^2)+((target_y-curr_y)^2))^0.5
iterate_no=round(rand(1,1)*(round(10*distance)))
text(curr_x+0.2,curr_y,'Start','Color','red','FontSize',12);
text(target_x+0.2,target_y,'Stop','Color','red','FontSize',12);
hold on
diff_x=abs(target_x-curr_x);
diff_y=abs(target_y-curr_y);
%%
for i=1:iterate_no
    change_x=target_x-curr_x;
  if(change_x>=0)
      curr_x = curr_x + (diff_x/iterate_no);
  else
      curr_x = curr_x - (diff_x/iterate_no);
  end
    change_y=target_y-curr_y;
  if(change_y>=0)
      curr_y = curr_y + (diff_y/iterate_no);
  else
      curr_y = curr_y - (diff_y/iterate_no);
  end
  plot(curr_x,curr_y,'*')
  axis([0 10 0 10])
  pause(0.1)
  title('Path Planning');
end


