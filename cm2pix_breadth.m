function pix_breadth = cm2pix_breadth(depth_cm, cm_breadth)
pix_breadth = cm_breadth*(0.003658*depth_cm.^2  + (-2.02)*depth_cm + 347.3)/32;  
end