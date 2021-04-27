function [centromatrix_x, centromatrix_y] = get_xy_centroid(xL,yL,directory,filename,var)
%% get centroids for all beads in a video given initial location (change to one bead at time)
%xL: x-position from user selection
%yL: y-position from user selection

%directory: directory in which images are contained
%filename: file names of experimental images (without appending number)

%% extract variables from structure to be used
endImage = var.endframe;
startframe = var.startframe;
p1 = var.box_half_size;
frame_val_frstframe = var.frame_val_frstframe; 

%%
%Determines the centroid of each bead, for each image. Stores this data in
%centromatrix_x and centromatrix_y
centromatrix_x=zeros(endImage - startframe+1,1); %preallocate matrix to store x-positions of each frame
centromatrix_y=zeros(endImage - startframe+1,1); %preallocate matrix to store y-positions of each frame

adjusted_start = startframe-startframe+1;
adjusted_end = endImage-startframe+1;
%%
    for j=adjusted_start:adjusted_end %for each image 
        
        x=floor(xL); %the x-coordinate (in pixels) of the user click (rounded to the nearest pixel)
        y=floor(yL); %the y-coordinate (in pixels) of the user click (rounded to the nearest pixel)
        
        %For every image, except the first, guess that the centroid is the same
        %as the centroid of the previous image centroid of the previous image.
        %This will allow tracking of beads that have moved from image to image.
        if j>adjusted_start
            x=floor(globalcentroidX);
            y=floor(globalcentroidY);
        end

    %if either x or y too close to the edge of the image (p1+10 pixels) this
    %could cause tracking errors. Make the x,y locations for this bead for
    %this image forward equal to zero.
    if x<(p1+10) %if too close to the left edge
        centromatrix_x(j:adjusted_end)=0;
        centromatrix_y(j:adjusted_end)=0;
        break
    elseif y<(p1+10) %if too close to the bottom edge
        centromatrix_x(j:adjusted_end)=0;
        centromatrix_y(j:adjusted_end)=0;
        break
    elseif x>(1920-(p1+10)) %if too close to right edge
        centromatrix_x(j:adjusted_end)=0;
        centromatrix_y(j:adjusted_end)=0;
        break
    elseif y> (1080-(p1+10)) %if too close to top edge
        centromatrix_x(j:adjusted_end)=0;
        centromatrix_y(j:adjusted_end)=0;
        break
    end %end if statement
        
        %Read in each experimental image into 'image_mat'
        frame_num_offset = frame_val_frstframe - 1;
        image_mat = read_image(directory,filename,j+frame_num_offset+(startframe-1));
        
        %cut out square section of image that contains bead of interes
        data_gradient = get_bead_box(image_mat,p1,x,y);
        
        %get matrix of x and y coordinates
        [xrel,yrel] = create_box_shape_for_image(p1);
        data = remove_background_gradient(data_gradient,xrel,yrel);
        
        %using intitial user guess, x and y, determine actual position of
        %centroid
        [globalcentroidX, globalcentroidY] = get_bead_centroid(data,x,y);
        
        centromatrix_x(j) = globalcentroidX;
        centromatrix_y(j) = globalcentroidY;
       
               
    end  % end of j loop


end