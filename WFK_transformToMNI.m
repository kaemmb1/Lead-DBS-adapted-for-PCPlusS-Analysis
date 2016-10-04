function patientCoord = WFK_transformToMNI(stealthCoord)
% As the first step in transforming stealth coordinates to MNI coordinates,
% rotate and translate stealthCoord to yield patientCoord, where
% the origin is at the AC, and the AC-PC line is
% co-linear with the AC and PC coordinates in the template.
% 
% Note that in the template, the AC is at: [ 0.250   1.298 -5.003]
% and the PC is at:  [-0.188 -24.756 -2.376]
%
global ACinStealthCoord;
global PCinStealthCoord;
global ACinPatientCoord;
global PCinPatientCoord;
MCinPatientCoord = (ACinPatientCoord + PCinPatientCoord)/2.0;
%
% Make translation part of transformation matrix, to translate
% the origin to the midpoint of the AC-PC line (MC).  The opposite
% transformation moves the origin from MC to AC.
%
T=makehgtform('translate',(-1*MCinPatientCoord));
oppositeT = makehgtform('translate',(+1*MCinPatientCoord));
%
%  The following code computes the rotations needed to get from
%  AC and PC in PatientCoord (MNI space) to AC and PC in Stealth Coord,
% (see the code in WFK_transformToStealth.m) and then computes the
%  opposite rotations, and applies them in reverse order.
%
%  Now rotate to zero out the X and Z coordinates in the AC-PC line.
%
transAC = [ACinPatientCoord,1] * T';
transMC = [MCinPatientCoord,1] * T';
% transPC = [PCinPatientCoord,1] * T';
CurrentVector = transAC - transMC;
xrotatedegree = -1 * atand(CurrentVector(1)/CurrentVector(3));
xrotateradians = xrotatedegree*pi/180;
AR1 = makehgtform('xrotate',xrotateradians);
oppositeXRotateRadians = -1 * xrotateradians;
oppositeAR1 = makehgtform('xrotate',oppositeXRotateRadians);
zeroXAC = transAC * AR1';
zeroXMC = transMC * AR1';
%
CurrentVector = zeroXAC - zeroXMC ;
xrotatedegree =  -1 * atand(CurrentVector(3)/CurrentVector(2));
xrotateradians = xrotatedegree*pi/180;
AR2 = makehgtform('xrotate',xrotateradians);
oppositeXRotateRadians = -1 * xrotateradians;
oppositeAR2 = makehgtform('xrotate',oppositeXRotateRadians);
zeroXZAC = zeroXAC * AR2';
zeroXZMC = zeroXMC * AR2';
%
CurrentVector = zeroXZAC - zeroXZMC ;
zrotatedegree =  atand(CurrentVector(1)/CurrentVector(2));
zrotateradians = zrotatedegree*pi/180;
AR3 = makehgtform('zrotate',zrotateradians);
oppositeZRotateRadians = -1 * zrotateradians;
oppositeAR3 = makehgtform('zrotate',oppositeZRotateRadians);
%
% Compose the full roation and translation matrix (applying the
% rotations in the reverse order compared to WFK_transformToStealth.m.
%
transformMatrix = oppositeAR3'*oppositeAR2'*oppositeAR1'*oppositeT';
%
% NOTE:  We know the transformation is correct when applying
% the transformMatrix to ACinStealthCoordinates yields
% ACinPatientCoordinates, and similarly, applying the transformMatrix to
% PCinStealthCoordiantes yields PCinPatientCoordinates, as follows:
%
% ComputedACinPatientCoord = [ACinStealthCoord,1] * transformMatrix;
% such that ComputedACinPatientCoord == [ACinPatientCoord,1];
%  --- AND --- 
% ComputedPCinPatientCoord = [PCinStealthCoord,1] * transformMatrix;
% such that ComputedPCinPatientCoord == [PCinPatientCoord,1];
%
%  Apply the transformation to stealthCoord to get patientCoord 
% (in MNI space).  The latter still need to be passed through the
% patient's inverse deformation field to get to the final MNICoord 
% for this patient.
%
nPoints = size(stealthCoord,1);
homogStealthCoord = [stealthCoord(:,:),ones(nPoints,1)];
homogPatientCoord = homogStealthCoord * transformMatrix;
patientCoord = homogPatientCoord(:,1:3);
%
%  Treat very small absolute values (e.g., 1.0 e-14) as zero.
%
patientCoord(abs(patientCoord)<1.0e-14) = 0;
end

