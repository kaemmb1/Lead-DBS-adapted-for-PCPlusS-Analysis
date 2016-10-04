function [OK,coords] = WFK_findContactCoordsUsingHoles(threshold,Vtra,traj,markers,LeadModel,handles,left)
%  Scan the cross-sections of the post-op CT image along the length of the
%  trajectory, looking for "donut holes."  Use peaks in the areas of the
%  donut holes to localize C0 and C3.
subplot(4,7, 7, 'align' ); axis off; cla;
subplot(4,7,14, 'align' ); axis off; cla;
subplot(4,7,21, 'align' ); axis off; cla;
subplot(4,7,28, 'align' ); axis off; cla;
subplot(4,7, 6, 'align' ); axis off; cla;
subplot(4,7,13, 'align' ); axis off; cla;
subplot(4,7,20, 'align' ); axis off; cla;
subplot(4,7,27, 'align' ); axis off; cla;
nRows = length(traj);
wsize = 16;
area = zeros(nRows,1);
for row = nRows:-1:1
    cursor = traj(row,:);
    % Set cursor to a row of the trajectory
    mks=[cursor;  markers(1).tail;  markers(2).head;  markers(2).tail];
    mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
    mks=mks(1:3,:)';
    % Get slice of lpostop_ct.nii at the cursor
    slice = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
    area(row) = WFK_donutHoleArea(slice,threshold,left);
    pause(0.05);
end;
peaks = WFK_findPeaks(area);
% subplot(4,5,5);  axis off; cla; axis square;
% subplot(4,5,10); axis off; cla; axis square;
% subplot(4,5,15); axis off; cla; axis square;
% subplot(4,5,20); axis off; cla; axis square;
C3z = peaks(1);
C0z = peaks(end);
% For model 3389, C3z and C0z should be about 30 slices apart 
% (6 mm at 0.22 mm per slice).
originalVector = abs(C3z - C0z);
pixSize = Vtra.mat(3,3); 
observedC0toC3DistInMM = originalVector * pixSize;
switch LeadModel
    case {'Medtronic 3391'}
        C3toC0distInMM = 21.0;  % 3 times the spacing
        spacingInMM = 7.0;  % contact length plus contact spacing
    case {'Medtronic 3387'}
        C3toC0distInMM = 9.0;
        spacingInMM = 3.0;
    case {'Medtronic 3389'}
        C3toC0distInMM = 6.0;
        spacingInMM = 2.0;
    otherwise
        error('TBD -- need to put in elspec for other models of leads');
end;
discrepancy = abs(C3toC0distInMM - observedC0toC3DistInMM);
if (discrepancy > spacingInMM * 2.0)
    set(handles.ProcessingStepText,'String','Auto contact placement failed.');
    coords = [];
    OK = false;
    return;
end;
%
%  Now that we are close, further optimize the coordinates by
%  minimizing the sum of the pixel values around the contact (i.e., to
%  put the contact at the most central part of the "hole."
%  (Clear the display areas before and afterwards).
clearDisplayAreas();
coords = WFK_optimizeEachCoordInItsHole(C0z,C3z,Vtra,traj,wsize,markers,threshold);
clearDisplayAreas();
OK = true;
end

function clearDisplayAreas()
subplot(4,7, 7, 'align' ); axis off; cla;
subplot(4,7,14, 'align' ); axis off; cla;
subplot(4,7,21, 'align' ); axis off; cla;
subplot(4,7,28, 'align' ); axis off; cla;
subplot(4,7, 6, 'align' ); axis off; cla;
subplot(4,7,13, 'align' ); axis off; cla;
subplot(4,7,20, 'align' ); axis off; cla;
subplot(4,7,27, 'align' ); axis off; cla;
end

