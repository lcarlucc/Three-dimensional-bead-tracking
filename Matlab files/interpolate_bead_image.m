function [interpVals] = interpolate_bead_image(data, xrel, yrel, raxis, theta, remainderx, remaindery)
 %%
    % interpolate and store angular-average pixel intensity data, for each
    % radial step
    
    s = numel(raxis);  %number of radial steps
    s2 = numel(theta); %number of angular steps
    
    R = repmat(raxis, s2,1); %Create matrix with 's2' rows and each row having values of 'raxis'
    T = repmat(theta', 1, s); %Create matrix with 's' columns and each column having values of 'theta'
    
    delx =R.*cos(T);  %delx is a matrix of x coords at which pixel intensities will be collected
    dely = R.*sin(T);  %dely is a matrix of y coords at which pixel intensities will be collected
    
    
    %add pixel remainder to x and y coordinate matrices so that data will
    %be centered precisely on calculated centroid
    xtempInd = delx+remainderx ;
    ytempInd = dely+remaindery ;
    
    
    InterpFun = interp2(xrel,yrel,data,xtempInd,ytempInd,'spline');   % this interpolates 'data' taken at points (xrel,yrel) to points (xtempInd,ytempInd)
    interpVals = mean(InterpFun); % averages pixel intensities over angular steps, result is a row vector of pixel intensities at each radial step
end