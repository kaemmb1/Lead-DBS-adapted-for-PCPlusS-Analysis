function matrixOut = WFK_backTranslate(matrixIn)
%
% A utility function I'm writing to understand how to
% use the deformation field files to convert voxel coordinates
% to and from the original patient coordinates to the MNI coordinate space.
%
global anatMat;
global mniMat;
global DEF;


% Translate from MNI Brain (millimeters) to mniVoxelIndex
mniBrainCoord = [mniX mniY mniZ 1]';
mniVoxelCoord = mniMat\mniBrainCoord;
x = mniVoxelCoord(1);
y = mniVoxelCoord(2);
z = mniVoxelCoord(3);

% Look up the voxel destination (through the warping) 
% using the deformation field

unwarpedX = DEF(x,y,z,1,1);
unwarpedY = DEF(x,y,z,1,2);
unwarpedZ = DEF(x,y,z,1,3);

% Translate from Brain (millimeters) to Voxel index
patientVoxelCoord = [unwarpedX unwarpedY unwarpedZ 1];
patientBrainCoord = patientVoxelCoord * anatMat;
patientXmm = patientBrainCoord(1);
patientYmm = patientBrainCoord(2);
patientZmm = patientBrainCoord(3);

end

