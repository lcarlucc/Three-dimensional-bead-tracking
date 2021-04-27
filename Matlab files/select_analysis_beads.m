function [xlaa, ylaa] = select_analysis_beads(p1, startframe, directory, filename, outputfile)

startframeend = sprintf('%03.0f', startframe-1); %3 digit number to append to filename
waan=imread([directory,filename,startframeend,'.tif']); %read in image file
imagesc(waan)
colormap('gray'); %convert to gray scale
%draw border around edge for picking bead
waan=insertShape(waan,'Rectangle',[p1*.75,p1*.75,1920-2*(p1*.75),1080-2*(p1*.75)], 'LineWidth', 5, 'Color', 'black'); %plots rectangle used to identify beads too close to edges.
imagesc (waan)
hold on

%this part adds circles to selected beads so that you can tell which ones
%you already selected
old_num_sel=0; %used to determine number of beads selected
xlaa=[]; %vector containing x-coordinates of ginput selections
ylaa=[]; %vector containing y-coordinates of ginput selections
done=[]; % number of selected beads
%now the user selects the beads to analyze
while isempty(done)
    title(['Click on Analysis Beads. Press enter when done '])
    %waan = insertShape(waan, 'Circle', 100, 100, p1);
    [xlaap, ylaap]=ginput();%user pics bead, x-pixel and y-pixel is recorded
    num_sel=length(xlaap)+old_num_sel; %tells you how many beads have been selected
    
    old_num_sel=num_sel; % add new beads to old_num_sel
    if isempty(xlaa) %if these are first beads selected
        xlaa=xlaap; %add new bead x-location to xlaa
        ylaa=ylaap; %add new bead y-location to ylaa
    else %if new beads were added, add them into the coordinate vectors xlaa and ylaa
        xlaa=cat(1,xlaa,xlaap);
        ylaa=cat(1,ylaa,ylaap);
    end
    scatter(xlaa,ylaa,'r') %show selections already made by user

    for z=1:length(xlaa)
        text(xlaa(z)+p1/2,ylaa(z)+p1/2,sprintf('%d',z)); %bead number is shown on plot at location of user click (xlaa,ylaa)
    end
    done=input([sprintf('%03d',num_sel) ' beads selected. Press enter to add more beads, press 1 enter if finished ']); %if this is the last bead to use, press 1 enter, otherwise enter to select more beads
end

saveas(gcf,strcat(outputfile,'beads.jpg')) %saves image of bead locations
close