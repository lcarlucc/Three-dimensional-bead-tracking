function [modelMatrix] = get_modelMatrix(cdirectory, cfilename, outputfile, first_Z_image_num, var) 

%unpack variables
distanceVector = var.distanceVector;
rstep = var.rstep;
p1 = var.box_half_size;
frame_val_frstframe = var. frame_val_frstframe;


num_images = length(distanceVector);

%correct var parameters to be for reference images
var.startframe = first_Z_image_num;
var.endframe = num_images;

corrected_Z_image_num = first_Z_image_num +(frame_val_frstframe-1);
[xlca, ylca] = select_calibration_beads(cdirectory,cfilename,outputfile(1:end-4),p1, corrected_Z_image_num); %select beads saves image of reference bead location
bead_num = size(xlca,1);
%modelMatrix = zeros(numel(distanceVector),numel([0:rstep:p1-6])); %preallocate modelMatrix
mm_indiv = zeros(num_images,numel([0:rstep:round(0.9*p1)]),size(xlca,1)); %for storing separate matrices for each bead

%get_xy_centroid
%convert return of centroid to usable form for calibrate KCJ

for a= 1:bead_num %create modelMatrix for each bead
    a
    [x_centroid, y_centroid] = get_xy_centroid(xlca(a), ylca(a),cdirectory,cfilename,var);
    modelMatrixtemp = calibrate_bead_profile(x_centroid,y_centroid,cdirectory,cfilename,var); %create 'modelMatrix' from z-stack images. Will be used to determine z-positions for analyis images
    %modelMatrix = modelMatrix+modelMatrixtemp;
    mm_indiv(:,:,a) = modelMatrixtemp;
end

%creating a large matrix
modelMatrix = mm_indiv;
save(outputfile, 'modelMatrix')

