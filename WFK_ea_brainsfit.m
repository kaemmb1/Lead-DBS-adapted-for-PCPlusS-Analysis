function WFK_ea_brainsfit(handles,fixedVolume, movingVolume, outputVolume)
% Wrapper for BRAINSFit
%
global codePath;  % e.g. C:\WFK\lead_dbs\;
BrainsFitDir =   strcat(codePath,'ext_libs\BRAINSFit\');
% BrainsFitDir = 'C:\WFK\lead_dbs\ext_libs\BRAINSFit\';  % WFK June 13, 2016 
% NOTE the above path must not contain any blanks or whitespace.



if fileparts(movingVolume)
    volumedir = [fileparts(movingVolume), filesep];
else
    volumedir =['.', filesep];
end

fixedVolume = ea_path_helper(fixedVolume);
movingVolume = ea_path_helper(movingVolume);
outputVolume = ea_path_helper(outputVolume);

fixparams = [' --fixedVolume ' , fixedVolume, ...
             ' --movingVolume ', movingVolume, ...
             ' --outputVolume ', outputVolume, ...
             ' --useRigid --useAffine' ...
             ' --samplingPercentage 0.005' ...
             ' --removeIntensityOutliers 0.005' ...
             ' --interpolationMode Linear' ...
             ' --outputTransform ', ea_path_helper([volumedir, 'ct2anat.txt'])];

% first attempt...
paramset{1} = [fixparams, ...
               ' --initializeTransformMode useGeometryAlign' ...
               ' --maskProcessingMode ROIAUTO' ...
               ' --ROIAutoDilateSize 3'];
% second attempt...
paramset{2} = [fixparams, ...
               ' --initializeTransformMode useGeometryAlign'];          
% third attempt...
if exist([volumedir, 'ct2anat.txt'],'file')
    paramset{3} = [fixparams, ...
                   ' --maskProcessingMode ROIAUTO' ...
                   ' --ROIAutoDilateSize 3' ...
                   ' --initializeTransformMode Off' ...
                   ' --initialTransform ', ea_path_helper([volumedir, 'ct2anat.txt'])];
else
    paramset{3} = [fixparams, ...
                   ' --maskProcessingMode ROIAUTO' ...
                   ' --ROIAutoDilateSize 3'];
end
% fourth attempt..
if exist([volumedir, 'ct2anat.txt'],'file')
    paramset{4} = [fixparams, ...
                   ' --initializeTransformMode Off' ...
                   ' --initialTransform ', ea_path_helper([volumedir, 'ct2anat.txt'])];
else
    paramset{4} = fixparams;
end

basename = [fileparts(mfilename('fullpath')), filesep, 'BRAINSFit'];

if ispc
    BRAINSFit = [BrainsFitDir, 'BRAINSFit.exe '];  %  WFK June 13, 2016
elseif isunix
    BRAINSFit = [basename, '.', computer, ' '];
end

ea_libs_helper
elapsedSeconds = 0;
nTrials = 4;
for trial = 1:nTrials
    cmd = [BRAINSFit, paramset{trial}];
    if ~ispc
        status = system(['bash -c "', cmd, '"']);
    else
        set(handles.ProcessingStepText,'String','Now running BRAINSFit.exe');
        set(handles.CurrentText,'String',sprintf('Try #%d',trial));
        set(handles.TotalCountText,'String',sprintf('%d',nTrials));
        tic;
        status = system(cmd);
        elapsedSeconds = toc;
    end
    set(handles.ProcessingStepText,'String',sprintf('BRAINSFit.exe took %6.2f min.',elapsedSeconds/60.0));
    if status == 0
        set(handles.CurrentText,   'String',' ');
        set(handles.TotalCountText,'String',' ');
        % fprintf(['\nBRAINSFit with parameter set ', num2str(trial), '\n']);
        break
    end
end
