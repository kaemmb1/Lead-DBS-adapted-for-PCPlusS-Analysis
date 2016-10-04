function [OK,coords] = WFK_findContactCoordsUsingTip(threshold,Vtra,traj,markers,LeadModel,handles,left)
%  Scan the lead trajectory from the distal region up the trajectory until
%  the apparent tip of the lead is found in the CT artifact.  Use this
%  location to calculate the contact coordinates for this lead.
switch LeadModel
    case {'Medtronic 3387'}
        tip_length = 1.50;
        tip_diameter = 1.27;
        contact_spacing = 1.50;
        contact_length = 1.50;
        eldist = 3.0;
    case {'Medtronic 3389'}
        tip_length = 1.50;
        tip_diameter = 1.27;
        contact_spacing = 0.50;
        contact_length = 1.50;
        eldist = 2.0;
    case {'Medtronic 3391'}
        tip_length = 1.50;
        tip_diameter = 1.27;
        contact_spacing = 4.00;
        contact_length = 3.00;
        eldist = 7.0;
    otherwise
        error('TBD -- need to put in elspec for other models of leads');
end;
pixSize = Vtra.mat(3,3); 
radiusInMM = tip_diameter/2.0; % MM radius of lead
radiusInPixels = radiusInMM / pixSize;
myPi = 3.14159265;
areaInPixels = (myPi * radiusInPixels * radiusInPixels);
areaThreshold = 0.75 * areaInPixels;
nRows = length(traj);
wsize = 16;  
zCoord = 0;
keepGoing = 0;
for row = nRows:-1:1
    cursor = traj(row,:);
    % Set cursor to a row of the trajectory
    mks=[cursor;  markers(1).tail;  markers(2).head;  markers(2).tail];
    mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
    mks=mks(1:3,:)';
    % Get slice of lpostop_ct.nii at the cursor
    [slice,~,boundboxmm] = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
    [area,centroidX,centroidY] = WFK_wholeArtifactArea(slice,threshold,left);
    % Stop as soon as the area is large enough to likely be the true
    % lead artifact, rather than just noise.
    pause(0.10);
    if (area > areaThreshold)
        % save the row (z coord) but continue for another several of rows
        % to get a better centroid for x and y
        if zCoord == 0
            zCoord = cursor(3);
        end;
        keepGoing = keepGoing + 1;
        if keepGoing > 5
            break;
        end;
    end;
end;
%
%  Next, need to convert the value of the row that broke us out of the
%  above loop into a coordinate, and then calculate a unit vector...
%
decodeX = boundboxmm{1,1};
decodeY = boundboxmm{1,2};
C0xMM = decodeX(round(centroidX));
C0yMM = decodeY(round(centroidY)); 
C0zMM = zCoord + tip_length + (contact_length/2.0);
Contact0Coordinates = [C0xMM, C0yMM, C0zMM];
% For display, get slice at the location of the C0
% mks=[Contact0Coordinates; markers(1).tail;  markers(2).head;  markers(2).tail];
% mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
% mks=mks(1:3,:)';
% slice = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
% subplot(4,5,15);
% cla;
% axis on;
% axis square;
% imagesc(slice);
% xlabel('Est. C0 loc based on lead tip.');
% hold on;
% x = size(slice,1);
% y = size(slice,2);
% plot(x/2,y/2,'rx');
%
%  Find another point on the lead artifact, by starting the slices from
%  the other (distal, near skull entry point) end.  Use this just to get
%  the trajectory's unit vector.
%
for row = floor(nRows/3):1:nRows
    cursor = traj(row,:);
    % Set cursor to a row of the trajectory
    mks=[cursor;  markers(1).tail;  markers(2).head;  markers(2).tail];
    mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
    mks=mks(1:3,:)';
    % Get slice of lpostop_ct.nii at the cursor
    [slice,~,boundboxmm] = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
    [area,centroidX,centroidY] = WFK_wholeArtifactArea(slice,threshold,left);
    % Stop as soon as the area is large enough to likely be the true
    % lead artifact, rather than just noise.
    pause(0.10);
    if (area > areaThreshold)
        break;
    end;
end;
decodeX = boundboxmm{1,1};
decodeY = boundboxmm{1,2};
C99xMM = decodeX(round(centroidX));
C99yMM = decodeY(round(centroidY)); 
C99zMM = cursor(3) + (contact_length/2.0);  % for consistency with C0zMM calc.
Contact99Coordinates = [C99xMM, C99yMM, C99zMM];
%
%  Finally, calculate the coordinates of C0, C1, C2, and C3 based on the
%  coordinate of the tip, the unit vector, and the known spacing of the
%  rings on the lead.
%
originalVector = Contact99Coordinates - Contact0Coordinates;
dist = sqrt(sum(originalVector .* originalVector));
unitVector = originalVector / dist;  
Contact1Coordinates = Contact0Coordinates + (eldist * unitVector);
Contact2Coordinates = Contact1Coordinates + (eldist * unitVector);
Contact3Coordinates = Contact2Coordinates + (eldist * unitVector);
coords = [Contact0Coordinates; ...
    Contact1Coordinates; Contact2Coordinates; Contact3Coordinates];
OK = true;
end

