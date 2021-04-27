function [new_output_dir] = make_dir(directory, additional,filename,appendage)

output_dir = strcat(directory,additional,filename,appendage) %create analysis directory if one does not exist
new_output_dir = output_dir;
[~,~, msgID] = mkdir (new_output_dir);
counter = 0;
%if directory exists, append number to end
while ismember(msgID, 'MATLAB:MKDIR:DirectoryExists')
    counterstr = int2str(counter);
    new_output_dir = strcat(output_dir,'_',counterstr);
    [~,~, msgID] = mkdir (new_output_dir);
    counter = counter+1;
end
