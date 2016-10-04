function vox=WFK_ea_mm2vox(mm, transform)
% converts mm-coordinates to voxel-coordinates
%
%  WFK_ea_mm2vox is a copy of ea_mm2vox so I can modify or at least add
%  comments to the code, as I figure out how to use it.
%     Bill Kaemmerer, August 23, 2016
%
%  mm = the 4x3 array of coordinates expressed as millimeters
%  transform = the full pathname of the image file for which the voxel
%  coordinates are desired, e.g., '....\lpost_op.nii'
%
if ischar(transform)
    transform = spm_get_space(transform);
end
    
transform = inv(transform);
vox = [mm, ones(size(mm,1),1)] * transform';
vox(:,4) = [];
vox = round(vox);


