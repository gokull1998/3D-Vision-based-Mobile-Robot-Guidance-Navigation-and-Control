%%
img = d100;
img(img>(1200)) = 65535;
img(img<(800)) = 65535;
imtool(img);