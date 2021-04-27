function [zesta, energy_comp] = get_interpolatedz(modelMatrix, interpVals, distanceVector, zGuess, strt_raxis, end_raxis)
%%
% return interpolated z value and the error for those values

     %if no initial guess
    if zGuess == 0 %if first frame being analyzed (no previous estimate)
        difi=zeros(1,length(distanceVector)); %preallocate for speed
        
        %get initial guess by finding ref bead closest
        for i = 1:numel(distanceVector) %for each z step taken in calibration stack...
             pr = modelMatrix(i,strt_raxis:end_raxis); %'pr' is a row vector of the radial pixel intensity at the ith z-step of the calibration bead
             difi(1,i) = sqrt(sum(abs(pr - interpVals(:,strt_raxis:end_raxis)).^2)); %'difi' is the RMS error between the experimental data and 'modelMatrix' pixel intensities
        end %end of i loop
        
        [~, I] = min(difi); %'I' is the row indice of the first minimum RMS difference from 'difi'
        zGuess = distanceVector(I); %initial guess for the calibration image that has least amount of error
    end
        
    %Need to add this becasue fminsearch returns wrong minimized values if
    %initial guess is close to zero (perhaps this has been fixed with more
    %recent matlab versions?)
    if abs(zGuess)<.01
        if zGuess<=0
            zGuess=-.01;
        elseif zGuess>0
            zGuess=.01;
        end
    end
    
    %%
    %use 'Cost' function to interpolate to more precise z-position
    
    gi=0; % initialize iteration counter
    zesta = fminsearch(@(z) Cost(z,interpVals(:,strt_raxis:end_raxis), modelMatrix(:,strt_raxis:end_raxis), distanceVector),zGuess); %zesta is interpolated z-coordinate for analysis bead position
    
    %now get energy costs
    [energy_comp, ~]=Cost(zesta,interpVals(:,strt_raxis:end_raxis),modelMatrix(:,strt_raxis:end_raxis),distanceVector); %extract final radial vector for plotting purposes
    


 end
 %%

    function [energy, estimate] = Cost(za, interpVals,modmat,distvect)
        %Function 'Cost' estimates the error between the calibration images (stored
        %in 'modmat') and the current bead image (stored in interpVals).
        
        %za: guess of z-position (in nm)
        %interpVals: vector of pixel intensities at different radial values for
        %current analysis bead for current image
        %modmat: matrix of pixel intensity vectors for different z-positions
        %distvect: vector of z-positions used in 'modmat'
        
        %gi=gi+1; %used to count iterations
        rvectp=[1:size(modmat,2)]; %vector from 1: number of radial steps
        estimate = zeros(1,size(modmat,2)); %matrix to store estimated pixel intensities from calibration images
        %as a function of radial step
        zvectfit=za*ones(1,size(modmat,2)); %vector of length raxis with repeats of the zguess
        % repmat(A,M,N) creates a large matrix consisting of an M-by-N tiling
        % of copies of A. The size of the matrix is [size(A,1)*M, size(A,2)*N].
        zvectinterp=repmat(distvect',1,size(modmat,2)); %matrix of the z-positions used in interpolation
        rvectinterp=repmat(1:size(modmat,2),length(distvect),1); %matrix of radial positions used in interpolation
        
        %Vq = interp2(X,Y,V,Xq,Yq) interpolates to find Vq, the values of the
        %underlying 2-D function V at the query points in matrices Xq and Yq.
        %Matrices X and Y specify the points at which the data V is given.
        estimate=interp2(rvectinterp,zvectinterp,modmat,rvectp,zvectfit,'spline'); %estimate of radial vector for 'z' based on modelMatrix
        cc = (((estimate)- interpVals).^2); % RMS error between interpolated radial intensity vector and analysis bead radial intensity vector
        %error_scaling
        %cc = cc.*
        
        %estimate is the 1D section of model matrix that Cost is trying
        %to make the most like the data
               
        energy = sum(cc); %Determine total RMS error
        %energygi(gi)=energy; % Determine RMS error at current iteration
    end % end 'Cost' function
    
 
    

