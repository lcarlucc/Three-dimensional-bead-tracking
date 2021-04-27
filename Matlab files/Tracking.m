function []= Tracking(directory, filename, xlaa, ylaa, output_dir,var)
%Function that processes bead images to output and save XYZ positions of
%selected coordinates
%Call from TrackManyVids to fascilitate parameter entering

%directory: folder in which images are stored in
%filename: name of video being tracked (without frame number appended at
%end
%xlaa: x coordinate of user input x position
%ylaa: y coordinate of user input y position
%output_dir: 
%var is a structure containing various parameters defined in TrackManyVids


%% Create prefix based on folder name that is put before the created position file
outputfile = fullfile(output_dir,filename); 

%% writes and saves inputs as text file stored in directory

textfilename = strcat(output_dir, "\", 'info.txt');
txtfile = fopen(textfilename,'w');
fprintf ( txtfile, '%s\r\n', 'Summary of parameters');
fprintf (txtfile, '%s %d %s %d\r\n', 'startframe', var.startframe,'endframe',var.endframe);
fprintf (txtfile, '%s %d %s %d\r\n',   'box_half_size',var.box_half_size, 'radial_step_size', var.rstep); 
fprintf (txtfile, '%s %d %s %d\r\n', 'number of angular steps', var.num_steps, 'scale', var.scale_profiles);
fprintf (txtfile, '%s %d %s %d\r\n',   'raxis analysis start',var.strt_raxis, 'raxis analysis end', var.end_raxis);

fprintf (txtfile, '%s %s %s %s\r\n',  'directory', directory, 'filename', filename);
fprintf (txtfile, '%s %s', 'modelMatrix path', var.modelMatrix_path); 

fclose(txtfile);
number_an_beads = numel(xlaa);
number_images = var.endframe - var.startframe+1;
%% Track XY
%Get centroid of each bead for each image.
centro_x = zeros(number_images,number_an_beads);
centro_y = zeros(number_images,number_an_beads);
for i = 1:number_an_beads
    [centro_x(:,i), centro_y(:,i)]=get_xy_centroid(xlaa(i),ylaa(i),directory,filename,var); %output are matrices with x and y locations of each stuck beads centroid
end

%% Track Z
% Find and save z positions of beads
for i=1:number_an_beads
    i
    clear coord_mat_an %clear output from 'trackBeads' for new iteration
    [coord_mat_an] = TrackBeadsInZ(centro_x(:,i),centro_y(:,i),directory,filename,var);% estimate x,y,z-positions of each analysis bead
    coordinate_matrix_analysis{i}=coord_mat_an;    %each cell of coordinate_matrix_analysis contains a column vectors of the x,y, and z-positions of the i-th bead as a function of time
end

%extract all bead z cordinates into single matrix
   
for i=1:number_an_beads
    z_vals(:,i)=coordinate_matrix_analysis{i}(:,3);
    x_vals(:,i) = coordinate_matrix_analysis{i}(:,1);
    y_vals(:,i) = coordinate_matrix_analysis{i}(:,2);
    %an_xyz(:,3*i-2:3*i)=coordinate_matrix_analysis{i}(:,1:3); %first three columsn are x,y,z of first bead, second 3 columns are x,y,z of second bead, etc
end

%save as excel
data_name = strcat(outputfile,'positions.xlsx');
%xlswrite(data_name,an_xyz,'xyz') %save locations in separate excel
writematrix(x_vals,data_name,'Sheet','x movement')
writematrix(y_vals,data_name,'Sheet','y movement')
writematrix(z_vals,data_name,'Sheet','z movement')

%save as Matlab data
positions.x =x_vals;
positions.y = y_vals;
positions.z = z_vals;
save(strcat(outputfile,'positions.mat'),'positions'); 


end


