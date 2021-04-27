function [data] = get_bead_box(image_mat,p1,x,y)
% cuts out a section of image that is a box 2*p1 by 2*p1 centered around xy
% coordinates of centroid

  %round xy coordinates down,
  %whole numbers are needed for indexing later
  x_round = floor(x);
  y_round = floor(y);
  
    % 'data' is a square set of pixels with center at the user selected
    % pixel and each side of length (2*p1)+1. This is the set of data that
    % will be used to calcualte the centroid of the bead and collect pixel
    % intensity data.
  data = image_mat(y_round-p1:y_round+p1, x_round-p1:x_round+p1);  
  
  %note: data is offset from image by a fraction of pixel caused by
  %rounding
  %this will be corrected during interpolation in calibrate function
end