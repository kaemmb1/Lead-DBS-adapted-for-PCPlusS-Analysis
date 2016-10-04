function y = WFK_prepareDEF(Def,vox,bb,mat,M0,dm)
% Copy of portion of spm_deformations.m (lines 362 thru 508) to
% replicate how a deformation matrix of y = (519 519 255 3) is created
% from a deformation matrix of y0 = (121 145 121 3), where the latter is
% obtained from y_ea_normparams.nii and the former is needed to do the 
% address mapping for voxel volumes of the size
% of our original MRI image [anat.nii].
% -- Bill Kaemmerer, July 6, 2016
%
%
%   Def = the original deformation matrix (121 145 121 3)
%   vox = [0.22 0.22 0.22] = voxel size of Def from ???
%   bb  = [-55,45,9.5;55,-65,-25] == bounding box (of TPM.nii???)
%   mat = TBD 4x4 matrix == ???
%   M0  = TBD 4x4 matrix == read from NI.mat
%   dm  = first 3 dimensions for the deformation matrix to be produced
%   (519 519 255)
% 

% if ~isempty(NI.extras) && isstruct(NI.extras) && isfield(NI.extras,'mat')
%     M1 = NI.extras.mat;
%     if size(M1,3) >= j && sum(sum(M1(:,:,j).^2)) ~=0
%         M0 = M1(:,:,j);
%     end
% end

[mat0,dim] = spm_get_matdim('',vox,bb);

M   = inv(mat0);
y0  = affine(Def,M);  % see function below!
% Here, M0 should be [0.5 0 0 -130.5; etc.  -- OK !! ]
% Here, mat should be [-1.4991 -0.0521 -0.0069  94.5509; etc.  --- OK ]
M   = mat\M0;
% Resulting M should be [-0.33 -0.011 -0.0039  150.17; etc. --- OK ] 
% dm  = [size(NI.dat),1,1,1,1];
%         if ~all(dm(1:3)==odm) || ~all(M(:)==oM(:))
%             % Generate new deformation (if needed)

y   = zeros([dm(1:3),3],'single');
for d=1:3
    yd = y0(:,:,:,d);
    for x3=1:size(y,3)
        y(:,:,x3,d) = single(spm_slice_vol(yd,M*spm_matrix([0 0 x3]),dm(1:2),[1 NaN]));
    end
end

%         end
end

function Def = affine(y,M)
Def          = zeros(size(y),'single');
Def(:,:,:,1) = y(:,:,:,1)*M(1,1) + y(:,:,:,2)*M(1,2) + y(:,:,:,3)*M(1,3) + M(1,4);
Def(:,:,:,2) = y(:,:,:,1)*M(2,1) + y(:,:,:,2)*M(2,2) + y(:,:,:,3)*M(2,3) + M(2,4);
Def(:,:,:,3) = y(:,:,:,1)*M(3,1) + y(:,:,:,2)*M(3,2) + y(:,:,:,3)*M(3,3) + M(3,4);
end

