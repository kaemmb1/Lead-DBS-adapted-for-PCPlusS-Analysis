function WFK_displayCoordinatesOnSlices(handles)
% Take the contact coordinates from the data tables of the GUI,
% and use them to display the corresponding slices of the lpostop_ct
% image on the right side of the GUI.
global outDirectory;
global LeftLeadModel;
global RightLeadModel;
% First, clear the right side of the GUI.
colormap gray;
subplot(4,5, 5); axis off; cla;
subplot(4,5,10); axis off; cla;
subplot(4,5,15); axis off; cla;
subplot(4,5,20); axis off; cla;


% Get lpostop_ct.nii loaded
fileName = strcat(outDirectory,'\','lpostop_ct.nii');
Vtra=spm_vol(fileName);
% Get markers from file.
[outRoot,patientName,~] = fileparts(outDirectory);
outRoot = strcat(outRoot,'\');
options.root = outRoot;
options.patientname = patientName;
options.native = 0;
% eaReconstructionFile = strcat(outDirectory,'\','ea_reconstruction.mat');
% load(eaReconstructionFile);
[coords_mm,trajectory,markers,elmodel,manually_corrected]=ea_load_reconstruction(options);

wsize = 16;

% Find and display the slides corresponding to the LEFT contacts.
if ~strcmp(LeftLeadModel,'None');
    coordinates = get(handles.LeftContactCoordinatesTable,'Data');
    %
    % DEBUGGING -- DO MARKERS EVEN MATTER???
    %
    markers(1).tail = [0 0 0];
    markers(2).head = [0 0 0];
    markers(2).tail = [0 0 0];
    % END OF DEBUGGING CODE
    for c = 1:4
        coord = coordinates(c,:);
        mks=[coord];
        mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
        mks=mks(1:3,:)';
        [slice,boundbox,boundboxmm,~]= ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
        subplot(4,7,(c*7)-1, 'align');
        axis on;
        axis square;
        imagesc(slice');
        xlabel(sprintf('Left C%d',c-1));
        hold on;
%         coordXinMM = coordinates(c,1);
%         coordYinMM = coordinates(c,2);
%         possibleXMM = boundboxmm{1,1},
%         possibleYMM = boundboxmm{1,2};
%         xCoord = find(possibleXMM==coordXinMM);
%         yCoord = find(possibleYMM==coordYinMM);
        plot((wsize*2)+1,(wsize*2)+1,'*','MarkerSize',10,'MarkerEdgeColor','cyan','LineWidth',1);
    end;
end;

% Find and display the slides corresponding to the RIGHT contacts.
if ~strcmp(RightLeadModel,'None');
    coordinates = get(handles.RightContactCoordinatesTable,'Data');
    for c = 1:4
        coord = coordinates(c,:);
        mks=[coord];
        mks=Vtra.mat\[mks,ones(size(mks,1),1)]';
        mks=mks(1:3,:)';
        slice = ea_sample_slice(Vtra,'tra',wsize,'vox',mks,1);
        subplot(4,7,c*7, 'align');
        axis on;
        axis square;
        imagesc(slice');
        xlabel(sprintf('Right C%d',c-1));
        hold on;
        plot((wsize*2)+1,(wsize*2)+1,'*','MarkerSize',10,'MarkerEdgeColor','magenta','LineWidth',1);
    end;
end;


end

