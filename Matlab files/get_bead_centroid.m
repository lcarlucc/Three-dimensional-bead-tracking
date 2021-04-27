function [globalcentroidX, globalcentroidY] = get_bead_centroid(data,x,y)

%Use 'Pauls FFT method' to determine the centroid of the bead.
    
    precision =50; % pixel precision, precision =50 will result in 1/50th of pixel precision
    imB = rot90(data,2); % rotate image data 180 degrees
    out =  intAlignIm(data, imB, precision); %'out' represents the pixel shift (x and y) needed to achieve alignment with centroid
    xc = out(4)/2; % pixel shift required in x-direction
    yc = out(3)/2; % pixel shift required in y-direction
    globalcentroidX = x + xc; %x-coordinate (in pixels) of calculated centroid
    globalcentroidY = y + yc; %y coordinate (in pixels) of calculated centroid
   
end