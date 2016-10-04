function WFK_ea_show_ctcoregistration(fig)
% __________________________________________________________________________________
% Copyright (C) 2014 Charite University Medicine Berlin, Movement Disorders Unit
% Andreas Horn
%
% Fragment of original ea_show_ctcoregistration function adapted for
% Seeking Beta project, June 22, 2016
%    -- Bill Kaemmerer (WFK)
%
global outDirectory; 
[outRoot,patientName,~] = fileparts(outDirectory);
outRoot = strcat(outRoot,'\');
options.root = outRoot;
options.patientname = patientName;
options.prefs.patientdir = patientName;
options.prefs.ctnii_coregistered = 'rpostop_ct.nii';
options.prefs.prenii_unnormalized = 'anat.nii';
ct=ea_load_nii([options.root,options.patientname,filesep,options.prefs.ctnii_coregistered]);
mr=ea_load_nii([options.root,options.prefs.patientdir,filesep,options.prefs.prenii_unnormalized]);

    if ~isequal(size(mr.img),size(ct.img))
        matlabbatch{1}.spm.util.imcalc.input = {[options.root,options.prefs.patientdir,filesep,options.prefs.prenii_unnormalized];
            [options.root,options.patientname,filesep,options.prefs.ctnii_coregistered]};
        matlabbatch{1}.spm.util.imcalc.output = [options.prefs.ctnii_coregistered];
        matlabbatch{1}.spm.util.imcalc.outdir = {[options.root,options.prefs.patientdir,filesep]};
        matlabbatch{1}.spm.util.imcalc.expression = ['i2'];
        matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
        matlabbatch{1}.spm.util.imcalc.options.mask = 0;
        matlabbatch{1}.spm.util.imcalc.options.interp = 1;
        matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
        jobs{1}=matlabbatch;
        spm_jobman('run',jobs);
        clear matlabbatch jobs;
        ct=ea_load_nii([options.root,options.patientname,filesep,options.prefs.ctnii_coregistered]);
    end


ct.img(:)=ea_nanzscore(ct.img(:));  % zscore changed to ea_nanzscore WFK Aug 1,2016
mr.img(:)=ea_nanzscore(mr.img(:));  % zscore changed to ea_nanzscore WFK Aug 1,2016
jim=cat(4,mr.img,ct.img,mean(cat(4,mr.img,ct.img),4));
WFK_ea_imshowpair(jim,options,'Preoperative MRI (pink) & Postoperative CT (green)',fig);

% elseif legacy
% % export wireframe of CT:
% disp('Generating wireframe from CT image...');
% if ~exist('edge.m','file')
%     disp('Image toolbox not found, using a slower replacement function...');
%     ea_reslice_nii([options.root,options.patientname,filesep,options.prefs.ctnii_coregistered],[options.root,options.patientname,filesep,'small_',options.prefs.ctnii_coregistered],[2 2 2],0);
%     CT=load_nii_proxi([options.root,options.patientname,filesep,'small_',options.prefs.ctnii_coregistered]);
%     useimtbx=0;
%     alpha=0.01;
% else % use image toolbox
%     CT=load_nii_proxi([options.root,options.patientname,filesep,options.prefs.ctnii_coregistered]);
%     useimtbx=1;
%     alpha=0.1;
% end
% 
% %delete([options.root,options.patientname,filesep,'small_',options.prefs.ctnii_coregistered]);
% 
% %disp('Done. Smoothing...');
% CT.img(CT.img<0)=0; % remove negative hounsfield parts.
% %CT.img=smooth3(CT.img,'gaussian',[11 11 11]);
% 
% 
% eCT=logical(ea_detect_edges_3d(CT.img,alpha,useimtbx));
% 
% CT.hdr.fname=[options.root,options.patientname,filesep,'wires_',options.prefs.ctnii_coregistered];
% CT.hdr.dt=[4,0];
% spm_write_vol(CT.hdr,eCT);
% 
% disp('Done. Fusing images...');
% 
% checkf=[options.root,options.prefs.patientdir,filesep,options.prefs.prenii_unnormalized,',1'];
% 
% nii=ea_load_nii([options.root,options.prefs.patientdir,filesep,options.prefs.prenii_unnormalized]);
% dims=nii.hdr.dime.pixdim(2:4);
% outf=['check_coregct_',options.prefs.prenii_unnormalized];
% 
% suff='_pre_tra';
% 
% 
% matlabbatch{1}.spm.util.imcalc.input = {checkf;
%     [options.root,options.patientname,filesep,'wires_',options.prefs.ctnii_coregistered,',1']
%     };
% matlabbatch{1}.spm.util.imcalc.output = outf;
% matlabbatch{1}.spm.util.imcalc.outdir = {[options.root,options.prefs.patientdir,filesep]};
% matlabbatch{1}.spm.util.imcalc.expression = ['i1+1000*i2'];
% matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
% matlabbatch{1}.spm.util.imcalc.options.mask = 0;
% matlabbatch{1}.spm.util.imcalc.options.interp = 1;
% matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
% jobs{1}=matlabbatch;
% cfg_util('run',jobs);
% clear matlabbatch jobs;
% 
% disp('Done. Showing results.');
% nii=load_untouch_nii([options.root,options.prefs.patientdir,filesep,outf]);
% 
% h1=figure('name',['Coregistration (CT+MR) results for ',options.prefs.patientdir,'_',outf],'NumberTitle','off');
% set(gcf,'color','w')
% imagesc(scale_image(squeeze(nii.img(:,:,round(end/2)))',[dims(1)/dims(2),1]));
% axis('equal')
% axis('off')
% axis xy
% colormap gray
% tightfig;
% 
% 
% h2=figure('name',['Coregistration (CT+MR) results for ',options.prefs.patientdir,'_',outf],'NumberTitle','off');
% try
% imat=scale_image(squeeze(nii.img(:,round(end/2),:))',[dims(3)/dims(1),1]);
% catch
%     ea_error('Image seems to have wrong orientation');
% end
% imagesc(imat);
% axis('equal')
% axis('off')
% axis xy
% colormap gray
% tightfig;
% 
% 
% h3=figure('name',['Coregistration (CT+MR) results for ',options.prefs.patientdir,'_',outf],'NumberTitle','off');
% imat=scale_image(squeeze(nii.img(round(end/2),:,:))',[dims(3)/dims(2),1]);
% imagesc(imat);
% axis('equal')
% axis('off')
% axis xy
% colormap gray
% tightfig;
% 
% saveas(h1,[options.root,options.prefs.patientdir,filesep,'ctmrcoreg_check',suff,'_d1.png']);
% saveas(h2,[options.root,options.prefs.patientdir,filesep,'ctmrcoreg_check',suff,'_d2.png']);
% saveas(h3,[options.root,options.prefs.patientdir,filesep,'ctmrcoreg_check',suff,'_d3.png']);
% 


% end


% 
% 
% function hfig = tightfig(hfig)
% 
% % Copyright (c) 2011, Richard Crozier
% % All rights reserved.
% %
% % Redistribution and use in source and binary forms, with or without
% % modification, are permitted provided that the following conditions are
% % met:
% %
% %     * Redistributions of source code must retain the above copyright
% %       notice, this list of conditions and the following disclaimer.
% %     * Redistributions in binary form must reproduce the above copyright
% %       notice, this list of conditions and the following disclaimer in
% %       the documentation and/or other materials provided with the distribution
% %
% % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% % AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% % IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% % ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% % LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% % CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% % SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% % INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% % CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% % ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% % POSSIBILITY OF SUCH DAMAGE.
% % tightfig: Alters a figure so that it has the minimum size necessary to
% % enclose all axes in the figure without excess space around them.
% %
% % Note that tightfig will expand the figure to completely encompass all
% % axes if necessary. If any 3D axes are present which have been zoomed,
% % tightfig will produce an error, as these cannot easily be dealt with.
% %
% % hfig - handle to figure, if not supplied, the current figure will be used
% % instead.
% 
% if nargin == 0
%     hfig = gcf;
% end
% 
% % There can be an issue with tightfig when the user has been modifying
% % the contnts manually, the code below is an attempt to resolve this,
% % but it has not yet been satisfactorily fixed
% %     origwindowstyle = get(hfig, 'WindowStyle');
% set(hfig, 'WindowStyle', 'normal');
% 
% % 1 point is 0.3528 mm for future use
% 
% % get all the axes handles note this will also fetch legends and
% % colorbars as well
% hax = findall(hfig, 'type', 'axes');
% 
% % get the original axes units, so we can change and reset these again
% % later
% origaxunits = get(hax, 'Units');
% 
% % change the axes units to cm
% set(hax, 'Units', 'centimeters');
% 
% % get various position parameters of the axes
% if numel(hax) > 1
%     %         fsize = cell2mat(get(hax, 'FontSize'));
%     ti = cell2mat(get(hax,'TightInset'));
%     pos = cell2mat(get(hax, 'Position'));
% else
%     %         fsize = get(hax, 'FontSize');
%     ti = get(hax,'TightInset');
%     pos = get(hax, 'Position');
% end
% 
% % ensure very tiny border so outer box always appears
% ti(ti < 0.1) = 0.15;
% 
% % we will check if any 3d axes are zoomed, to do this we will check if
% % they are not being viewed in any of the 2d directions
% views2d = [0,90; 0,0; 90,0];
% 
% for i = 1:numel(hax)
% 
%     set(hax(i), 'LooseInset', ti(i,:));
%     %         set(hax(i), 'LooseInset', [0,0,0,0]);
% 
%     % get the current viewing angle of the axes
%     [az,el] = view(hax(i));
% 
%     % determine if the axes are zoomed
%     iszoomed = strcmp(get(hax(i), 'CameraViewAngleMode'), 'manual');
% 
%     % test if we are viewing in 2d mode or a 3d view
%     is2d = all(bsxfun(@eq, [az,el], views2d), 2);
% 
%     if iszoomed && ~any(is2d)
%         error('TIGHTFIG:haszoomed3d', 'Cannot make figures containing zoomed 3D axes tight.')
%     end
% 
% end
% 
% % we will move all the axes down and to the left by the amount
% % necessary to just show the bottom and leftmost axes and labels etc.
% moveleft = min(pos(:,1) - ti(:,1));
% 
% movedown = min(pos(:,2) - ti(:,2));
% 
% % we will also alter the height and width of the figure to just
% % encompass the topmost and rightmost axes and lables
% figwidth = max(pos(:,1) + pos(:,3) + ti(:,3) - moveleft);
% 
% figheight = max(pos(:,2) + pos(:,4) + ti(:,4) - movedown);
% 
% % move all the axes
% for i = 1:numel(hax)
% 
%     set(hax(i), 'Position', [pos(i,1:2) - [moveleft,movedown], pos(i,3:4)]);
% 
% end
% 
% origfigunits = get(hfig, 'Units');
% 
% set(hfig, 'Units', 'centimeters');
% 
% % change the size of the figure
% figpos = get(hfig, 'Position');
% 
% set(hfig, 'Position', [figpos(1), figpos(2), figwidth, figheight]);
% 
% % change the size of the paper
% set(hfig, 'PaperUnits','centimeters');
% set(hfig, 'PaperSize', [figwidth, figheight]);
% set(hfig, 'PaperPositionMode', 'manual');
% set(hfig, 'PaperPosition',[0 0 figwidth figheight]);
% 
% % reset to original units for axes and figure
% if ~iscell(origaxunits)
%     origaxunits = {origaxunits};
% end
% 
% for i = 1:numel(hax)
%     set(hax(i), 'Units', origaxunits{i});
% end
% 
% set(hfig, 'Units', origfigunits);
% 
% 
% 
% function scaled = scale_image(imat,scale_zoom)
% 
% oldSize = size(imat);                               % Old image size
% newSize = max(floor(scale_zoom(1:2).*oldSize(1:2)),1);  % New image size
% newX = ((1:newSize(2))-0.5)./scale_zoom(2)+0.5;  % New image pixel X coordinates
% newY = ((1:newSize(1))-0.5)./scale_zoom(1)+0.5;  % New image pixel Y coordinates
% oldClass = class(imat);  % Original image type
% imat = double(imat);      % Convert image to double precision for interpolation
% scaled = interp2(imat,newX,newY(:),'cubic');
% scaled = cast(scaled,oldClass);  % Convert back to original image type
% 
% 
% function nii=load_nii_proxi(fname)
% 
% V=spm_vol(fname);
% X=spm_read_vols(V);
% nii.img=X;
% nii.hdr=V;
