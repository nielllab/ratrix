function r = sbxalign_tif_rot(ImgSeq, idx)
%Similar to sbxalign_tif, but with rotation calculated into the rigid
%alignment process -D Wyrick
if(length(idx)==1)
    
    A = ImgSeq(:,:,idx(1)); 
    A = edgetaper(A,fspecial('gaussian',10,2));
    
    %Set the mean to the image itself & the transformation matrix to the
    %identity matrix
    r.m{1} = A; 
    r.T = {eye(3)}; 
    r.n = 1; 
elseif (length(idx)==2)
    %% Subtract away the mean
    A = ImgSeq(:,:,idx(1));  
    B = ImgSeq(:,:,idx(2)); 
    A = A - mean(A(:));
    B = B - mean(B(:));
    
    %Configurations for intensity-based registration
    [optimizer, metric] = imregconfig('monomodal');
    
    %Obtain geometric transformation matrix that aligns A to B
    D = imregtform(A,B,'rigid',optimizer, metric);

    %Apply Transformation to A, but keep the matrix size the same
    Rfixed = imref2d(size(A));
    Ar = imwarp(ImgSeq(:,:,idx(1)),D,'OutputView',Rfixed);
    
    %Calculate the mean
    r.m{1} = (Ar/2 + ImgSeq(:,:,idx(2))/2);
    
    %Output tranformation matrices
    r.T = [{D.T} {eye(3)}];
else
    %% split into two groups
    idx0 = idx(1:floor(end/2)); 
    idx1 = idx(floor(end/2)+1 : end);
    
    % align each group
    r0 = sbxalign_tif_rot(ImgSeq,idx0); 
    r1 = sbxalign_tif_rot(ImgSeq,idx1);
    
    %Subtract away the mean
    A = r0.m{1};
    B = r1.m{1};
    A = A - mean(A(:));
    B = B - mean(B(:));
    
    %Configurations for intensity-based registration
    [optimizer, metric] = imregconfig('monomodal');
    
    %Obtain geometric transformation matrix that aligns A to B
    D = imregtform(A,B,'rigid',optimizer, metric);
    
    %Apply Transformation to A, but keep the matrix size the same
    Rfixed = imref2d(size(A));
    Ar = imwarp(r0.m{1},D,'OutputView',Rfixed);
    
    %Calculate the mean
    r.m{1} = (Ar/2+r1.m{1}/2);
    
    %Apply transformation matrix to previous iterations 
    r0.T = cellfun(@(x) (x*D.T),r0.T,'UniformOutput',false); 
    
    %Output new set of transformation matrices
    r.T = [r0.T r1.T];
end

