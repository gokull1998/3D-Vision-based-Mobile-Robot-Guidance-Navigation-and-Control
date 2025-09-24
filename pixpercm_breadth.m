function breadth_pixpercm = pixpercm_breadth(depth_cm)
breadth_pixpercm = (0.003658*depth_cm.^2  + (-2.02)*depth_cm + 347.3)/32;  
end