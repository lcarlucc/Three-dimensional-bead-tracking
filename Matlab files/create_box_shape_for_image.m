function [xrel, yrel] = create_box_shape_for_image(p1)

%creates box that will enclose area of interest

    q = 2*p1+1; %length of side of box that will enclose bead (thus creating area of interest)
    
    % repmat(A,M,N) creates a large matrix consisting of an M-by-N tiling
    % of copies of A. The size of the matrix is [size(A,1)*M, size(A,2)*N].
    xrel = repmat(-p1:p1, q, 1); % xrel is matrix with q rows with each row having values (-p1:p1)
    yrel = repmat((-p1:p1)', 1, q); %yrel is matrix with q columns, with each columns having values (-p1:p1)
    
end