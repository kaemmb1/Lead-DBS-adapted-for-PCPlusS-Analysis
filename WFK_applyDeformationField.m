function targetMM = WFK_applyDeformationField(srcMM,deformationFileName)
% Apply deformation field to translate a coordinate for a voxel in a source
% cooordinate system (in millimeters) to a corresponding coordinate for a voxel in the
% target coordinate system (in millimeters), given the deformation field found in the nifti
% file with full file name transformFileName.
%
%   srcMM should be an Npoints by 3 matrix where each row is an x,y,z point.
%
% To get patient coordinates from MNI coordinates, use y_ea_normparams as
% the transformation file name (NOT y_ea_inv_normparams).
%
%   Bill Kaemmerer, August 24, 2016
%
%  Code is modeled after spm_swarp.m and a description of the use of 
%  distortion fields in the MATLAB Image Processing Toolbox.tar
%
def = nifti(deformationFileName);
y = def(1).dat(:,:,:,:,:);
M = def(1).mat;
iM = inv(M);
nPoints = size(srcMM,1);
v = iM(1:3,1:4) * [srcMM'; ones(1,nPoints)];
targetVoxel = zeros(nPoints,3);
for p = 1:nPoints
    vx = v(1,p);
    vy = v(2,p);
    vz = v(3,p);
    
    vxFloor = floor(vx);
    vyFloor = floor(vy);
    vzFloor = floor(vz);
    y1Floor = y(vxFloor,vyFloor,vzFloor,:,1);
    y2Floor = y(vxFloor,vyFloor,vzFloor,:,2);
    y3Floor = y(vxFloor,vyFloor,vzFloor,:,3);
    
    vxCeil = ceil(vx);
    vyCeil = ceil(vy);
    vzCeil = ceil(vz);
    y1Ceil = y(vxCeil,vyCeil,vzCeil,:,1);
    y2Ceil = y(vxCeil,vyCeil,vzCeil,:,2);
    y3Ceil = y(vxCeil,vyCeil,vzCeil,:,3);
    
    % Now interpolate between floor and ceiling points.
    vxFraction = vx - vxFloor;
    vyFraction = vy - vyFloor;
    vzFraction = vz - vzFloor;
    
    targetVoxel(p,1) = y1Floor + (vxFraction * (y1Ceil - y1Floor));
    targetVoxel(p,2) = y2Floor + (vyFraction * (y2Ceil - y2Floor)); 
    targetVoxel(p,3) = y3Floor + (vzFraction * (y3Ceil - y3Floor));
end;

targetMM = targetVoxel;


