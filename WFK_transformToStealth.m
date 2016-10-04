function stealthCoord = WFK_transformToStealth(patientCoord)
% Rotate and translate patientCoord to yield stealthCoord, where
% the origin is at the midpoint of the AC-PC line, and the AC-PC line is
% co-linear with the y-axis.
%
global ACinPatientCoord;
global PCinPatientCoord;
MCinPatientCoord = (ACinPatientCoord + PCinPatientCoord)/2.0;
%
% Make translation part of transformation matrix, to translate
% the origin to the midpoint of the AC-PC line (MC).
%
T=makehgtform('translate',(-1*MCinPatientCoord));
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
zeroXAC = transAC * AR1';
zeroXMC = transMC * AR1';
%
CurrentVector = zeroXAC - zeroXMC ;
xrotatedegree =  -1 * atand(CurrentVector(3)/CurrentVector(2));
xrotateradians = xrotatedegree*pi/180;
AR2 = makehgtform('xrotate',xrotateradians);
zeroXZAC = zeroXAC * AR2';
zeroXZMC = zeroXMC * AR2';
%
CurrentVector = zeroXZAC - zeroXZMC ;
zrotatedegree =  atand(CurrentVector(1)/CurrentVector(2));
zrotateradians = zrotatedegree*pi/180;
AR3 = makehgtform('zrotate',zrotateradians);
%
% Compose the full translation and rotation matrix.
%
transformMatrix = T'*AR1'*AR2'*AR3';
%
%  Apply the transformation
%
nPoints = size(patientCoord,1);
homogPatientCoord = [patientCoord(:,:),ones(nPoints,1)];
homogStealthCoord = homogPatientCoord * transformMatrix;
stealthCoord = homogStealthCoord(:,1:3);
%
%  Treat very small absolute values (e.g., 1.0 e-14) as zero.
%
stealthCoord(abs(stealthCoord)<1.0e-14) = 0;
end

