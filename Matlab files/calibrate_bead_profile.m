function [profile_matrix] = calibrate_bead_profile(xL,yL,directory,filename,var)
%% create 1D profile from an image of a bead from directory and filename given a range

%%extract variables from var structure
rstep = var.rstep;
p1 = var.box_half_size;
N = var.num_steps;
startframe = var.startframe;
endframe = var.endframe;
strt_raxis = var.strt_raxis;
end_raxis = var.end_raxis;
scale_profiles = var.scale_profiles;
frame_val_frstframe = var.frame_val_frstframe;

%%
raxis = [0:rstep:round(0.9*p1)]; % vector (in pixels) in radial direction at which pixel intensities will be analyzed
theta = [0:N-1]*2*pi/N; % vector (in radians) in angular direction at which pixel intensities will be analyzed

%%
%stores the angular average pixel intensity for each radial
%step for each calibration image

profile_matrix = zeros((endframe-startframe+1),numel(raxis));%% a matrix of size(number of calibration images, number of radial steps)

%%
%For each calibration image, first choose an area of interest around the
%bead based on 'p1'. Then determine the centroid of the bead and store the
%angular averaged pixel intensity for each radial step into 'modelMatrix'

adjusted_start = startframe-startframe+1;
adjusted_end = endframe-startframe+1;

for dist = adjusted_start:adjusted_end %for each frame
   
    x = xL(dist);
    y = yL(dist);
    
    %if an x position was set to 0 (meaning tracking lost)
    if x ==0
        break
    end
     %%
    %if either x or y too close to the edge of the image (p1+10 pixels) this
    %could cause tracking errors. Make the x,y locations for this bead for
    %this image forward equal to zero.
    if x<(p1+10) %if too close to the left edge
        xL(dist:adjusted_end)=0;
        yL(dist:adjusted_end)=0;
        break
    elseif y<(p1+10) %if too close to the bottom edge
        xL(dist:adjusted_end)=0;
        yL(dist:adjusted_end)=0;
        break
    elseif x>(1920-(p1+10)) %if too close to right edge
        xL(dist:adjusted_end)=0;
        yL(dist:adjusted_end)=0;
        break
    elseif y> (1080-(p1+10)) %if too close to top edge
        xL(dist:adjusted_end)=0;
        yL(dist:adjusted_end)=0;
        break
    end %end if statement
    
 %%   
    
    %Read in each image and convert to a martix
        frame_num_offset = frame_val_frstframe - 1;
        image_mat = read_image(directory,filename,dist+frame_num_offset+(startframe-1));
    
    %define size of box to encompass bead
    [xrel,yrel] = create_box_shape_for_image(p1);
    
        flooredcentroidx=floor(x); %x-coordinate of calculated centroid (rounded down to nearest pixel)
        remainderx=x-flooredcentroidx; %used to get precise centroid location later
        flooredcentroidy=floor(y); %y-coordinate of calculated centroid (rounded down to nearest pixel)
        remaindery=y-flooredcentroidy; %used to get precise centroid location later

     %center box around bead and remove background
        data_gradient = get_bead_box(image_mat,p1,x,y);    
        [data] = remove_background_gradient(data_gradient, xrel,yrel);

    
    %%
    % interpolate and store angular-average pixel intensity data, for each
    % radial step
    interpVals = interpolate_bead_image(data, xrel, yrel, raxis, theta, remainderx, remaindery);

    %scale interpolated values if specified to
    if scale_profiles
        max_val = max(interpVals(strt_raxis:end_raxis));
        min_val = min(interpVals(strt_raxis:end_raxis));
        range = max_val - min_val;
        %scale to correct for differences in max/min brightness
        adjustment_factor = 100./range; 
        %adjust the range to account for differences in brightness range
        scaled_interpVals = interpVals*adjustment_factor;
        %shift profile so bottom points line up along y axis
        min_adjusted = min(scaled_interpVals);
        interpVals = scaled_interpVals - min_adjusted;
    end
    profile_matrix(dist,:) = interpVals;
     
end
