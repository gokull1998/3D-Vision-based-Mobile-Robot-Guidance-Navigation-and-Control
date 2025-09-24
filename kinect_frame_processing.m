%%
frame1=d80;
frame1=double(frame1);
frame1=frame1/4000;
for i=1:480
    for j=1:640
        if(frame1(i,j)==0)
            frame1(i,j)=1;
        end
    end
end
imtool(frame1);
