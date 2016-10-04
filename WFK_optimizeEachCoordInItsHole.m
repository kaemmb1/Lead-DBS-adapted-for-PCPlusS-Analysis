function [FinalCoordMM] = WFK_optimizeEachCoordInItsHole(C0z,C3z,Vtra,traj,wsize,markers,threshold)
% Refine the coordinates for the contacts by minimizing the sum of the
% voxel brightness values around the proposed coordinates.
%
% Get the approximate z coordinates to start.
%
gap = round((C0z-C3z)/3.0);
C1z = C0z - gap;
C2z = C1z - gap;
candidateCoords = zeros(4,3);
candidateCoords(1,3) = C0z;
candidateCoords(2,3) = C1z;
candidateCoords(3,3) = C2z;
candidateCoords(4,3) = C3z;
%
%  Use donut hole centroid to initialize the X and Y coordinates.
%
for c = 1:4
    Cz = candidateCoords(c,3);
    cursor = traj(Cz,:);
    mks=cursor;
    mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
    mks=mks(1:3,:)';
    % Get slice of lpostop_ct.nii at the cursor
    [slice,~,~] = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
    [aveRow,aveCol] = WFK_donutHoleCentroid(slice,threshold);
    candidateCoords(c,1) = round(aveRow);
    candidateCoords(c,2) = round(aveCol);
    % plot
    subplot(4,7,(c*7), 'align');
    axis on;
    axis square;
    imagesc(slice');
    xlabel(sprintf('Starting C%d',c-1));
    hold on;
    plot(aveRow,aveCol,'*','MarkerSize',10,'MarkerEdgeColor','red','LineWidth',1);
    pause on;
    pause(1.0); % pauses allow the work to be followed visually.
end;
%
%  Start by finding the sum of the pixel brightness values around the 
%  current candidate contact coordinates.
%
offset = zeros(4,3);
%
% Now try moving in each x,y,z direction, and see if we can do better (minimize further).
%
up       = zeros(4,3);       up(:,1) = -1;
down     = zeros(4,3);     down(:,1) =  1;
left     = zeros(4,3);     left(:,2) = -1;
right    = zeros(4,3);    right(:,2) =  1;
superior = zeros(4,3); superior(:,3) = -1;  
inferior = zeros(4,3); inferior(:,3) =  1; 
%
%  DO THE OPTIMIZATION FOR EACH CONTACT SEPARATELY  -- August 31, 2016 WFK
%
for c = 1:4
    Cz = candidateCoords(c,3);
    [sliceCurrent,sliceSuperior,sliceInferior] = getSlices(Cz,traj,markers,Vtra,wsize);
    % Display where we are now.
    Cx = candidateCoords(c,1);
    Cy = candidateCoords(c,2);
    subplot(4,7,(c*7)-1, 'align');
    axis on;
    axis square;
    imagesc(sliceCurrent');
    newCurrent = false;
    xlabel(sprintf('Optimizing C%d',c-1));
    hold on;
    plot(Cx,Cy,'*','MarkerSize',10,'MarkerEdgeColor','red','LineWidth',1);
    %  do the optimization for contact c
    contin = true;
    searchLimit = 100;  % set a limit just in case, to prevent infinite loop.
    numSearches = 0;
    minimumSumBrightness  = WFK_donutHoleBrightnessForContact(c,sliceCurrent,candidateCoords,offset);
    while contin && numSearches < searchLimit
        numSearches = numSearches + 1;
        % sumCurrent  = WFK_donutHoleBrightnessForContact(c,sliceCurrent, candidateCoords,offset);
        sumUp       = WFK_donutHoleBrightnessForContact(c,sliceCurrent, candidateCoords,up);
        sumDown     = WFK_donutHoleBrightnessForContact(c,sliceCurrent, candidateCoords,down);
        sumLeft     = WFK_donutHoleBrightnessForContact(c,sliceCurrent, candidateCoords,left);
        sumRight    = WFK_donutHoleBrightnessForContact(c,sliceCurrent, candidateCoords,right);
        sumSuperior = WFK_donutHoleBrightnessForContact(c,sliceSuperior,candidateCoords,superior);
        sumInferior = WFK_donutHoleBrightnessForContact(c,sliceInferior,candidateCoords,inferior);
        minSB = min([sumUp,sumDown,sumLeft,sumRight,sumSuperior,sumInferior]);
        if ~(minSB < minimumSumBrightness)
            % we DO NOT have a new minimum, time to quit.
            contin = false;
        else
            % we have a new minimum ...
            minimumSumBrightness = minSB;
            % ... which one determines what direction to move.
            if (minSB == sumUp)
                candidateCoords(c,1) = candidateCoords(c,1) - 1;
            elseif (minSB == sumDown)
                candidateCoords(c,1) = candidateCoords(c,1) + 1;
            elseif (minSB == sumLeft)
                candidateCoords(c,2) = candidateCoords(c,2) - 1;
            elseif (minSB == sumRight)
                candidateCoords(c,2) = candidateCoords(c,2) + 1;
            elseif (minSB == sumSuperior)
                candidateCoords(c,3) = candidateCoords(c,3) - 1;
                % update slices when we move superior 
                Cz = candidateCoords(c,3);
                [sliceCurrent,sliceSuperior,sliceInferior] = getSlices(Cz,traj,markers,Vtra,wsize);
                newCurrent = true;
            elseif (minSB == sumInferior)
                % update slices when we move inferior
                candidateCoords(c,3) = candidateCoords(c,3) + 1;
                Cz = candidateCoords(c,3);
                [sliceCurrent,sliceSuperior,sliceInferior] = getSlices(Cz,traj,markers,Vtra,wsize);
                newCurrent = true;
            end;
        end;
        % Display where we are now.
        Cx = candidateCoords(c,1);
        Cy = candidateCoords(c,2);
        % subplot(4,7,(c*7)-1, 'align');
        axis on;
        axis square;
        if newCurrent
            % need to update the image on the display
            imagesc(sliceCurrent');
            newCurrent = false;
        end;
        xlabel(sprintf('Optimizing C%d',c-1));
        hold on;
        plot(Cx,Cy,'.','MarkerSize',10,'MarkerEdgeColor','yellow','LineWidth',3);
        pause on;
        pause(0.75);
    end;
    % Display where we ended up for contact c.
    Cx = candidateCoords(c,1);
    Cy = candidateCoords(c,2);
    % subplot(4,7,(c*7)-1, 'align');
    axis on;
    axis square;
    imagesc(sliceCurrent');
    xlabel(sprintf('Final C%d',c-1));
    hold on;
    plot(Cx,Cy,'*','MarkerSize',10,'MarkerEdgeColor','cyan','LineWidth',1);
    pause on;
    pause(1.0);
end;
% Finally, convert the candidateCoord into mm coordinates.
FinalCoordMM = zeros(4,3);
for c = 1:4
    Cz = candidateCoords(c,3);
    cursor = traj(Cz,:);
    % Set cursor to a row of the trajectory
    FinalCoordMM(c,3) = cursor(3);
    mks=cursor;
    mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
    mks=mks(1:3,:)';
    % Get slice of lpostop_ct.nii at the cursor, for its boundingbox info
    [slice,boundbox,boundboxmm] = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
    % Where we ended up was on the transposed slice
    % so need to interchange x and y.
    Cx = candidateCoords(c,2); 
    Cy = candidateCoords(c,1); 
    
    % diagonal = (wsize*2)+1;
    % reflectedCy = diagonal + (diagonal - Cy);
    % reflectedCy = Cy;
    % Cy = Cx;
    % Cx = reflectedCy;

    % Now, convert to millimeters using the information in boundingboxmm.
    decodeX = boundboxmm{1,1};
    CxMM = decodeX(round(Cx));
    decodeY = boundboxmm{1,2};
    CyMM = decodeY(round(Cy));
    FinalCoordMM(c,1) = CxMM;
    FinalCoordMM(c,2) = CyMM;
    
%     % for DEBUGGING ONLY -- display slice again, has it moved?
%     Cx = candidateCoords(c,1);
%     Cy = candidateCoords(c,2);
%     subplot(4,7,(c*7)-1, 'align');
%     axis on;
%     axis square;
%     imagesc(slice');
%     xlabel(sprintf('Final final C%d',c-1));
%     hold on;
%     plot(Cx,Cy,'*','MarkerSize',10,'MarkerEdgeColor','cyan','LineWidth',1);
%     pause on;
%     
%     mks=FinalCoordMM(c,:);
%     mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
%     mks=mks(1:3,:)';
%     [slice2,boundbox2,boundboxmm2] = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
%     Cxxx = 33;
%     Cyyy = 33;
%     axis on;
%     axis square;
%     imagesc(slice2');
%     xlabel(sprintf('Final final final C%d',c-1));
%     hold on;
%     plot(Cxxx,Cyyy,'*','MarkerSize',10,'MarkerEdgeColor','cyan','LineWidth',1);
%     pause on;
%     % END OF CODE THAT WAS FOR DEBUGGING ONLY
    
end;
end

function [sliceCurrent,sliceSuperior,sliceInferior] = getSlices(Cz,traj,markers,Vtra,wsize)
    % get slice we are currently at
    cursor = traj(Cz,:);
    mks=cursor;
    mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
    mks=mks(1:3,:)';
    sliceCurrent = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
    % get slice if we move up the lead trajectory one voxel
    cursor = traj(Cz-1,:);
    mks=cursor;
    mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
    mks=mks(1:3,:)';
    sliceSuperior = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
    % get slice if we move down the lead trajectory one voxel
    cursor = traj(Cz+1,:);
    mks=cursor;
    mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
    mks=mks(1:3,:)';
    sliceInferior = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
end



