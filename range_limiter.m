function y = range_limiter(x)
for i=1:480
    for j=1:640
        if ((x(i,j)>=806)&&(x(i,j)<=1228))
            y(i,j)=x(i,j);
        else
            y(i,j)=0;
        end
    end
end
end