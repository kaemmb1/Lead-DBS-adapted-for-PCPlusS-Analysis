function patientOut = WFK_backTranslate(mniIn)
%
% A utility function I'm writing to understand how to
% use the deformation field files to convert voxel coordinates
% to and from the original patient coordinates to the MNI coordinate space.
%
global anatMat;
global mniMat;
global DEF;

% Convert this from a loop over rows to just deal with matrices as a whole,
% later -- WFK

for r = 1:4
    
    % Translate from MNI Brain (millimeters) to mniVoxelIndex
    mniLoc(1,1) = mniIn(r,1);
    mniLoc(1,2) = mniIn(r,2);
    mniLoc(1,3) = mniIn(r,3);
    mniLoc(1,4) = 1;
    mniVoxelIndex = inv(mniMat)*mniLoc';
    x = mniVoxelIndex(1);
    y = mniVoxelIndex(2);
    z = mniVoxelIndex(3);
    ix = round(x);
    iy = round(y);
    iz = round(z);
    
    % Look up the voxel destination (through the warping)
    % using the deformation field
    
    unwarpedX = DEF(ix,iy,iz,1);
    unwarpedY = DEF(ix,iy,iz,2);
    unwarpedZ = DEF(ix,iy,iz,3);
    
    % Translate from Brain (millimeters) to Voxel index
    patientVoxelIndex = [unwarpedX unwarpedY unwarpedZ 1];
    patientBrainCoord = anatMat * patientVoxelIndex';
    
    patientOut(r,1) = patientBrainCoord(1);
    patientOut(r,2) = patientBrainCoord(2);
    patientOut(r,3) = patientBrainCoord(3);
    
end;

end

