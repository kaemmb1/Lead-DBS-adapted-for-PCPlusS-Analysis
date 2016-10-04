function [trajectory,trajvector]=WFK_ea_reconstruct_trajectory(priortrajectory,tra_nii,side,refine,options)
% __________________________________________________________________________________
% Copyright (C) 2014 Charite University Medicine Berlin, Movement Disorders Unit
% Andreas Horn
options.endtolerance = 10; % WFK added August 8, 2016
if options.modality==2 % CT support
    tra_nii.img=tra_nii.img*-1;
end


%Vtra=spm_vol([options.root,patientname,filesep,patientname,'_tra_brain_A3_final.nii']);
slice=zeros(size(tra_nii.img,1),size(tra_nii.img,2));
masknii=tra_nii;
if side==1
    if options.verbose>1; progressfig=figure('name','Finding left electrode','NumberTitle','off','Menubar','none','ToolBar','none'); set(gcf,'color','w'); axis off; end
else
    if options.verbose>1; progressfig=figure('name','Finding right electrode','NumberTitle','off','Menubar','none','ToolBar','none'); set(gcf,'color','w'); axis off; end
end

%  set(progressfig,'KeyPressFcn',@ea_keystr);  -- WFK commented out.  July
%  28, 2016

%maximize(progressfig)
if options.verbose>1; colormap(gray); end
endcount=0;
nanflag=0;


% determine startslice at ~ z=8.7mm
mmpt=[0;0;8.7;1];
mmvx=tra_nii.mat\mmpt;
startslice=round(mmvx(3)); 
clear mmpt mmvx



if ~refine % if this is not a refine-run but an initial run, mask of first slice has to be defined heuristically.
    % define initial mask
    mask=zeros(size(slice,1),size(slice,2));
    
    switch options.entrypoint
        case 'STN, GPi or ViM'
            mask(200:350,70:220)=1;
            if side==1
                mask=fliplr(mask);
            end
        case 'Cg25'
            mask(390:490,270:370)=1;
            if side==1
                mask=fliplr(mask);
            end
        case 'Manual'
            
            colormask=zeros(size(slice,1),size(slice,2),3);
            colormask(:,:,1)=1;
            mask(200:350,70:220)=1;
            if side==1
                mask=fliplr(mask);
            end
            slice=double(tra_nii.img(:,:,startslice))'; % extract the correct slice.
            %slice=fliplr(slice);
            slice(slice==0)=nan;
            mn=figure('color','w','ToolBar','none','NumberTitle','off','Menubar','none','name','Please specify manual starting point.'); imagesc(slice); colormap gray;
            hold on
            cof=imshow(colormask);
            set(cof, 'AlphaData', mask*0.3)
            [X,Y]=ginput(1);
            close(mn);
            % reset mask from mouse input
            
            mask=zeros(size(slice,1),size(slice,2));
            
            mask(Y-10:Y+10,X-10:X+10)=1;
    end
    
    
    % initialize slice. mean average for entrypoint over the first 4 slices.
    slice=zeros(size(mask,1),size(mask,2),4);
    slicebw=zeros(size(mask,1),size(mask,2),4);
    for i=10:14
        [slice(:,:,i),slicebw(:,:,i)]=ea_prepare_slice(tra_nii,mask,1,startslice-(i-1),options);
    end
    slice=mean(slice,3);
    slicebw=logical(mean(slicebw,3));
    slicebw=ea_centralcomponent(slicebw,mask,options);
    
    
    
    %keyboard % here to analyse initial slice.
    
    
    
    
    stats=ea_centroid(slicebw);
    
    try
        isempty(stats.Centroid); % this is only to check if stats.Centroid is empty.
        centerline(1,:)=[stats.Centroid,startslice];
    catch
        
        disp('Threshold too high?');
    end
    
    
end


Vmat=nii2Vmat(tra_nii);
zfifteen=Vmat\[0;0;-15.5;1];


%% starting slice 2:end



