function [coord] = TrackBeadsInZ(xL,yL, directory, filename, var)
%% finds Z position, returns matrix containing XYZ positions in nm
% X and Y positions are converted from pixel to nm
%  Estimates the bead z-position be reducing error between analysis images
%  and lookup table (modelMatrix),one bead at a time.

%xL: vector of x-dimension centroid for a single bead as a function of
%image
%yL: vector of y-dimension centroid for a single bead as a function of
%image

%% Extract variables from var structure
distanceVector = var.distanceVector;
startframe = var.startframe;
endframe = var.endframe;
modelMatrix = var.modelMatrix;
strt_raxis = var.strt_raxis;
end_raxis = var.end_raxis;
modelMat_num2use = var.modelMat_num;
lateral_pix_conv = var.pix_conv;

%%
reference_frame = 1; %frame of analysis vid that will be used to choose the optimal model matrix (one where bead is likely on bottom of slide)

if size(modelMatrix,3) <modelMat_num2use
    modelMat_num2use = size(modelMatrix,3);
end
%To have empty values stored as NaN instead of zeros change this line to
%NaN
coord = zeros(endframe,3); % This matrix will store an estimate of the x,y,z coordinates for each image.

modelMat_err = zeros(numel(distanceVector),1);
modelMat_scores = zeros(size(modelMatrix,3), 2);
modelMat_allenergies = zeros(numel(distanceVector), size(modelMatrix,3));

modelMat_ref_used = NaN(size(modelMatrix,3),(endframe-startframe+1)); %create empty cell array for storing the identities of ref matrices used

%store energies for screening frame
modelMat_screen = zeros(size(modelMatrix,3),1); 

errors = zeros(startframe,endframe);

%bead_array = zeros(numel(distanceVector),numel(raxis)); %for storing radial profiles at each image


%% get radial intensity profiles for each bead at each image
% returns 2D matrix containing 1D radial profiles over each frame
bead_array = calibrate_bead_profile(xL,yL,directory,filename,var);

adjusted_start = startframe-startframe+1;
adjusted_end = endframe-startframe+1;

%% Find model matrices with lowest error for current analysis bead
 %get the radial array for frame of interest
 interpVals_ref = bead_array(reference_frame,:); 
 
 %test every model matrix with frame of interest to get error for each
 for mm = 1:size(modelMatrix,3)       
    zGuess = 0; %clear initial guess
    [~,energy_comp] = get_interpolatedz(modelMatrix(:,:,mm), interpVals_ref, distanceVector, zGuess, strt_raxis, end_raxis);
    modelMat_screen(mm) = energy_comp; %error
    
 end
 
 %% Create model matrix array to use in final analysis
    
   [errors_sorted, indices] = sort(modelMat_screen);
    modelMat_index_best = indices(1:modelMat_num2use); %get indices of best model matrices

    modelMat_screen(modelMat_index_best);
    modelMat_best = modelMatrix(:,:,modelMat_index_best);%get the model matrices with the best scores
    modelMat_avg = mean(modelMat_best,3); %average model matrices together to get final model matrix (2D array)

 %% Find z values for all frames using modelMat_avg
    zGuess = 0; %clear zGuess
    for frame = adjusted_start:adjusted_end 

        interpVals = bead_array(frame,:);       
         %if interpVals is all zeros (bead lost)
        if nnz(interpVals)==0 
             break
        end
        [z_val, energy_cost] = get_interpolatedz(modelMat_avg,interpVals,distanceVector,zGuess, strt_raxis, end_raxis);
        
        %every frame
        zGuess = z_val; %initial guess for next frame is value from previous frame


        % store values in array        
        coord(frame,1)=(xL(frame)*lateral_pix_conv); % x-position of bead in nm
        coord(frame,2)=(yL(frame)*lateral_pix_conv); % y-position of bead in nm
        
        coord(frame,3) = z_val;

    end %end loop through frames
    modelMat_err;
    

end % end function 
