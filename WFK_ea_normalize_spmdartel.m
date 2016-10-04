function WFK_ea_normalize_spmdartel(handles,outRoot,patientName,anatFileName)
% This is a function that normalizes both a copy of transversal and coronar
% images into MNI-space. The goal was to make the procedure both robust and
% automatic, but still, it must be said that normalization results should
% be taken with much care because all reconstruction results heavily depend
% on these results. Normalization of DBS-MR-images is especially
% problematic since usually, the field of view doesn't cover the whole
% brain (to reduce SAR-levels during acquisition) and since electrode
% artifacts can impair the normalization process. Therefore, normalization
% might be best archieved with other tools that have specialized on
% normalization of such image data.
%
% The procedure used here uses the SPM DARTEL approach to map a patient's
% brain to MNI space directly. Unlike the usual DARTEL-approach, which is
% usually used for group studies, here, DARTEL is used for a pairwise
% co-registration between patient anatomy and MNI template. It has been
% shown that DARTEL also performs superior to many other normalization approaches
% also  in a pair-wise setting e.g. in
%   Klein, A., et al. (2009). Evaluation of 14 nonlinear deformation algorithms
%   applied to human brain MRI registration. NeuroImage, 46(3), 786?802.
%   doi:10.1016/j.neuroimage.2008.12.037
%
% Since a high resolution is needed for accurate DBS localizations, this
% function applies DARTEL to an output resolution of 0.5 mm isotropic. This
% makes the procedure quite slow.

% The function uses some code snippets written by Ged Ridgway.
% __________________________________________________________________________________
% Copyright (C) 2014 Charite University Medicine Berlin, Movement Disorders Unit
% Andreas Horn

%
%  Copy of original ea_normalize_spmdartel.m file to allow me to adapt
%  for the purposes of the Seeking Beta project.
%  Bill Kaemmerer (WFK) - June 20, 2016
%


%if ischar(options) % return name of method.
%    if strcmp(spm('ver'),'SPM12')
%        varargout{1}='SPM12 DARTEL nonlinear [MR/CT]';
%    elseif strcmp(spm('ver'),'SPM8')%
%        varargout{1}='SPM8 DARTEL nonlinear [MR/CT]';
%    end
%    varargout{2}={'SPM8','SPM12'};
%    return
%end
global codePath;
options.earoot = codePath;
options.prefs.normalize.coreg = 'auto';
options.root = outRoot;
options.prefs.patientdir = patientName;
options.prefs.prenii_unnormalized = anatFileName;
options.patientname = patientName;


segmentresolution=0.5; % resolution of the DARTEL-Warps. Setting this value to larger values will generate the usual DARTEL-Workflow.
usecombined=0;         % if set, eauto will try to fuse coronar and transversal images before normalizing them.
usesegmentnew=0;
costfuns={'nmi','mi','ecc','ncc'};

% now dartel-import the preoperative version.

set(handles.ProcessingStepText,'String','Segmenting MR--TAKES ~20 min.');
set(handles.CurrentText,'String',' ');
set(handles.TotalCountText,'String',' ');
t1 = datetime('now');
t2 = t1 + minutes(20);
set(handles.ExpectedCompletionTime,'String',sprintf('Guess at segment completion time: %s',datestr(t2)));
pause on;
pause(0.5);
timerVal = tic;
ea_newseg([options.root,options.prefs.patientdir,filesep],options.prefs.prenii_unnormalized,1,options);
delete([options.root,options.prefs.patientdir,filesep,'c4',options.prefs.prenii_unnormalized]);
delete([options.root,options.prefs.patientdir,filesep,'c5',options.prefs.prenii_unnormalized]);
elapsedSeconds = toc(timerVal);
set(handles.ProcessingStepText,'String',sprintf('Segmentation took %6.2f min.',elapsedSeconds/60));
set(handles.CurrentText,'String',' ');
set(handles.TotalCountText,'String',' ');
set(handles.ExpectedCompletionTime,'String',' ');
pause on;
pause(3.0);


% There is a DARTEL-Template. Check if it will match:
Vt=spm_vol([options.earoot,filesep,'templates',filesep,'dartel',filesep,'dartelmni_6.nii']);
Vp=spm_vol([options.root,filesep,options.patientname,filesep,'rc1',options.prefs.prenii_unnormalized]);
if ~isequal(Vp.dim,Vt(1).dim) || ~isequal(Vp.mat,Vt(1).mat) % Dartel template not matching. -> create matching one.
    ea_create_mni_darteltemplate([options.root,filesep,options.patientname,filesep,'rc1',options.prefs.prenii_unnormalized]);