for sliceno=2:startslice % sliceno is the counter (how many slices have been processed).
    % uncomment the following two lines to write out slice views.
    %imwrite(((reshape(slice(logical(mask)),sqrt(numel(find(mask))),sqrt(numel(find(mask)))))-min(slice(:)))/(max(slice(:)-min(slice(:)))),['slice_',num2str(sliceno),'.png']);
    %imwrite(reshape(slicebw(logical(mask)),sqrt(numel(find(mask))),sqrt(numel(find(mask)))),['slicebw_',num2str(sliceno),'.png']);
    
    if refine
        centerline(1,:)=priortrajectory(1,:); % define initial point and mask for this run.
        mask=zeros(size(slice,1),size(slice,2));
        try
            estpoint=priortrajectory(sliceno,:); % overwrite estpoint defined at the end of the loop if priortrajectory is defined.
        catch
            break
        end
        
        mask(round(estpoint(2)-options.maskwindow):round(estpoint(2)+options.maskwindow),round(estpoint(1)-options.maskwindow):round(estpoint(1)+options.maskwindow))=1;
    end
    
    
    imgsliceno=startslice-(sliceno-1); % imgsliceno is the slice number in the image.
    
    
    if imgsliceno<zfifteen(3) && ~strcmp(options.entrypoint,'Cg25')
        ea_showdis('Lower than z=-15.5 mm. Stopping.',options.verbose);
        break
    end
    
    %% loop over each slice to find the electrode trajectory.
    %% part 1: finding the electrode on the current slice.
    %-------------------------------------------------------------------------------------------------%
    
    
    
    
    
    
    
    
    if options.verbose>1; ea_setfocus(progressfig); subplot(3,3,1); axis off; end
    
    
    % the following function will return the slice and a bw copy of the
    % slice.
    [slice,slicebw,maskslice,maskslicebw]=ea_prepare_slice(tra_nii,mask,sliceno,imgsliceno,options);
    
    if isempty(find(slicebw, 1)) % -> slice is not empty
    end
    
    
    
    % slice is always the raw current slice.
    
    if options.verbose>1; ea_setfocus(progressfig); colormap(gray); end
    if options.verbose>1; ea_setfocus(progressfig); imagesc(slice); end
    if options.verbose>1; ea_setfocus(progressfig); colormap(gray); end
    if options.verbose>1; ea_setfocus(progressfig); axis square; end
    
    
    
    
    
    %% part 2: check whether the new point is plausible.
    %-------------------------------------------------------------------------------------------------%
    
    
    % the following function will use midpoint from the
    % last iteration to determine the distance to the new
    % one and will output the new midpoint.
    
    % check if estpoint has been defined
    
    
    
    
    
    
    if exist('estpoint','var')
        
        % this function will return one midpoint from the slice. If there are
        % more objects, it will return the midpoint of the one closest to the
        % estimated one.
        [numidpoint,greymaskslicebw,options]=ea_findonemidpoint(slicebw,estpoint(1:2),mask,options);
        if isnan(numidpoint)
            ea_showdis(['Midpoint is nan. Stopping.'],options.verbose);
            
            break
        end
        
        if WFK_pdist([estpoint;[numidpoint,imgsliceno]])<15-maxthree(refine)
            centerline(sliceno,:)=[numidpoint,imgsliceno];
            %ea_showdis(['Empirical Midpoint seems to be ',num2str([numidpoint,imgsliceno]),'.'],options.verbose);
            %ea_showdis(['New Midpoint found. Distance is ',num2str(WFK_pdist([estpoint;[numidpoint,imgsliceno]])),'.'],options.verbose);
        else
            
            endcount=endcount+1;
            if endcount==options.endtolerance
                ea_showdis(['Too many interpolations. Stopping.'],options.verbose);
                
                break
            end
            centerline(sliceno,:)=estpoint;
            
            %ea_showdis(['No new Midpoint found. Distance is ',num2str(WFK_pdist([estpoint;[numidpoint,imgsliceno]])),'. Interpolating.'],options.verbose);
            
        end
        
    else
        ea_showdis('Estimated point not yet defined. Using second empirical point.',options.verbose);
        numidpoint=ea_findonemidpoint(slicebw,centerline(1,1:2),mask,options);
        
        centerline(sliceno,:)=[numidpoint,imgsliceno];
        if isnan(centerline)
            ea_error('Reconstruction failed. Please choose "manual" entrypoint.');
        end
    end
    
    
    
    
    
    
    endnow = [];  % WFK July 28, 2016
    %  endnow=getappdata(progressfig,'endnow');
    if ~isempty(endnow)
        if endnow
            ea_showdis('User pressed space, stopping.',options.verbose);
            break
        end
    end
    
    
    
    
    
    
    
    
    
    
    
    %% part 3: update parameters for next run...
    %-------------------------------------------------------------------------------------------------%
    
    
    
    
    % this function estimates a fitted line and the following point based on the last points.
    
    [trajectory,trajvector,estpoint]=WFK_ea_fit_line(centerline);
    %ea_showdis(['Next point was estimated to be ',num2str(estpoint),'.'],options.verbose);
    % update mask
    mask=zeros(size(slice,1),size(slice,2));
    
    
    if round(estpoint(2)-options.maskwindow)<0 || round(estpoint(2)+options.maskwindow)>500 || round(estpoint(1)-options.maskwindow)<0 || round(estpoint(1)+options.maskwindow)>500
        close(progressfig)
        ea_error('Mask out of bounds. Must have lost trajectory. Try iterating with a different maskwindow again.');
        
        return
        %pause
    end
    
    mask(round(estpoint(2)-options.maskwindow):round(estpoint(2)+options.maskwindow),round(estpoint(1)-options.maskwindow):round(estpoint(1)+options.maskwindow))=1;

    
    
    %% part 4: visualization...
    %-------------------------------------------------------------------%
    
    if options.verbose>1; ea_setfocus(progressfig); subplot(3,3,2); axis off; end
    if options.verbose>1; ea_setfocus(progressfig); imagesc(mask); end
    if options.verbose>1; ea_setfocus(progressfig); axis square; end
    
    if options.verbose>1; ea_setfocus(progressfig); subplot(3,3,3); axis off; end
    if options.verbose>1; ea_setfocus(progressfig); imagesc(slicebw); end
    if options.verbose>1; ea_setfocus(progressfig); axis square; end
    
    
    if options.verbose>1; ea_setfocus(progressfig); subplot(3,3,4); axis off; end
    
    if options.verbose>1; ea_setfocus(progressfig); imagesc(maskslice); end
    if options.verbose>1; ea_setfocus(progressfig); axis square; end
    
    if options.verbose>1; ea_setfocus(progressfig); subplot(3,3,5); axis off; end
    if options.verbose>1; ea_setfocus(progressfig); imagesc(maskslicebw); end
    if options.verbose>1; ea_setfocus(progressfig); axis square; end
    
    
    if exist('greymaskslicebw','var')
        if ~isnan(greymaskslicebw)
            if options.verbose>1; ea_setfocus(progressfig); subplot(3,3,6); axis off; end
            if options.verbose>1; ea_setfocus(progressfig); imagesc(greymaskslicebw); end
            if options.verbose>1; ea_setfocus(progressfig); axis square; end
        end
    else
        if options.verbose>1; ea_setfocus(progressfig); subplot(3,3,6); axis off; end
        if options.verbose>1; ea_setfocus(progressfig); imagesc(zeros(10)); end
        if options.verbose>1; ea_setfocus(progressfig); axis square; end
    end
    
    
    
    
    
    
    
    
    if options.verbose>1; ea_setfocus(progressfig); subplot(3,3,7:9); end
    
    
    if options.verbose>1; ea_setfocus(progressfig); plot3(centerline(:,1),centerline(:,2),centerline(:,3)); hold on; plot3(centerline(1,1),centerline(1,2),centerline(1,3),'*g'); hold off; end
    
    
    if options.verbose>1; ea_setfocus(progressfig); hold on; plot3(trajectory(:,1),trajectory(:,2),trajectory(:,3),'r'); hold off; end
    
    if options.verbose>1; ea_setfocus(progressfig); drawnow; end
    
    
    
    
    
end

if options.verbose>2; close(progressfig); end



function ea_setfocus(progressfig)
try
    set(0,'CurrentFigure',progressfig)
catch
    ea_error('Please do not close the progress figure during reconstruction.')
end

function ea_keystr(progressfig,event)
commnd=event.Character;
switch lower(commnd)
    case ' '
        setappdata(progressfig,'endnow',1);        
end


function Vmat=nii2Vmat(nii)
Vmat=zeros(4);
Vmat(1,:)=nii.hdr.hist.srow_x-[0,0,0,nii.hdr.dime.pixdim(2)];
Vmat(2,:)=nii.hdr.hist.srow_y-[0,0,0,nii.hdr.dime.pixdim(3)];
Vmat(3,:)=nii.hdr.hist.srow_z-[0,0,0,nii.hdr.dime.pixdim(4)];
Vmat(4,:)=[0,0,0,1];

function output=maxthree(refine) % simply returns maximally four
output=refine;
if output>3; output=3; end