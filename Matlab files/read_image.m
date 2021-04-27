function [image_mat] = read_image(directory, filename, number)

%Read in each experimental image and convert into matrix of doubles stored
%as image_mat

  fileend = sprintf('%03.0f', number); % get three digit number for the current image
  %imread returns 2D matrix of uint8 variables if image is grayscale
  image_mat = double(imread([directory, filename, fileend, '.tif'])); %read in image data 
  
end