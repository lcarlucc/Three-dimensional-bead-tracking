function [data] = remove_background_gradient(data,xrel,yrel)

%takes image data in form of a matrix of doubles and removes any background
%gradient
    
    
    %Subtract any gradient in pixel intensity across 'data' by fitting a
    %plane ('zz') to 'data' and then subtracting 'zz' from 'data'
    guesses = [1,1,30]; %initial guess for plane orientation: guesses(1) is slope in x-direction, guesses(2) is slope in y-direction, guesses(3) is z-coordinate

    estimates = fminsearch(@planeFit, guesses); % finds the plane that best fits the data based on 'guesses', 'xrel', and 'yrel'. Parameters for this plane are stored in 'estimates'
    zz = estimates(1)*xrel + estimates(2)*yrel + estimates(3); % plane fit of pixel intensities
    
    
    data = data-zz; %subtracts the plane fit intensities from 'data', this eliminates any brightness gradient.
    
    %%
    function [J] = planeFit(guesses)
        %This function is used to fit a plane to the pixel intensity data
        zest = guesses(1)*xrel+guesses(2)*yrel+guesses(3); %plane orientation based on 'guesses'
        J = sum(sum((zest-data).^2)); %'J' is RMS error between current plane and 'data'
    end % end 'planeFit' function

end