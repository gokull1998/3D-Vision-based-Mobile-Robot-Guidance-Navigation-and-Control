close
X=[1 2 3];
Y=[5 6 7];
hold on
for i=1:20
  X=i;
  Y=i*2;
  plot(X,Y,'*')
  pause(1)
end
