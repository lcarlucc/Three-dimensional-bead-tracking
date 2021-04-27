function [xlca, ylca] = select_calibration_beads(cdirectory, cfilename, outputfile, p1, Z_image_num)

startframeend = sprintf('%03.0f', Z_image_num); %3 digit number to append to filename
wcan = imread([cdirectory,cfilename, startframeend, '.tif']);%'wcan' is the data from the image in 'cdirectory' (was 040.tif)
colormap('gray'); %convert to grayscale
imagesc(wcan); %display image
title(['Click on Analysis Calibration Beads. Press enter when done ']);
[xlca, ylca]=ginput; %user pics bead, x-pixel and y-pixel are recorded in 'xlca' and 'ylca'
hold on
scatter(xlca,ylca,'r')
    for z=1:length(xlca)
        text(xlca(z)+p1/2,ylca(z)+p1/2,sprintf('%d',z)); %bead number is shown on plot at location of user click (xlaa,ylaa)
    end
saveas(gcf,strcat(outputfile,'_reference_bead.jpg'))
close