function [ OK, coords ] = WFK_autoFindContactCoords(Vtra,traj,markers,LeadModel,handles,left)
% Find the coordinates of the contacts on the lead in the
% right or left hemisphere.
nRows = length(traj);
%  Scan all the slices to find the typical brightness and set
%  a threshold for converting the slices to binary images.
wsize = 16;
pause on;
for row = nRows:-1:1
    cursor = traj(row,:);
    % Set cursor to a row of the trajectory
    mks=[cursor;  markers(1).tail;  markers(2).head;  markers(2).tail];
    mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
    mks=mks(1:3,:)';
    % Get slice of lpostop_ct.nii at the cursor
    slice = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
    allSlices(:,:,row) = slice(:,:);
end;
threshold = max(max(max(allSlices)));
threshold = threshold * 0.40;
%
[OK1, coordsUsingHoles] = WFK_findContactCoordsUsingHoles(threshold,Vtra,traj,markers,LeadModel,handles,left);
OK2 = false;
if ~OK1
    % Only do the method of searching from the tip as a backup plan.
    [OK2, coordsByDistFromTip] = WFK_findContactCoordsUsingTip(threshold,Vtra,traj,markers,LeadModel,handles,left);
end;
if OK1
    coords = coordsUsingHoles;
else if OK2
        coords = coordsByDistFromTip;
    else
        coords = [];
    end;
end;
OK = OK1 | OK2;