end


% Normalize to MNI using DARTEL.
matlabbatch{1}.spm.tools.dartel.warp1.images = {
    {[options.root,options.prefs.patientdir,filesep,'rc1',options.prefs.prenii_unnormalized,',1']};
    {[options.root,options.prefs.patientdir,filesep,'rc2',options.prefs.prenii_unnormalized,',1']};
    {[options.root,options.prefs.patientdir,filesep,'rc3',options.prefs.prenii_unnormalized,',1']}
    }';
matlabbatch{1}.spm.tools.dartel.warp1.settings.rform = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).rparam = [4 2 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).K = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(1).template = {[options.earoot,'templates',filesep,'dartel',filesep,'dartelmni_6.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).rparam = [2 1 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).K = 0;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(2).template = {[options.earoot,'templates',filesep,'dartel',filesep,'dartelmni_5.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).rparam = [1 0.5 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).K = 1;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(3).template = {[options.earoot,'templates',filesep,'dartel',filesep,'dartelmni_4.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).rparam = [0.5 0.25 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).K = 2;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(4).template = {[options.earoot,'templates',filesep,'dartel',filesep,'dartelmni_3.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).K = 4;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(5).template = {[options.earoot,'templates',filesep,'dartel',filesep,'dartelmni_2.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).its = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).rparam = [0.25 0.125 1e-06];
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).K = 6;
matlabbatch{1}.spm.tools.dartel.warp1.settings.param(6).template = {[options.earoot,'templates',filesep,'dartel',filesep,'dartelmni_1.nii']};
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.lmreg = 0.01;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.cyc = 3;
matlabbatch{1}.spm.tools.dartel.warp1.settings.optim.its = 3;
jobs{1}=matlabbatch;

try
    set(handles.ProcessingStepText,'String','Now, Dartel coreg, takes ~ 7 min.');
    set(handles.CurrentText,'String',' ');
    set(handles.TotalCountText,'String',' ');
    t1 = datetime('now');
    t2 = t1 + minutes(7);
    set(handles.ExpectedCompletionTime,'String',sprintf('Guess at Dartel completion time: %s',datestr(t2)));
    pause on;
    pause(0.5);
    timerVal = tic;
    cfg_util('run',jobs);
    elapsedSeconds = toc(timerVal);
    set(handles.ProcessingStepText,'String',sprintf('Dartel took %6.2f min.',elapsedSeconds/60));
    set(handles.CurrentText,'String',' ');
    set(handles.TotalCountText,'String',' ');
    set(handles.ExpectedCompletionTime,'String',' ');
    pause on;
    pause(0.5);
catch
    set(handles.ProcessingStepText,'String','Uh-oh, Dartel coregistration failed!');
    set(handles.CurrentText,'String',' ');
    set(handles.TotalCountText,'String',' ');
    pause on;
    pause(0.5);
    error('*** Dartel coregistration failed.');
end

clear matlabbatch jobs;

% export normalization parameters:
step = 0;
nSteps = 2;
for inverse=0:1
    if inverse
        addstr='_inv';
    else
        addstr='';
    end
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.flowfield = {[options.root,options.prefs.patientdir,filesep,'u_rc1',options.prefs.prenii_unnormalized]};
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.times = [1-inverse 0+inverse];
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.K = 6;
    matlabbatch{1}.spm.util.defs.comp{1}.dartel.template = {''};
    matlabbatch{1}.spm.util.defs.out{1}.savedef.ofname = ['ea',addstr,'_normparams'];
    matlabbatch{1}.spm.util.defs.out{1}.savedef.savedir.saveusr = {[options.root,options.prefs.patientdir,filesep]};
    jobs{1}=matlabbatch;
    step = step + 1;
    set(handles.ProcessingStepText,'String','Saving norm params.');
    set(handles.CurrentText,'String',sprintf('%d',step));
    set(handles.TotalCountText,'String',sprintf('%d',nSteps));
    pause on;
    pause(0.5);
    cfg_util('run',jobs);
    clear matlabbatch jobs;
end

% WFK_ea_apply_normalization(handles,options)
