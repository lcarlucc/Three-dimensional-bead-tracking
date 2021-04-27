function[] = TrackManyVids()
%tracks XYZ coordinates of beads in videos
%designed to analyze many videos back to back with only user input in
%beginning
%
%assumes tif images of video are name in the following format (described further in README): 
% 'basename''number of video''_''frame number''.tif'

%% Parameters to change/check for each run
%% specifies information about videos to be analyzed

%name identifier for series of r single) videos
basenames = {'8.3_'};

%creates array of number designations of videos to analyze
strtvid = 1; %first vid number in series to analyze
endvid = 2; %last vid number in series to analyze

%in regards to frame order in a video
startframe = 1;  %which frame in the video to start with (1 means 1st frame, regardless of how this frame is numbered)
endframe =100; %last frame to analyze 

%frame number of first frame in a video (to find the numbering offset)
frame_val_frstframe = 0; 

%name of LUT (model matrix) to call or to save a new mm as
modelMatrix_path =  'C:\Users\lacar\Documents\Grad school\Thomas lab\Lab Manuscripts\bead analysis paper\Matlab files\modelmatrix3.mat'

%will only be used if above line fails to import a model matrix
Z_stack_name = 'Z1_';%base name of reference image names taken in a Z stack
first_Z_image = 1; %which image to start Z stack at (assumes same numbering convention as with 'startframe')

dir_appendage = 'data'; %label to append to end of directory name (eg 'data')

%% user input paramenters for tracking beads

%positions for each step in Model Matrix (LUT)
modelMat_axial_loc = [99:-1:0]*2000; %vector of axial positions LUT was collected at
nair = 1; %Refraction of air (or medium between objective and chamber)
nwater = 1.33; %Refraction of water (or medium beads are in)
distanceVector = (nwater/nair)*modelMat_axial_loc; %adjust for interface

%number of model matrices to average together in final LUT
modelMat_num2use = 5; 

%number of nm per pixel at objective used (use 1 if want to report lateral position in pixels)
lateral_pix_conv = 275; 

scale_profiles = 0; %boolean whether to scale radial profiles for intensity

box_half_size = 55; %half size of length of box that will surround bead
%optimal box sizes that Ive found work well to encompass the bead without
%too much empty space (too large box may overlap with neighboring beads)
%suggested sizes in 20x:
%60 for 11 um beads
%55 for 8 um beads
%50 for 6 um beads
%45 for 3 um beads

% 1st pixel position of radial profile to be used in Z location
% determination 
%(all model matrices will always be collected and saved starting at
% position 1 even if the inner most positions will not be used in Z
% location analysis
% '1' indicates center most pixel, '12' skips the 11 center most pixels
strt_raxis = 12; %Recommend 12 beads > 3 um
%last pixel position
end_raxis =round(box_half_size*0.90);

rstep = 1; %radial step size
num_steps = 60; %number of angular steps, only passed to modelMatrix


%% create structure to store parameters used for every video in this run (ease parameter passing)

    var.modelMatrix_path = modelMatrix_path;
    var.startframe = startframe;
    var.endframe = endframe;
    var.box_half_size = box_half_size;
    var.rstep = rstep;
    var.num_steps = num_steps;
    var.distanceVector = distanceVector;
    var.strt_raxis = strt_raxis;
    var.end_raxis = end_raxis;
    var.scale_profiles = scale_profiles;
    var.modelMat_num = modelMat_num2use;
    var.pix_conv = lateral_pix_conv;
    var.frame_val_frstframe = frame_val_frstframe;
%%
%structure holding basic information of each file collected from user
data = struct('dir', {}, 'file', {}, 'output_dir', {}, 'xlaa', {}, 'ylaa', {});

directory =  uigetdir('E:\Laura', 'Select directory of analysis');


try %try to read in modelMatrix, if no excel exists or cannot find file, will create and save new model matrix
    modelMatrix_struct = load(modelMatrix_path);
    modelMatrix = modelMatrix_struct.modelMatrix;  
catch
    outputfile = modelMatrix_path;
    modelMatrix = get_modelMatrix(directory,['\' Z_stack_name],outputfile,  first_Z_image, var);
end  

    %store Model MAtrix
    var.modelMatrix = modelMatrix;

%%
total_vids = 0; %counter to keep track on number of videos
for c = basenames
    c
    for a = strtvid:endvid %this for loop involves input
        intval = int2str(a);
        total_vids = total_vids+1;
        filename=strcat('\',char(c),intval,'_');
       %filename = strcat('\',char(c));
        data(total_vids).dir = directory;
        data(total_vids).file = filename;

        %% create output directory
        data(total_vids).output_dir = make_dir(directory,'\analysis',filename, dir_appendage); %make directory and return name
        try %in case a file was mislabeled and does not follow sequence, program will skip this basename and not error out
            [data(total_vids).xlaa, data(total_vids).ylaa] = select_analysis_beads(box_half_size, startframe, directory, filename, strcat(data(total_vids).output_dir,"\",filename));
            close all
        catch ME
            %Remove for upload
            disp (ME)
            disp('skipping to next video')
            total_vids = total_vids -1 % ensure info from a failed basename will be written over
            continue
        end
    end
end
for vid_num = 1:total_vids %for each video
    if vid_num == 1
        disp(strcat('Initial bead positions recieved successfully. Beginning analysis of ', int2str(total_vids), ' videos'));
    end
    vid_num
    Tracking(data(vid_num).dir, data(vid_num).file, data(vid_num).xlaa, data(vid_num).ylaa, data(vid_num).output_dir,var)
end