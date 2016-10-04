function y = WFK_preparePullDEF(Def,mat)  % vox,bb,mat,M0,dm)
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
%   mat = TBD 4x4 matrix == ???
% 
global outDirectory;
FN = strcat(outDirectory,'\','anat.nii'); % TBD
NI = ea_load_nii(FN);
M0 = NI.mat;
M = inv(M0);
y0 = affine(Def,M);

M   = mat\M0;
dm  = [size(NI.private.dat),1,1,1,1];

y   = zeros([dm(1:3),3],'single');
for d=1:3
    yd = y0(:,:,:,d);
    for x3=1:size(y,3)
        y(:,:,x3,d) = single(spm_slice_vol(yd,M*spm_matrix([0 0 x3]),dm(1:2),[1 NaN]));
    end
end;

end

function Def = affine(y,M)
Def          = zeros(size(y),'single');
Def(:,:,:,1) = y(:,:,:,1)*M(1,1) + y(:,:,:,2)*M(1,2) + y(:,:,:,3)*M(1,3) + M(1,4);
Def(:,:,:,2) = y(:,:,:,1)*M(2,1) + y(:,:,:,2)*M(2,2) + y(:,:,:,3)*M(2,3) + M(2,4);
Def(:,:,:,3) = y(:,:,:,1)*M(3,1) + y(:,:,:,2)*M(3,2) + y(:,:,:,3)*M(3,3) + M(3,4);
end

