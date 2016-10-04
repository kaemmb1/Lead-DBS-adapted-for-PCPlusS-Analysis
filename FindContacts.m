function varargout = FindContacts(varargin)
% FINDCONTACTS MATLAB code for FindContacts.fig
%      FINDCONTACTS, by itself, creates a new FINDCONTACTS or raises the existing
%      singleton*.
%
%      H = FINDCONTACTS returns the handle to a new FINDCONTACTS or the handle to
%      the existing singleton*.
%
%      FINDCONTACTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINDCONTACTS.M with the given input arguments.
%
%      FINDCONTACTS('Property','Value',...) creates a new FINDCONTACTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FindContacts_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FindContacts_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FindContacts

% Last Modified by GUIDE v2.5 27-Sep-2016 14:38:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FindContacts_OpeningFcn, ...
                   'gui_OutputFcn',  @FindContacts_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function figure1_CreateFcn(hObject,eventdata,handles)
%end

% --- Executes just before FindContacts is made visible.
function FindContacts_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FindContacts (see VARARGIN)

% Choose default command line output for FindContacts
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global codePath;  % directory root for ext_libs\BRAINSFit\
global ReadyToRun;
ReadyToRun = false;
%
%  Attempt to set codePath automatically...
%
str = which('BRAINSFit.exe');
[path,~,~] = fileparts(str);
index = strfind(path,'ext_libs\BRAINSFit');
if ~isempty(index)
    codePath = path(1:index-1);
else
    % if we can't find this automatically, the have the user find it.
    path = uigetdir('C:\','Select folder that contains BRAINSFit.exe');
    index = strfind(path,'ext_libs\BRAINSFit');
    if ~isempty(index)
        codePath = path(1:index-1);
    else
        % if the user entered something invalid, give error msg.
        error('Need to have global variable codePath set to directory root for ext_libs\BRAINSFit\');
    end;
end;
%
%
global LeftLeadModel;
LeftLeadModel = 'None';
global RightLeadModel;
RightLeadModel = 'None';
global outDirectory;
outDirectory = [];
global gray;
global darkGray;
global brightGreen;
global darkGreen;
global softGreen;
global blue;
gray = [240 240 240]/255;
darkGray = [96 96 96]/255;
brightGreen = [51 204 0]/255;
darkGreen = [0 148 0]/255;
softGreen = [193 221 198]/255;
blue = [0 0 1];

function checkReadyToRun(handles)
% Set ReadyToRun global to true if all of the following are true:
% outDirectory has been set;
% LeftLead is not NONE -or- RightLead is not NONE (or both are not NONE)
global LeftLeadModel;
global RightLeadModel;
% global PatientFolderName;
global outDirectory;
global codePath;
global ReadyToRun;
global gray;
global softGreen;
% [outRoot,~,~] = fileparts(outDirectory);
% outRoot = strcat(outRoot,'\');
% PatientFolderName = get(handles.PatientFolder,'String');
if isdir(outDirectory) && ...
        (~strcmp(LeftLeadModel,'None') || ~strcmp(RightLeadModel,'None'))
    ReadyToRun = true;
else
    ReadyToRun = false;
end
if (ReadyToRun)
    set(handles.STEP1,'enable','on');
    set(handles.STEP2,'enable','on');
    set(handles.STEP3,'enable','on');
    set(handles.STEP4,'enable','on');
    set(handles.STEP5,'enable','on');
    set(handles.STEP6,'enable','on');
    set(handles.STEP7,'enable','on');
    set(handles.STEP8,'enable','on');
    set(handles.Step8Bypass,'enable','on');
    set(handles.STEP9,'enable','on');
    set(handles.STEP10,'enable','on');
    set(handles.STEP11,'enable','on');
    set(handles.STEP12,'enable','on');
    set(handles.RunButton,'enable','on');
    set(handles.RunAllStepsButton,'enable','on');
else
    set(handles.STEP1,'enable','off');
    set(handles.STEP2,'enable','off');
    set(handles.STEP3,'enable','off');
    set(handles.STEP4,'enable','off');
    set(handles.STEP5,'enable','off');
    set(handles.STEP6,'enable','off');
    set(handles.STEP7,'enable','off');
    set(handles.STEP8,'enable','off');
    set(handles.Step8Bypass,'enable','off');
    set(handles.STEP9,'enable','off');
    set(handles.STEP10,'enable','off');
    set(handles.STEP11,'enable','off');
    set(handles.STEP12,'enable','on');
    set(handles.RunButton,'enable','off');
    set(handles.RunAllStepsButton,'enable','off');
end;
resultFileExists = ResultsExist();
if resultFileExists
    set(handles.ReloadResults,'enable','on');
else
    set(handles.ReloadResults,'enable','off');
end;  

anatFileName =         strcat(outDirectory,'\',      'anat.nii');
registeredCTFileName = strcat(outDirectory,'\','rpostop_ct.nii');
if (exist(anatFileName,'file') == 2) && ...
        (exist(registeredCTFileName,'file') == 2)
    set(handles.ShowCoregistration,'enable','on');
    set(handles.ShowCoregistration,'BackgroundColor',softGreen);
    set(handles.ShowCoregistration,'String','Show coregistration');
else
    set(handles.ShowCoregistration,'enable','off');
    set(handles.ShowCoregistration,'BackgroundColor',gray);
    set(handles.ShowCoregistration,'String','Show coregistration');
end;

mniWiresFileName = strcat(codePath,'templates\mni_wires.nii');
warpedMRFileName = strcat(outDirectory,'\','glanat.nii');
if (exist(mniWiresFileName,'file') == 2) && ...
        (exist(warpedMRFileName,'file') == 2)
    set(handles.ShowNormalization,'enable','on');
    set(handles.ShowNormalization,'BackgroundColor',softGreen);
    set(handles.ShowNormalization,'String','Show normalization');
else
    set(handles.ShowNormalization,'enable','off');
    set(handles.ShowNormalization,'BackgroundColor',gray);
    set(handles.ShowNormalization,'String','Show normalization');
end;

% --- Outputs from this function are returned to the command line.
function varargout = FindContacts_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in SelectOutputFolder.
function SelectOutputFolder_Callback(hObject, eventdata, handles)
% hObject    handle to SelectOutputFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global blue;
global outDirectory;
global LeftLeadModel;
global RightLeadModel;
outDirectory = uigetdir();
if (outDirectory == 0)  % user cancelled operation
    return;
end;
resetGUI(handles);
[~,patientName,~] = fileparts(outDirectory);
numChar = length(patientName);
if numChar < 18
    displayName = patientName;
else
    displayName = strcat(patientName(1:5),'...',patientName(end-10:end));
end;
set(handles.outputFolder,'String',displayName);
set(handles.CurrentPatientNumber,'String','1');
set(handles.CurrentPatientNumber,'ForegroundColor',blue);
set(handles.TotalNumberOfPatients,'String','1');
set(handles.TotalNumberOfPatients,'ForegroundColor',blue);
justChecking = false;
readLeadModels(handles,justChecking,patientName);
checkReadyToRun(handles);

% --- Executes when selected object is changed in LeftLeadButtonGroup.
function LeftLeadButtonGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in LeftLeadButtonGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global LeftLeadModel;
choice = get(handles.LeftLeadButtonGroup,'SelectedObject');
choiceName = get(choice,'Tag');
switch choiceName
    case {'Left3387'}
        LeftLeadModel = 'Medtronic 3387';
    case {'Left3389'}
        LeftLeadModel = 'Medtronic 3389';
    otherwise
        LeftLeadModel = 'None';
end;
checkReadyToRun(handles);

% --- Executes when selected object is changed in RightLeadButtonGroup.
function RightLeadButtonGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in RightLeadButtonGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global RightLeadModel;
choice = get(handles.RightLeadButtonGroup,'SelectedObject');
choiceName = get(choice,'Tag');
switch choiceName
    case {'Right3387'}
        RightLeadModel = 'Medtronic 3387';
    case {'Right3389'}
        RightLeadModel = 'Medtronic 3389';
    otherwise
        RightLeadModel = 'None';
end;
checkReadyToRun(handles);

function ProcessingStepText_Callback(hObject, eventdata, handles)
% hObject    handle to ProcessingStepText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function ProcessingStepText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProcessingStepText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CurrentText_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function CurrentText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TotalCountText_Callback(hObject, eventdata, handles)
% hObject    handle to TotalCountText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function TotalCountText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalCountText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DICOMtoNIITime_Callback(hObject, eventdata, handles)
% hObject    handle to DICOMtoNIITime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function DICOMtoNIITime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DICOMtoNIITime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function InterpolateMRTime_Callback(hObject, eventdata, handles)
% hObject    handle to InterpolateMRTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function InterpolateMRTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InterpolateMRTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function CTRegistrationTime_Callback(hObject, eventdata, handles)
% hObject    handle to CTRegistrationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function CTRegistrationTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CTRegistrationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function NormalizationTime_Callback(hObject, eventdata, handles)
% hObject    handle to NormalizationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function NormalizationTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NormalizationTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ApplyNormTime_Callback(hObject, eventdata, handles)
% hObject    handle to ApplyNormTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function ApplyNormTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ApplyNormTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LeadReconstructionTime_Callback(hObject, eventdata, handles)
% hObject    handle to LeadReconstructionTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function LeadReconstructionTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LeadReconstructionTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ContactIDTime_Callback(hObject, eventdata, handles)
% hObject    handle to ContactIDTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function ContactIDTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ContactIDTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TotalRunTime_Callback(hObject, eventdata, handles)
% hObject    handle to TotalRunTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function TotalRunTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalRunTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RunButton.
function RunButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%  The goal of FindContacts is to find the coordinates of the contacts of
%  the DBS leads in a patient given the patient's pre-operative MRI and
%  post-operative CT.  The procedure is based on the methods used in the
%  LEAD-DBS toolbox, with some modifications to make the processing as
%  automatic as possible (ie., with the least amount of user intervention
%  and fewest manual steps).
%
%  The steps in the processing are as follows:
%  1) Convert the patient's DICOM images to Nifty format (.nii files)
%  2) Reslice the pre-operative MR file (anat.nii).
%  3) Co-register the post-operative CT to the pre-operative MRI using the
%     BrainFit routine.
%  4) Normalize the post-operative CT to MNI coordinate space using the SPM
%     DARTEL function to find the deformation field.
%  5) Apply the deformation field to the MRI and CT files.
%  6) Identify the likely trajectories of the leads in the CT based on the
%     artifact caused by the leads in the CT imaging.
%  7) Identify the likely contact locations in the lead trajectories by 
%     looking for the "donut holes" in the artifact caused by the ring
%     electrodes.
%  8) Allow the user to manually review and/or re-position the lead contacts 
%     onto the artifact in the CT image.
%  9) Output the coordinates of the lead contacts in MNI coordinate space;
%         also, back-translate to patient coordinate space.
%
%   -- Bill Kaemmerer, July, 2016
%
set(handles.RunButton,'enable','off');
set(handles.RunButton,'BackgroundColor',[255 102 102]/255);
set(handles.RunButton,'String','(running)');
set(handles.TotalRunTime,'String',' --- ');
set(handles.STEP1,'enable','off');
set(handles.STEP2,'enable','off');
set(handles.STEP3,'enable','off');
set(handles.STEP4,'enable','off');
set(handles.STEP5,'enable','off');
set(handles.STEP6,'enable','off');
set(handles.STEP7,'enable','off');
timerVal = tic;
STEP1_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP2_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP3_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP4_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP5_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP6_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP7_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
set(handles.STEP1,'enable','on');
set(handles.STEP2,'enable','on');
set(handles.STEP3,'enable','on');
set(handles.STEP4,'enable','on');
set(handles.STEP5,'enable','on');
set(handles.STEP6,'enable','on');
set(handles.STEP7,'enable','on');
set(handles.RunButton,'enable','on');
set(handles.RunButton,'BackgroundColor',[0 209 0]/255);
set(handles.RunButton,'String','Run');

function OK = step1(handles)
%
%  Convert the patient's DICOM images to Nifty format (.nii files)
%
%  Convention:  
%      The DICOM files for pre-operative MR images are expected to be in a
%           subdirectory of the patient folder, named "MR", and
%      the DICOM files for the post-operative CT images are expected to be
%           in a subdirectory of the patient folder, named "CT".
%
%
% global PatientFolderName;
global outDirectory;
%
% Directory and subdirectory naming conventions.
%
MRdirectory = strcat(outDirectory,'\DICOM\MR');
CTdirectory = strcat(outDirectory,'\DICOM\CT');
MRniiSubdirectory = 'MRnii';
CTniiSubdirectory = 'CTnii';
%
% Convert the DICOMs in the MR directory to nii files
%
files = dir(MRdirectory);
nFiles = length(files);
fcnt = 1;
for i = 1:nFiles
    if ~strcmp(files(i).name(1),'.') && ~files(i).isdir
        filecell{fcnt}=strcat(MRdirectory,'\',files(i).name);
        fcnt=fcnt+1;
    end
end
job.data = filecell';
job.root = 'flat';
job.outdir = {outDirectory};
job.protfilter = '.*';
job.convopts.format = 'nii';
job.convopts.icedims = 0;
msg = 'Reading MR DICOM headers';
out = WFK_spm_run_dicom(handles,msg,job);
set(handles.ProcessingStepText,'String','Done converting MR files');
% move the MR files that are now in .nii format into a subdirectory
mkdir(outDirectory,MRniiSubdirectory);
nFiles = length(out.files);
for i = 1:nFiles
    src = out.files{i};
    [pathstr,name,ext] = fileparts(src);
    dest = strcat(pathstr,'\',MRniiSubdirectory,'\',name,ext);
    movefile(src,dest);
end;
% find the largest of the MRnii files 
D = dir(strcat(outDirectory,'\',MRniiSubdirectory,'\'));
maxSize = 0;
oneWithMaxSize = 0;
for i = 1:length(D)
    if ~strcmp(D(i).name(1),'.') && ~D(i).isdir
        sz = D(i).bytes;
        if (sz > maxSize)
            maxSize = sz;
            oneWithMaxSize = i;
        end;
    end;
end;
% Move a copy of the largest MRnii file back to the outputFiles directory
% giving the file the name anat.nii  
fullFileName = strcat(outDirectory,'\',MRniiSubdirectory,'\',D(oneWithMaxSize).name);
copyfile(fullFileName,outDirectory);
copyFileName = strcat(outDirectory,'\',D(oneWithMaxSize).name);
renameFileName = strcat(outDirectory,'\','anat.nii');
movefile(copyFileName,renameFileName);
%
% Convert the DICOMs in the CT directory to nii files
%
files = dir(CTdirectory);
nFiles = length(files);
fcnt = 1;
for i = 1:nFiles
    if ~strcmp(files(i).name(1),'.') && ~files(i).isdir
        filecell{fcnt}=strcat(CTdirectory,'\',files(i).name);
        fcnt=fcnt+1;
    end
end
job.data = filecell';
job.root = 'flat';
job.outdir = {outDirectory};
job.protfilter = '.*';
job.convopts.format = 'nii';
job.convopts.icedims = 0;
msg = 'Reading CT DICOM headers';
out = WFK_spm_run_dicom(handles,msg,job);
set(handles.ProcessingStepText,'String','Done converting CT files');
% move the CT files that are now in .nii format into a subdirectory
mkdir(outDirectory,CTniiSubdirectory);
nFiles = length(out.files);
for i = 1:nFiles
    src = out.files{i};
    [pathstr,name,ext] = fileparts(src);
    dest = strcat(pathstr,'\',CTniiSubdirectory,'\',name,ext);
    movefile(src,dest);
end;
% find the largest of the CTnii files 
D = dir(strcat(outDirectory,'\',CTniiSubdirectory,'\'));
maxSize = 0;
oneWithMaxSize = 0;
for i = 1:length(D)
    if ~strcmp(D(i).name(1),'.') && ~D(i).isdir
        sz = D(i).bytes;
        if (sz > maxSize)
            maxSize = sz;
            oneWithMaxSize = i;
        end;
    end;
end;
% Move a copy of the largest CTnii file back to the outputFiles directory
% giving the file the name postop_ct.nii  
fullFileName = strcat(outDirectory,'\',CTniiSubdirectory,'\',D(oneWithMaxSize).name);
copyfile(fullFileName,outDirectory);
copyFileName = strcat(outDirectory,'\',D(oneWithMaxSize).name);
renameFileName = strcat(outDirectory,'\','postop_ct.nii');
movefile(copyFileName,renameFileName);
OK = true;

function OK = step2(handles)
%
%  Interpolate pre-operative anatomical image (anat.nii) 
%
global outDirectory;
OK = false;
anatFileName = strcat(outDirectory,'\','anat.nii');
voxelSize = [0.5,0.5,0.5];
set(handles.ProcessingStepText,'String','Interpolating MR slices.');
pause on;
pause(0.005);
WFK_ea_reslice_nii(handles,anatFileName,anatFileName,voxelSize);
set(handles.ProcessingStepText,'String','Done re-slicing MR anat.nii.');
set(handles.CurrentText,   'String',' ');
set(handles.TotalCountText,'String',' ');
OK = true;

function OK = step3(handles)
%
%  Co-register the post-op CT to the pre-op MR
%
global outDirectory;
global brightGreen;
global gray;
OK = false;
set(handles.ShowCoregistration,'enable','off');
anatFileName =         strcat(outDirectory,'\',      'anat.nii');
postopCTFileName =     strcat(outDirectory,'\', 'postop_ct.nii');
registeredCTFileName = strcat(outDirectory,'\','rpostop_ct.nii');
set(handles.ProcessingStepText,'String','Calling BRAINSFIT.');
set(handles.CurrentText,   'String',' ');
set(handles.TotalCountText,'String',' ');
t1 = datetime('now');
t2 = t1 + minutes(8);
set(handles.ExpectedCompletionTime,'String',sprintf('Guess at BRAINSFIT completion time: %s',datestr(t2)));
WFK_ea_brainsfit(handles,anatFileName,postopCTFileName,registeredCTFileName);
set(handles.ProcessingStepText,'String','Co-registration done.');
set(handles.ExpectedCompletionTime,'String','');
if (exist(anatFileName,'file') == 2) && ...
        (exist(registeredCTFileName,'file') == 2)
    set(handles.ShowCoregistration,'enable','on');
    set(handles.ShowCoregistration,'BackgroundColor',brightGreen);
else
    set(handles.ShowCoregistration,'enable','off');
    set(handles.ShowCoregistration,'BackgroundColor',gray);
end;
OK = true;

function OK = step4(handles)
%
%  Normalization of anat.nii and rpostop_ct.nii via SPM DARTEL method
%  to produce lpostop_ct.nii.
%
global outDirectory; 
global brightGreen;
global gray;
set(handles.ShowNormalization,'enable','off');
[outRoot,patientName,~] = fileparts(outDirectory);
outRoot = strcat(outRoot,'\');
OK = false;
anatFileName = 'anat.nii';
set(handles.ProcessingStepText,'String','WFK_ea_normalize_spmdartel)');
set(handles.CurrentText,   'String',' ');
set(handles.TotalCountText,'String',' ');
WFK_ea_normalize_spmdartel(handles,outRoot,patientName,anatFileName);
set(handles.ProcessingStepText,'String','Normalization params written.');
set(handles.CurrentText,   'String',' ');
set(handles.TotalCountText,'String',' ');
OK = true;

function OK = step5(handles)
%
%  Apply the normalizations found in step 4.
%
global outDirectory;  
global codePath;
global brightGreen;
global gray;
[outRoot,patientName,~] = fileparts(outDirectory);
outRoot = strcat(outRoot,'\');
OK = false;
anatFileName = 'anat.nii';
set(handles.ProcessingStepText,'String','Apply normalizations');
set(handles.CurrentText,   'String',' ');
set(handles.TotalCountText,'String',' ');
WFK_ea_apply_normalization(handles,outRoot,patientName,anatFileName);
set(handles.ProcessingStepText,'String','Normalization applied.');
mniWiresFileName = strcat(codePath,'templates\mni_wires.nii');
warpedMRFileName = strcat(outDirectory,'\','glanat.nii');
if (exist(mniWiresFileName,'file') == 2) && ...
        (exist(warpedMRFileName,'file') == 2)
    set(handles.ShowNormalization,'enable','on');
    set(handles.ShowNormalization,'BackgroundColor',brightGreen);
else
    set(handles.ShowNormalization,'enable','off');
    set(handles.ShowNormalization,'BackgroundColor',gray);
end;
%
%  Save a copy of the current deformation field for converting MNI space
%  (in millimeters) back to patient space (in millimeters), for use later.
%  This is necessary because sometimes lead_dbs routines re-use this file
%  name, and then the backtranslation doesn't work anymore.
%   -- Bill Kaemmerer, August 26, 2016.
%
deformationFieldFileName = strcat(outDirectory,'\','y_ea_normparams.nii');
copyOfDeformationFieldFile = strcat(outDirectory,'\','y_ea_normparams_saved.nii');
copyfile(deformationFieldFileName,copyOfDeformationFieldFile);
%
%  Save a copy of the inverse, too, just in case this also might get
%  overwritten by some later Lead-DBS processing.  This deformation field
%  will be used to go from Manual Stealth Coordinates to the patient's
%  equivalent MNI Coordinates.
%    -- Bill Kaemmerer, September 28, 2016
%
deformationFieldFileName = strcat(outDirectory,'\','y_ea_inv_normparams.nii');
copyOfDeformationFieldFile = strcat(outDirectory,'\','y_ea_inv_normparams_saved.nii');
copyfile(deformationFieldFileName,copyOfDeformationFieldFile);
%
set(handles.ProcessingStepText,'String','Normalization done.');
OK = true;

function OK = step6(handles)
%
%  Using lpostop_ct.nii, reconstruct the lead trajectories
%
global outDirectory;  
global darkGray;
[outRoot,patientName,~] = fileparts(outDirectory);
outRoot = strcat(outRoot,'\');
OK = false;
global LeftLeadModel;
global RightLeadModel;
leftLeadCoordinates = [];
rightLeadCoordinates = [];
set(handles.LeftContactCoordinatesTable,'Data',leftLeadCoordinates);
set(handles.RightContactCoordinatesTable,'Data',rightLeadCoordinates);
set(handles.LeftContactsStealthCoordinates,'Data',[]);
set(handles.RightContactsStealthCoordinates,'Data',[]);
currentLead = 0;
if strcmp(RightLeadModel,'None')
    if strcmp(LeftLeadModel,'None')
        % No leads at all, we shouldn't be here.
        error('No lead specified for either hemisphere.');
    else
        % Left lead only
        numLeads = 1;
        options.sides = [2];  % Using lead-dbs Left = 2 here.
    end;
else
    if strcmp(LeftLeadModel,'None')
        % Right lead only
        numLeads = 1;
        options.sides = [1]; % Using lead-dbs Right = 1 here.
    else
        % Both leads
        numLeads = 2;
        options.sides = [1 2];
    end;
end;
set(handles.TotalCountText,'String',sprintf('%d',numLeads));
%
options.patientname = patientName; 
options.root = outRoot;
options.prefs.patientdir = patientName;
options.prefs.tranii = 'lpostop_ct.nii';
options.native = 0;
eaReconstructionFile = strcat(outDirectory,'\','ea_reconstruction.mat');
if exist(eaReconstructionFile,'file') == 2
    [coords_mm,trajectory,markers,elmodel,manually_corrected]=ea_load_reconstruction(options);
    if exist('coords_mm','var')
        nSides = max(size(coords_mm));
        if (nSides > 0)
            rightLeadCoordinates  = coords_mm{1,1};
            rightTrajectory = trajectory{1,1};
            rightMarkers = markers(1,1);
        end;
        if (nSides > 1)
            leftLeadCoordinates = coords_mm{1,2};
            leftTrajectory = trajectory{1,2};
            leftMarkers = markers(1,2);
        end;
    end;
end;
pause on;
%
if ~strcmp(LeftLeadModel,'None')
    currentLead = currentLead + 1;
    set(handles.CurrentText,'String',sprintf('Lead %d',currentLead));
    side = 2;  % For LEFT hemisphere lead
    options.elmodel = LeftLeadModel;
    set(handles.ProcessingStepText,'String','Finding LEFT Lead');
    pause(0.5);
    [coordsMM,markers,trajectory] = WFK_findTrajectory(options,side);
    set(handles.ProcessingStepText,'String','Done finding LEFT lead.');
    leftLeadCoordinates = coordsMM{1,side};
    leftTrajectory = trajectory{1,side};
    leftMarkers = markers(1,side);
    set(handles.LeftContactCoordinatesTable,'Data',leftLeadCoordinates);
    set(handles.LeftContactCoordinatesTable,'ForegroundColor',darkGray);
    set(handles.LeftMNITableLabel,'String','Left Contacts, MNI coord, initial guess.');
    set(handles.LeftMNITableLabel,'ForegroundColor',darkGray);
end;
%
if ~strcmp(RightLeadModel,'None')
    currentLead = currentLead + 1;
    set(handles.CurrentText,'String',sprintf('Lead %d',currentLead));
    side = 1;  % For RIGHT hemisphere lead
    options.elmodel = RightLeadModel;
    set(handles.ProcessingStepText,'String','Finding RIGHT Lead');
    pause(0.5);
    [coordsMM,markers,trajectory] = WFK_findTrajectory(options,side);
    set(handles.ProcessingStepText,'String','Done finding RIGHT lead.');
    rightLeadCoordinates = coordsMM{1,side};
    rightTrajectory = trajectory{1,side};
    rightMarkers = markers(1,side);
    set(handles.RightContactCoordinatesTable,'Data',rightLeadCoordinates);
    set(handles.RightContactCoordinatesTable,'ForegroundColor',darkGray);
    set(handles.RightMNITableLabel,'String','Right Contacts, MNI coord, initial guess.');
    set(handles.RightMNITableLabel,'ForegroundColor',darkGray);
end;
%
%  Now be sure that both left and right lead coordinates are written to
%  ea_reconstruction.mat
%
% load(eaReconstructionFile);
[coords_mm,trajectory,markers,elmodel,manually_corrected]=ea_load_reconstruction(options);
coords_mm{1,2} = leftLeadCoordinates;
trajectory{1,2} = leftTrajectory;
markers(1,2) = leftMarkers;
coords_mm{1,1} = rightLeadCoordinates;
trajectory{1,1} = rightTrajectory;
markers(1,1) = rightMarkers;
% save(eaReconstructionFile,'trajectory','coords_mm','markers','elmodel');
options.native = 0;
ea_save_reconstruction(coords_mm,trajectory,markers,elmodel,manually_corrected,options);
set(handles.ProcessingStepText,'String','Done finding leads.');
OK = true;

function OK = step7(handles)
%
%  Automated identification of contact locations in left and right leads.
%
global outDirectory;
global LeftLeadModel;
global RightLeadModel;
global blue;
% Get lpostop_ct.nii loaded
fileName = strcat(outDirectory,'\','lpostop_ct.nii');
Vtra=spm_vol(fileName);
% Get trajectory and markers variables from file.
% eaReconstructionFile = strcat(outDirectory,'\','ea_reconstruction.mat');
% load(eaReconstructionFile);
[outRoot,patientName,~] = fileparts(outDirectory);
outRoot = strcat(outRoot,'\');
options.root = outRoot;
options.patientname = patientName; 
options.native = 0;
[coords_mm,trajectory,markers,elmodel,manually_corrected]=ea_load_reconstruction(options);
set(handles.CurrentText,'String',' ');
set(handles.TotalCountText,'String',' ');
currentLead = 0;
if strcmp(RightLeadModel,'None')
    if strcmp(LeftLeadModel,'None')
        % No leads at all, we shouldn't be here.
        error('No lead specified for either hemisphere.');
    else
        % Left lead only
        numLeads = 1;
        options.sides = [2];  % Using lead-dbs Left = 2 here.
    end;
else
    if strcmp(LeftLeadModel,'None')
        % Right lead only
        numLeads = 1;
        options.sides = [1]; % Using lead-dbs Right = 1 here.
    else
        % Both leads
        numLeads = 2;
        options.sides = [1 2];
    end;
end;

set(handles.TotalCountText,'String',sprintf('%d',numLeads));
pause on;
%
OKLeft = true;
leftLeadCoords = [];
if ~strcmp(LeftLeadModel,'None')
    currentLead = currentLead + 1;
    set(handles.CurrentText,'String',sprintf('Lead %d',currentLead));
    set(handles.ProcessingStepText,'String','Auto ID of LEFT Contacts...');
    set(handles.LeftContactCoordinatesTable,'Data',[]);
    traj = trajectory{1,2};
    [OKLeft, leftLeadCoords] = WFK_autoFindContactCoords(Vtra,traj,markers,LeftLeadModel,handles,1);
    if ~OKLeft
        set(handles.ProcessingStepText,'String','Auto ID of LEFT Contacts FAILED.');
        pause (5.0);
    else
        coords_mm{1,2}  = leftLeadCoords;
        markers(2).head = leftLeadCoords(1,:);  % contact 0, left lead
        markers(2).tail = leftLeadCoords(4,:);  % contact 3, left lead
        % trajectory{1,2} = leftTrajectory;
        % markers(1,2) = leftMarkers;
        set(handles.LeftContactCoordinatesTable,'Data',leftLeadCoords);
        set(handles.LeftContactCoordinatesTable,'ForegroundColor',blue);
        set(handles.LeftMNITableLabel,'ForegroundColor',blue);
        set(handles.LeftMNITableLabel,'String','Left Contacts, MNI coord, not yet reviewed');
        set(handles.ProcessingStepText,'String','Auto ID of LEFT Contacts DONE.');
        set(handles.LeftContactsStealthCoordinates,'Data',[]);
        pause (1.0);
    end;
end;
%
OKRight = true;
rightLeadCoords = [];
if ~strcmp(RightLeadModel,'None')
    currentLead = currentLead + 1;
    set(handles.CurrentText,'String',sprintf('Lead %d',currentLead));
    set(handles.ProcessingStepText,'String','Auto ID of RIGHT Contacts...');
    set(handles.RightContactCoordinatesTable,'Data',[]);
    traj = trajectory{1,1};
    [OKRight, rightLeadCoords] = WFK_autoFindContactCoords(Vtra,traj,markers,RightLeadModel,handles,0);
    if ~OKRight
        set(handles.ProcessingStepText,'String','Auto ID of RIGHT Contacts FAILED.');
        pause (5.0);
    else
        coords_mm{1,1}  = rightLeadCoords;
        markers(1).head = rightLeadCoords(1,:);  % contact 0, right lead
        markers(1).tail = rightLeadCoords(4,:);  % contact 3, right lead
        % trajectory{1,1} = rightTrajectory;
        % markers(1,1) = rightMarkers;
        set(handles.RightContactCoordinatesTable,'Data',rightLeadCoords);
        set(handles.RightContactCoordinatesTable,'ForegroundColor',blue);
        set(handles.RightMNITableLabel,'ForegroundColor',blue);
        set(handles.RightMNITableLabel,'String','Right Contacts, MNI coord, not yet reviewed');
        set(handles.ProcessingStepText,'String','Auto ID of RIGHT Contacts DONE.');
        set(handles.RightContactsStealthCoordinates,'Data',[]);
        pause (1.0);
    end;
end;
%
%  Now write the coordinates to ea_reconstruction.mat
%
%  save(eaReconstructionFile,'trajectory','coords_mm','markers','elmodel');
ea_save_reconstruction(coords_mm,trajectory,markers,elmodel,manually_corrected,options);
set(handles.ProcessingStepText,'String','Done saving coords.');
%
WFK_displayCoordinatesOnSlices(handles);
% 
% Save results from Step 7 to a file that can be read in at start of Step 8
% allowing work flow to be resumed at Step 8.
%
step7IntermediateResultsFile = strcat(outDirectory,'\','InitialAutoFoundCoords.mat');
manually_corrected = 0;
save(step7IntermediateResultsFile,'coords_mm','trajectory','markers','elmodel','manually_corrected','options',...
    'leftLeadCoords','rightLeadCoords');
msg = strcat(step7IntermediateResultsFile,' written.');
set(handles.ExpectedCompletionTime,'String',msg);  % too long to put into Processing Step field, put below it.
OK = OKRight & OKLeft;

function OK = step8(handles,skipManual)
%
%  This function allows the user to position the contacts on the
%  reconstructed lead trajectories manually, then obtains the resulting
%  lead coordinates from the ea_reconstruction structure, and copies them
%  into the GUI tables and writes them to an output file.
%
%  Set skipManual argument to true to not bother with presenting the 
%  Lead-DBS manual review pop-up window to the user.  In this case, the
%  coordinates are accepted as given from Step 7, and just swapped left vs
%  right hemispheres, so that the coordinates with the positive X-axis
%  values are the right lead, and the coordinates with the negative X-axis
%  values are the left lead.
%
global darkGreen;
global blue;
global outDirectory; 
global codePath;
global WFK_manualReconstructionDone;
[outRoot,patientName,~] = fileparts(outDirectory);
outRoot = strcat(outRoot,'\');
global LeftLeadModel;
global RightLeadModel;
set(handles.ProcessingStepText,'String','Doing Manual Reconstruction');
set(handles.CurrentText,'String',' ');
set(handles.TotalCountText,'String',' ');
set(handles.ExpectedCompletionTime,'String',' ');  % not needed, clear this field from Step 7.
step7IntermediateResultsFile = strcat(outDirectory,'\','InitialAutoFoundCoords.mat');
fid = fopen(step7IntermediateResultsFile,'r');
if (fid == -1) % -1 means could not open the file; otherwise, already exists
    set(handles.ProcessingStepText,'String','Step 7 results not available.');
    set(handles.CurrentText,'String',' ');
    set(handles.TotalCountText,'String',' ');
    OK = false;
    return;
else
    fclose(fid);
end;
% get everything back to the way it was at the end of step 7:
load(step7IntermediateResultsFile);
set(handles.RightContactCoordinatesTable,'Data',rightLeadCoords);
set(handles.RightContactCoordinatesTable,'ForegroundColor',blue);
set(handles.RightMNITableLabel,'ForegroundColor',blue);
set(handles.RightMNITableLabel,'String','Right Contacts, MNI coord, not yet reviewed');
set(handles.LeftContactCoordinatesTable,'Data',leftLeadCoords);
set(handles.LeftContactCoordinatesTable,'ForegroundColor',blue);
set(handles.LeftMNITableLabel,'ForegroundColor',blue);
set(handles.LeftMNITableLabel,'String','Left Contacts, MNI coord, not yet reviewed');

if skipManual
    % DISPLAYING with 1=LEFT, 2=RIGHT as this is what corresponds to STEALTH Station
    leftLeadCoordinates = get(handles.RightContactCoordinatesTable,'Data');
    rightLeadCoordinates = get(handles.LeftContactCoordinatesTable,'Data');
    set(handles.ProcessingStepText,'String','Manual reconstruction IGNORED.');
    set(handles.RightContactCoordinatesTable,'Data',rightLeadCoordinates);
    set(handles.RightContactCoordinatesTable,'ForegroundColor',darkGreen);
    set(handles.RightMNITableLabel,'ForegroundColor',darkGreen);
    set(handles.RightMNITableLabel,'String','Right, MNI coord (in Stealth L-R orientation)');
    set(handles.LeftContactCoordinatesTable,'Data',leftLeadCoordinates);
    set(handles.LeftContactCoordinatesTable,'ForegroundColor',darkGreen);
    set(handles.LeftMNITableLabel,'ForegroundColor',darkGreen);
    set(handles.LeftMNITableLabel,'String','Left, MNI coord (in Stealth L-R orientation)');
    set(handles.CurrentText,'String',' ');
    set(handles.TotalCountText,'String',' ');
    OK = true;
    WFK_displayCoordinatesOnSlices(handles);
    return;
end;

if ~strcmp(RightLeadModel,'None') && strcmp(LeftLeadModel,'None')
    sides = 1;  % Right only
elseif strcmp(RightLeadModel,'None') && ~strcmp(LeftLeadModel,'None')
    sides = 2;  % Left only
else
    sides = [1 2];  % Both Right and Left
end;
switch RightLeadModel  % Assumes that both hemisphere's leads are same model
    case {'Medtronic 3387'}
        options.elmodel = 'medtronic_3387';
        options.elspec.matfname = 'medtronic_3387';
        options.elspec.lead_diameter = 1.27;
        options.elspec.lead_color = 0.70;
        options.elspec.contact_length = 1.50;
        options.elspec.contact_diameter = 1.27;
        options.elspec.contact_color = 0.30;
        options.elspec.tip_diameter = 1.27;
        options.elspec.tip_color = 0.70;
        options.elspec.tip_length = 1.50;
        options.elspec.contact_spacing = 1.50;
        options.elspec.numel = 4;
        options.elspec.tipiscontact = 0;
        options.elspec.contactnames = {'K0' 'K1' 'K2' 'K3' 'K8' 'K9' 'K10' 'K11'};
        options.elspec.eldist = 3;
    case {'Medtronic 3389'}
        options.elmodel = 'medtronic_3389';
        options.elspec.matfname = 'medtronic_3389';
        options.elspec.lead_diameter = 1.27;
        options.elspec.lead_color = 0.70;
        options.elspec.contact_length = 1.50;
        options.elspec.contact_diameter = 1.27;
        options.elspec.contact_color = 0.30;
        options.elspec.tip_diameter = 1.27;
        options.elspec.tip_color = 0.70;
        options.elspec.tip_length = 1.50;
        options.elspec.contact_spacing = 0.50;
        options.elspec.numel = 4;
        options.elspec.tipiscontact = 0;
        options.elspec.contactnames = {'K0' 'K1' 'K2' 'K3' 'K8' 'K9' 'K10' 'K11'};
        options.elspec.eldist = 2;
    case {'Medtronic 3391'}
        options.elmodel = 'medtronic_3391';
        options.elspec.matfname = 'medtronic_3391';
        options.elspec.lead_diameter = 1.27;
        options.elspec.lead_color = 0.70;
        options.elspec.contact_length = 3.0;
        options.elspec.contact_diameter = 1.27;
        options.elspec.contact_color = 0.30;
        options.elspec.tip_diameter = 1.27;
        options.elspec.tip_color = 0.70;
        options.elspec.tip_length = 1.50;
        options.elspec.contact_spacing = 4.0;
        options.elspec.numel = 4;
        options.elspec.tipiscontact = 0;
        options.elspec.contactnames = {'K0' 'K1' 'K2' 'K3' 'K8' 'K9' 'K10' 'K11'};
        options.elspec.eldist = 7.0;
    otherwise
        error('TBD -- need to put in elspec for other models of leads');
end;
options.sides = sides;
options.autoimprove = 0;
options.d2.write = 0;
options.d3.write = 0;
options.modality = 2;  % CT
options.patientname = patientName; 
options.root = outRoot;
options.earoot = codePath;
options.prefs.patientdir = patientName;
options.prefs.tranii = 'lpostop_ct.nii';
% eaReconstructionFile = strcat(outDirectory,'\','ea_reconstruction.mat');
options.native = 0;

nSides = max(size(coords_mm));
if (nSides > 0)
    rightLeadCoordinates  = coords_mm{1,1};
    rightTrajectory = trajectory{1,1};
    rightMarkers = markers(1,1);
end;
if (nSides > 1)
    leftLeadCoordinates = coords_mm{1,2};
    leftTrajectory = trajectory{1,2};
    leftMarkers = markers(1,2);
end;

% HERE IS WHERE THE MANUAL RECONSTRUCTION ROUTINE GOES
set(handles.LeftContactsStealthCoordinates,'Data',[]);
set(handles.RightContactsStealthCoordinates,'Data',[]);
fig = figure('Name','Manual Reconstruction');
WFK_manualReconstructionDone = false;
WFK_ea_manualreconstruction(fig,markers,trajectory,options.patientname,options);
timerVal = tic;
elapsedSeconds = 0;
while ~WFK_manualReconstructionDone && elapsedSeconds < 180
    %
    % WFK_manualReconstructionDone is set to true in function ea_endfcn
    % found within WFK_ea_manualreconstruction.m
    % If this never happens, then time out of this while loop after
    % three minutes.
    %
    pause(1.0);
    elapsedSeconds = toc(timerVal);
end;
%
% Manual reconstruction re-writes the eaReconstructionFile,
% so reload it here to display the revised coordinates.
%
if WFK_manualReconstructionDone
    choice = questdlg('Use manual reconstruction (forced co-linearity in MNI space)?', ...
        'Force co-linearity?','Yes','NO','NO');
    if strcmp(choice,'Yes')
        if exist(eaReconstructionFile,'file') == 2
            [coords_mm,trajectory,markers,elmodel,manually_corrected]=ea_load_reconstruction(options);
            nSides = max(size(coords_mm));
            if (nSides > 0)
                rightLead  = coords_mm{1,1};
%                 rightTrajectory = trajectory{1,1};
%                 rightMarkers = markers(1,1);
            end;
            if (nSides > 1)
                leftLead = coords_mm{1,2};
%                 leftTrajectory = trajectory{1,2};
%                 leftMarkers = markers(1,2);
            end;
        end;
        rightLeadCoordinates = leftLead;  % DISPLAYING with 1=LEFT, 2=RIGHT as this is what corresponds to STEALTH Station
        leftLeadCoordinates  = rightLead;  % DISPLAYING with 1=LEFT, 2=RIGHT as this is what corresponds to STEALTH Station
        set(handles.ProcessingStepText,'String','Manual reconstruction DONE.');
    else
        % DISPLAYING with 1=LEFT, 2=RIGHT as this is what corresponds to STEALTH Station
        leftLeadCoordinates = get(handles.RightContactCoordinatesTable,'Data');
        rightLeadCoordinates = get(handles.LeftContactCoordinatesTable,'Data');
        set(handles.ProcessingStepText,'String','Manual reconstruction IGNORED.');
    end;
    set(handles.RightContactCoordinatesTable,'Data',rightLeadCoordinates);
    set(handles.RightContactCoordinatesTable,'ForegroundColor',darkGreen);
    set(handles.RightMNITableLabel,'ForegroundColor',darkGreen);
    set(handles.RightMNITableLabel,'String','Right, MNI coord (in Stealth L-R orientation)');
    set(handles.LeftContactCoordinatesTable,'Data',leftLeadCoordinates);
    set(handles.LeftContactCoordinatesTable,'ForegroundColor',darkGreen);
    set(handles.LeftMNITableLabel,'ForegroundColor',darkGreen);
    set(handles.LeftMNITableLabel,'String','Left, MNI coord (in Stealth L-R orientation)');
    set(handles.CurrentText,'String',' ');
    set(handles.TotalCountText,'String',' ');
    OK = true;
else
    set(handles.RightContactCoordinatesTable,'Data',[]);
    set(handles.LeftContactCoordinatesTable,'Data',[]);
    set(handles.ProcessingStepText,'String','Manual reconstruction timed out.');
    OK = false;
end;
WFK_displayCoordinatesOnSlices(handles);

function OK = step9(handles)
%
%  Get the MNI coordinates from the GUI, backtranslate to Patient space
%  using the saved deformation field in y_ea_normparams_saved.nii, translate
%  to the patient's Stealth coordinates using the midpoint of AC-PC line as
%  the origin, then put the resulting Stealth coordinates into the GUI.
%
global darkGreen;
global outDirectory;
global codePath;
global LeftLeadModel;
global RightLeadModel;
global ACinMNICoord;
global ACinPatientCoord;
global ACinStealthCoord;
global PCinMNICoord;
global PCinPatientCoord;
global PCinStealthCoord;
global AccollaSTNAtlas;
global AccollaSTNAtlasInPatientStealthSpace;
defFN = strcat(outDirectory,'\','y_ea_normparams_saved.nii');
results.leftMNICoordinates = get(handles.LeftContactCoordinatesTable,'Data');
results.rightMNICoordinates = get(handles.RightContactCoordinatesTable,'Data');
set(handles.LeftContactsStealthCoordinates,'Data',[]);
set(handles.RightContactsStealthCoordinates,'Data',[]);
pause on;
pause(0.5);
currentLead = 0;
numLeads = 0;
if ~strcmp(LeftLeadModel,'None')
    numLeads = numLeads + 1;
end;
if ~strcmp(RightLeadModel,'None')
    numLeads = numLeads + 1;
end;
set(handles.TotalCountText,'String',sprintf('%d',numLeads));
%
%  Find the AC, PC, and midpoint (MC) in the Patient's space.
%
%  Note that the AC is NOT at 0,0,0 in the MNI template.
%
% MNIac = [ 0.250   1.298 -5.003]; % from ea_mni2acpc code by lead_dbs
% MNIpc = [-0.188 -24.756 -2.376];
ACinMNICoord = [ 0.250   1.298 -5.003]; % from ea_mni2acpc code by lead_dbs
PCinMNICoord = [-0.188 -24.756 -2.376];
ACinPatientCoord = WFK_applyDeformationField(ACinMNICoord,defFN);
PCinPatientCoord = WFK_applyDeformationField(PCinMNICoord,defFN);
ACinStealthCoord = WFK_transformToStealth(ACinPatientCoord);
PCinStealthCoord = WFK_transformToStealth(PCinPatientCoord);
% These globals are used by the WFK_transformToStealth function.
%
if ~strcmp(LeftLeadModel,'None')
    currentLead = currentLead + 1;
    set(handles.CurrentText,'String',sprintf('Lead %d',currentLead));
    set(handles.ProcessingStepText,'String','Backtranslating LEFT coords');
    pause(0.5);
    leftPatientCoord = WFK_applyDeformationField(results.leftMNICoordinates,defFN);
    leftStealthCoord = WFK_transformToStealth(leftPatientCoord);
    set(handles.LeftContactsStealthCoordinates,'Data',leftStealthCoord);
    results.leftStealthCoordinates = leftStealthCoord;
    set(handles.LeftContactsStealthCoordinates,'ForegroundColor',darkGreen);
    pause(1.0);
end;

if ~strcmp(RightLeadModel,'None')
    currentLead = currentLead + 1;
    set(handles.CurrentText,'String',sprintf('Lead %d',currentLead));
    set(handles.ProcessingStepText,'String','Backtranslating RIGHT coords');
    pause(0.5);
    set(handles.RightContactsStealthCoordinates,'Data',[]);
    rightPatientCoord = WFK_applyDeformationField(results.rightMNICoordinates,defFN);
    rightStealthCoord = WFK_transformToStealth(rightPatientCoord);
    set(handles.RightContactsStealthCoordinates,'Data',rightStealthCoord);
    results.rightStealthCoordinates = rightStealthCoord;
    set(handles.RightContactsStealthCoordinates,'ForegroundColor',darkGreen);
    pause(0.5);
end;
%
% Convert the STN Atlas Regions to Patient Stealth Space
%
fName = strcat(codePath,'atlases\STN-Subdivisions (Accolla 2014)\atlas_index.mat');
load(fName);
AccollaSTNAtlas = atlases;
for hemi = 1:2
    for region = 1:3
        faces = AccollaSTNAtlas.fv{region,hemi}.faces;
        vertices = AccollaSTNAtlas.fv{region,hemi}.vertices;
        transVertices = WFK_applyDeformationField(vertices,defFN);
        transVertices = WFK_transformToStealth(transVertices);
        AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.faces = faces;
        AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.vertices = transVertices;
    end;
end;

set(handles.ProcessingStepText,'String','Backtranslation complete. ');
set(handles.CurrentText,'String',' ');
set(handles.TotalCountText,'String',' ');
set(handles.STEP10,'enable','on');
OK = true;

function OK = step10(handles,unattended)
%  Save the lead coordinates for this patient in both MNI and Stealth
%  coordinates; also save indications of whether various contacts are
%  within the various regions of the STN (using MNI Coordinates).
%  Finally, save the values for AC, MC and PC in MNI space,
%  patient space, and Stealth coordinates (for this patient).
%
%  unattended = true means assume user isn't around to answer question
%  about whether to overwrite any existing file, and just go ahead and
%  overwrite it.
%
global outDirectory;
% global codePath;
% global LeftLeadModel;
% global RightLeadModel;
global ACinMNICoord;
global PCinMNICoord;
global ACinPatientCoord;
global PCinPatientCoord;
global ACinStealthCoord;
global PCinStealthCoord;
global AccollaSTNAtlas;
global AccollaSTNAtlasInPatientStealthSpace;
% defFN = strcat(outDirectory,'\','y_ea_normparams_saved.nii');
[~,patientName,~] = fileparts(outDirectory);
results.patientName = patientName;
results.leftMNICoordinates = get(handles.LeftContactCoordinatesTable,'Data');
results.rightMNICoordinates = get(handles.RightContactCoordinatesTable,'Data');
results.leftStealthCoordinates = get(handles.LeftContactsStealthCoordinates,'Data');
results.rightStealthCoordinates = get(handles.RightContactsStealthCoordinates,'Data');
if isempty(results.rightStealthCoordinates) && isempty(results.leftStealthCoordinates)
    set(handles.ProcessingStepText,'String','Patient coords unavail-nothing saved.');
    set(handles.CurrentText,'String',' ');
    set(handles.TotalCountText,'String',' ');
    set(handles.STEP10,'enable','off');
    OK=false;
else
    fileName = strcat(outDirectory,'\FindContacts_Results');
    fullFileName = strcat(outDirectory,'\FindContacts_Results.mat');
    if ~unattended
        % Don't overwrite an existing file without checking first.
        fid = fopen(fullFileName,'r');
        if (fid ~= -1) % -1 means could not open the file; otherwise, already exists
            choice = questdlg('File already exists.  Overwrite?', ...
                'Overwrite?','Yes','NO','NO');
            if (~strcmp(choice,'Yes'))
                fclose(fid);
                set(handles.ProcessingStepText,'String','File not changed.');
                set(handles.CurrentText,'String',' ');
                set(handles.TotalCountText,'String',' ');
                OK = false;
                return;
            else
                fclose(fid);
            end;
        end;
    end;
    % Determine whether each contact is within or outside various STN
    % regions using the AccollaSTNAtlas.
    %     fName = strcat(codePath,'atlases\STN-Subdivisions (Accolla 2014)\atlas_index.mat');
    %     load(fName);
    %     AccollaSTNAtlas = atlases;
    %
    flipNorms = true;  % this is the case for all the AccollaSTNAtlas regions.
    %
    % FIRST, DO THIS FOR THE MNI COORDINATES AND MNI ATLAS
    %
    leftInside = zeros(4,3);
    hemi = 2; % Using 2=LEFT, 1=RIGHT as this is what corresponds to LEAD-DBS and thus presumably the atlas.
    for contact = 1:4
        x = results.leftMNICoordinates(contact,1);
        y = results.leftMNICoordinates(contact,2);
        z = results.leftMNICoordinates(contact,3);
        for region = 1:3  % 1 = assoc; 2 = limbic; 3 = motor
            faces = AccollaSTNAtlas.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlas.fv{region,hemi}.vertices;
            leftInside(contact,region) = WFK_isContactInRegion(x,y,z,faces,vertices,flipNorms);
        end;
    end;
    results.leftMNIContactInAssocLimbicMotorSTN = leftInside;
    % Now for the right hemisphere.
    rightInside = zeros(4,3);
    hemi = 1; % Using 2=LEFT, 1=RIGHT as this is what corresponds to LEAD-DBS and thus presumably the atlas.
    for contact = 1:4
        x = results.rightMNICoordinates(contact,1);
        y = results.rightMNICoordinates(contact,2);
        z = results.rightMNICoordinates(contact,3);
        for region = 1:3  % 1 = assoc; 2 = limbic; 3 = motor
            faces = AccollaSTNAtlas.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlas.fv{region,hemi}.vertices;
            rightInside(contact,region) = WFK_isContactInRegion(x,y,z,faces,vertices,flipNorms);
        end;
    end;
    results.rightMNIContactInAssocLimbicMotorSTN = rightInside;
    %
    % NOW, DO IT AGAIN FOR THE STEALTH COORDINATES, USING THE ATLAS 
    % THAT WAS PREVIOUSLY CONVERTED TO STEALTH SPACE (see step9).
    %
    leftInside = zeros(4,3);
    hemi = 2; % Using 2=LEFT, 1=RIGHT as this is what corresponds to LEAD-DBS and thus presumably the atlas.
    for contact = 1:4
        x = results.leftStealthCoordinates(contact,1);
        y = results.leftStealthCoordinates(contact,2);
        z = results.leftStealthCoordinates(contact,3);
        for region = 1:3  % 1 = assoc; 2 = limbic; 3 = motor
            faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.vertices;
            leftInside(contact,region) = WFK_isContactInRegion(x,y,z,faces,vertices,flipNorms);
        end;
    end;
    results.leftStealthContactInAssocLimbicMotorSTN = leftInside;
    % Now for the right hemisphere.
    rightInside = zeros(4,3);
    hemi = 1; % Using 2=LEFT, 1=RIGHT as this is what corresponds to LEAD-DBS and thus presumably the atlas.
    for contact = 1:4
        x = results.rightStealthCoordinates(contact,1);
        y = results.rightStealthCoordinates(contact,2);
        z = results.rightStealthCoordinates(contact,3);
        for region = 1:3  % 1 = assoc; 2 = limbic; 3 = motor
            faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.vertices;
            rightInside(contact,region) = WFK_isContactInRegion(x,y,z,faces,vertices,flipNorms);
        end;
    end;
    results.rightStealthContactInAssocLimbicMotorSTN = rightInside;
    %     %
    %     %  Also get and store (for saving out in our results structure) the so-called "native" coordinates
    %     %  and the so-called ACPC coordinates from the lead-dbs reco structure.
    %     %
    %     reconstructionFileName = strcat(outDirectory,'\ea_reconstruction.mat');
    %     load(reconstructionFileName);
    %     if isfield(reco,'native');
    %         if ~strcmp(LeftLeadModel,'None')
    %             results.leftNativeCoordinates = reco.native.coords_mm{1,1};
    %             % Using 1=LEFT, 2=RIGHT as this is what corresponds to STEALTH Station
    %         end;
    %         if ~strcmp(RightLeadModel,'None')
    %             results.rightNativeCoordinates = reco.native.coords_mm{1,2};
    %             % Using 1=LEFT, 2=RIGHT as this is what corresponds to STEALTH Station
    %         end;
    %     else
    %         results.leftNativeCoordinates = [];
    %         results.rightNativeCoordinates = [];
    %     end;
    %     if isfield(reco,'ACPC');
    %         if ~strcmp(LeftLeadModel,'None')
    %             results.leftACPCCoordinates = reco.ACPC.coords_mm{1,1};
    %             % Using 1=LEFT, 2=RIGHT as this is what corresponds to STEALTH Station
    %         end;
    %         if ~strcmp(RightLeadModel,'None')
    %             results.rightACPCCoordinates = reco.ACPC.coords_mm{1,2};
    %             % Using 1=LEFT, 2=RIGHT as this is what corresponds to STEALTH Station
    %         end;
    %     else
    %         results.leftACPCCoordinates = [];
    %         results.rightACPCCoordinates = [];
    %     end;
    
    %
    %  Save the AC, PC, and midpoint (MC) in the Patient's space,
    %  and in Stealth coordinates (patient space with MC as origin and
    %  AC-PC line colinear with y-axis).
    %
    %  Note that the AC is NOT at 0,0,0 in the MNI template.
    %
    results.ACinMNICoord = ACinMNICoord;
    results.PCinMNICoord = PCinMNICoord;
    results.MCinMNICoord = (ACinMNICoord + PCinMNICoord) / 2.0;
    results.ACinPatientCoord = ACinPatientCoord;
    results.PCinPatientCoord = PCinPatientCoord;
    results.MCinPatientCoord = (results.ACinPatientCoord + results.PCinPatientCoord)/2.0;
    results.ACinStealthCoord = ACinStealthCoord;
    results.PCinStealthCoord = PCinStealthCoord;
    MCinStealthCoord = (ACinStealthCoord + PCinStealthCoord)/2.0;
    % Set very small absolute values to zero.
    MCinStealthCoord(abs(MCinStealthCoord)<1.0e-14) = 0;
    results.MCinStealthCoord = MCinStealthCoord;
    results.AccollaSTNAtlasInPatientStealthSpace = AccollaSTNAtlasInPatientStealthSpace;
    %
    %  Write out the  results structure.
    %
    save(fileName,'results');
    msg = strcat(fileName,'.mat written.');
    set(handles.ReloadResults,'enable','on');
    if length(msg) > 150
        trunc = msg(end-150:end);
        msg = strcat('...',trunc);
    end;
    set(handles.ExpectedCompletionTime,'String',msg);
    set(handles.ProcessingStepText,'String','Results written.');
    set(handles.CurrentText,'String',' ');
    set(handles.TotalCountText,'String',' ');
    set(handles.STEP10,'enable','off');
    OK = true;
end

function OK = step11(handles)
%
%  Create and display a 3-D view
%  of the leads shown along with the STN regions, using
%  the MNI space.
%  
global codePath;
global outDirectory;
global LeftLeadModel;
global RightLeadModel;
global AccollaSTNAtlas;
global showAssociativeSTN;
global showLimbicSTN;
global showMotorSTN;
% regions using the AccollaSTNAtlas.
fName = strcat(codePath,'atlases\STN-Subdivisions (Accolla 2014)\atlas_index.mat');
load(fName);
AccollaSTNAtlas = atlases;
fig = figure('Name','MNI Space','Toolbar','none','Units','normalized','OuterPosition',[0.25,0.15,0.4,0.8]);
toolBar = uitoolbar(fig);
assoc = zeros(16,16,3);
assoc(:,:,3) = 1;  % blue
showAssociativeSTN = uitoggletool(toolBar,'CData',assoc,'TooltipString','Toggle Associative STN');
showAssociativeSTN.State = 'on';
showAssociativeSTN.OnCallback = @toggleAssociativeSTN;
showAssociativeSTN.OffCallback = @toggleAssociativeSTN;
limbic = zeros(16,16,3);
limbic(:,:,2) = 1;  % green
showLimbicSTN = uitoggletool(toolBar,'CData',limbic,'TooltipString','Toggle Limbic STN');
showLimbicSTN.State = 'on';
showLimbicSTN.OnCallback = @toggleLimbicSTN;
showLimbicSTN.OffCallback = @toggleLimbicSTN;
motor = zeros(16,16,3);
motor(:,:,1) = 1;  % red
showMotorSTN = uitoggletool(toolBar,'CData',motor,'TooltipString','Toggle Motor STN');
showMotorSTN.State = 'on';
showMotorSTN.OnCallback = @toggleMotorSTN;
showMotorSTN.OffCallback = @toggleMotorSTN;
a = ones(19,19,3);
viewCoronal = uipushtool(toolBar,'CData',a*0,'TooltipString','Coronal View');
viewCoronal.ClickedCallback = @viewpointCoronal;
viewSagittal = uipushtool(toolBar,'CData',a*0.33,'TooltipString','Sagittal View');
viewSagittal.ClickedCallback = @viewpointSagittal;
viewHorizontal = uipushtool(toolBar,'CData',a*0.66,'TooltipString','Horizontal View');
viewHorizontal.ClickedCallback = @viewpointHorizontal;
drawAxes(fig);
stealth = false;  % flag to indicate whether atlas convertion from MNI to Stealth Coordinates is to be done.
displayAssociativeSTN(fig,stealth);
displayLimbicSTN(fig,stealth);
displayMotorSTN(fig,stealth);
if ~strcmp(LeftLeadModel,'None') && strcmp(RightLeadModel,'None')
    sides = 1;  % LEFT only, Using 1=LEFT, 2=RIGHT as this is what corresponds to Stealth Station and GUI display.
elseif strcmp(LeftLeadModel,'None') && ~strcmp(RightLeadModel,'None')
    sides = 2;  % RIGHT only, Using 1=LEFT, 2=RIGHT as this is what corresponds to Stealth Station and GUI display.
else
    sides = [1 2];  % Both Right and Left
end;
for side = sides
    drawLead(fig,stealth,side,handles);
end;
% 
% Now superimpose the registered and warped post-op CT (lpostop_ct.nii);
%
options.d3.verbose = 'on';
options.native = 0;
options.macaquemodus = 0;
[outroot,patientName] = fileparts(outDirectory);
options.root = strcat(outroot,'\');
options.patientname = patientName;
options.prefs.tranii = 'lpostop_ct.nii';
options.earoot = codePath;
% 
% ea_anatomycontrol(fig,options);
%
set(handles.ProcessingStepText,'String','3D plot displayed.');
OK = true;

function OK = step12(handles)
%
%  Create and display a 3-D view
%  of the leads shown along with the STN regions, using
%  the patient's Stealth space.  This involves backtranslating
%  the STN patches (i.e., the vertices in the faces / vertices data structure) 
%  using the patient's deformation field.
%
%  For now, this uses the same code (subroutines) as the MNI coordinate
%  version (see step11(handles), adding a flag "stealth" to indicate that
%  the lead and atlas patches are to be in Stealth coordinates, not MNI
%  coordinates.  In the future, this probably should have its own dedicated
%  code so that the two figures can be displayed simultaneously without
%  entanglement of the code, which could be buggy.  -- WFK  August 29, 2016
%  
global codePath;
global outDirectory;
global LeftLeadModel;
global RightLeadModel;
global AccollaSTNAtlas;
global showAssociativeSTN;
global showLimbicSTN;
global showMotorSTN;
% regions using the AccollaSTNAtlas.
fName = strcat(codePath,'atlases\STN-Subdivisions (Accolla 2014)\atlas_index.mat');
load(fName);
AccollaSTNAtlas = atlases;
fig = figure('Name','Patient''s Stealth Space','Toolbar','none','Units','normalized','OuterPosition',[0.25,0.15,0.4,0.8]);
toolBar = uitoolbar(fig);
assoc = zeros(16,16,3);
assoc(:,:,3) = 1;  % blue
showAssociativeSTN = uitoggletool(toolBar,'CData',assoc,'TooltipString','Toggle Associative STN');
showAssociativeSTN.State = 'on';
showAssociativeSTN.OnCallback = @toggleAssociativeSTN;
showAssociativeSTN.OffCallback = @toggleAssociativeSTN;
limbic = zeros(16,16,3);
limbic(:,:,2) = 1;  % green
showLimbicSTN = uitoggletool(toolBar,'CData',limbic,'TooltipString','Toggle Limbic STN');
showLimbicSTN.State = 'on';
showLimbicSTN.OnCallback = @toggleLimbicSTN;
showLimbicSTN.OffCallback = @toggleLimbicSTN;
motor = zeros(16,16,3);
motor(:,:,1) = 1;  % red
showMotorSTN = uitoggletool(toolBar,'CData',motor,'TooltipString','Toggle Motor STN');
showMotorSTN.State = 'on';
showMotorSTN.OnCallback = @toggleMotorSTN;
showMotorSTN.OffCallback = @toggleMotorSTN;
a = ones(19,19,3);
viewCoronal = uipushtool(toolBar,'CData',a*0,'TooltipString','Coronal View');
viewCoronal.ClickedCallback = @viewpointCoronal;
viewSagittal = uipushtool(toolBar,'CData',a*0.33,'TooltipString','Sagittal View');
viewSagittal.ClickedCallback = @viewpointSagittal;
viewHorizontal = uipushtool(toolBar,'CData',a*0.66,'TooltipString','Horizontal View');
viewHorizontal.ClickedCallback = @viewpointHorizontal;
drawAxes(fig);
stealth = true;
displayAssociativeSTN(fig,stealth);
displayLimbicSTN(fig,stealth);
displayMotorSTN(fig,stealth);
if ~strcmp(LeftLeadModel,'None') && strcmp(RightLeadModel,'None')
    sides = 1;  % LEFT only, Using 1=LEFT, 2=RIGHT as this is what corresponds to Stealth Station and GUI display.
elseif strcmp(LeftLeadModel,'None') && ~strcmp(RightLeadModel,'None')
    sides = 2;  % RIGHT only, Using 1=LEFT, 2=RIGHT as this is what corresponds to Stealth Station and GUI display.
else
    sides = [1 2];  % Both Right and Left
end;
for side = sides
    drawLead(fig,stealth,side,handles);
end;
% 
% Now superimpose the original, registered post-op CT (rpostop_ct.nii);
%
options.d3.verbose = 'on';
options.native = 0;
options.macaquemodus = 0;
[outroot,patientName] = fileparts(outDirectory);
options.root = strcat(outroot,'\');
options.patientname = patientName;
options.prefs.tranii = 'rpostop_ct.nii';
options.earoot = codePath;
% 
% ea_anatomycontrol(fig,options);
%
set(handles.ProcessingStepText,'String','3D Stealth plot displayed.');
OK = true;


function drawLead(fig,stealth,side,handles)
global AccollaSTNAtlas;
global AccollaSTNAtlasInPatientStealthSpace;
global outDirectory;
fullFileName = strcat(outDirectory,'\FindContacts_Results.mat');
load(fullFileName);
defFN = strcat(outDirectory,'\','y_ea_normparams_saved.nii');
figure(fig);
if side == 1
    if stealth
        Coords = get(handles.LeftContactsStealthCoordinates,'Data');
    else
        Coords = get(handles.LeftContactCoordinatesTable,'Data');
    end;
    hemi = 2;  % for atlas
else
    if stealth
        Coords = get(handles.RightContactsStealthCoordinates,'Data');
    else
        Coords = get(handles.RightContactCoordinatesTable,'Data');
    end;
    hemi = 1;
end;
x = Coords(:,1);
y = Coords(:,2);
z = Coords(:,3);
% Plot each contact with an indication of whether it is inside an STN
% region.
flipNorms = true;
for contact = 1:4
    contactX = x(contact);
    contactY = y(contact);
    contactZ = z(contact);
    markerStr = '-o';
    markerSz = 5;
    color = [0 0 0];
    for region = 1:3
        if stealth
            faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.vertices;
        else
            faces = AccollaSTNAtlas.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlas.fv{region,hemi}.vertices;
        end;
        inside = WFK_isContactInRegion(contactX,contactY,contactZ,faces,vertices,flipNorms);
        if inside
            markerStr = '-*';
            markerSz = 8;
            switch region
                case {1}
                    color = [0 0 1];
                case {2}
                    color = [0 1 0];
                case {3}
                    color = [1 0 0];
                otherwise
                    color = [0.5 0.5 0.5];
            end;
            break;
        end;
    end;
    plot3(contactX,contactY,contactZ,markerStr,'Color',color,'LineWidth',1.5,'MarkerSize',markerSz);
end;
%
% plot extension to represent the lead body
%
xx(1) = Coords(1,1);
yy(1) = Coords(1,2);
zz(1) = Coords(1,3);
multiple = 3;
xx(2) = xx(1) + (multiple * (x(4) - x(1)));
yy(2) = yy(1) + (multiple * (y(4) - y(1)));
zz(2) = zz(1) + (multiple * (z(4) - z(1)));
plot3(xx,yy,zz,'-','Color',color','LineWidth',0.5);
    
function drawAxes(fig)
figure(fig);
hold on;
X = [-20 0 20];
Y = [0 0 0];
Z = [0 0 0];
plot3(X,Y,Z,'-k');
X = [0 0 0];
Y = [5 0 -20];
Z = [0 0 0];
plot3(X,Y,Z,'-b');
X = [0 0 0];
Y = [0 0 0];
Z = [-15 0 5];
plot3(X,Y,Z,'-r');
xlabel('< -L -- lateral -- R+ >','Color','k');
ylabel('< -P -- AP -- A+ >','Color','b');
zlabel('< -I -- SI -- S+ >','Color','r');
rotate3d 'on';
viewpoint = [-45 45];  % oblique
view(viewpoint);

function toggleAssociativeSTN(toggle,action)
global leftAssociativePatch;
global rightAssociativePatch;
if strcmp(action.EventName,'On')
    set(leftAssociativePatch,'Visible','on');
    set(rightAssociativePatch,'Visible','on');
end;
if strcmp(action.EventName,'Off')
    set(leftAssociativePatch,'Visible','off');
    set(rightAssociativePatch,'Visible','off');
end;
    
function toggleLimbicSTN(toggle,action)
global leftLimbicPatch;
global rightLimbicPatch;
if strcmp(action.EventName,'On')
    set(leftLimbicPatch,'Visible','on');
    set(rightLimbicPatch,'Visible','on');
end;
if strcmp(action.EventName,'Off')
    set(leftLimbicPatch,'Visible','off');
    set(rightLimbicPatch,'Visible','off');
end;

function toggleMotorSTN(toggle,action)
global leftMotorPatch;
global rightMotorPatch;
if strcmp(action.EventName,'On')
    set(leftMotorPatch,'Visible','on');
    set(rightMotorPatch,'Visible','on');
end;
if strcmp(action.EventName,'Off')
    set(leftMotorPatch,'Visible','off');
    set(rightMotorPatch,'Visible','off');
end;

function viewpointCoronal(button,action)
coronal = [0 0];
view(coronal);

function viewpointSagittal(button,action)
coronal = [90 0];
view(coronal);

function viewpointHorizontal(button,action)
coronal = [0 90];
view(coronal);

function displayAssociativeSTN(fig,stealth)
%
% Associative area
%
global AccollaSTNAtlas;
global AccollaSTNAtlasInPatientStealthSpace;
global leftAssociativePatch;
global rightAssociativePatch;
% global outDirectory;
% fullFileName = strcat(outDirectory,'\FindContacts_Results.mat');
% load(fullFileName);
% defFN = strcat(outDirectory,'\','y_ea_normparams_saved.nii');
region = 1;
faceColor = [0 0 1]; % blue
figure(fig);
if stealth
    leftAssociativeFaces = AccollaSTNAtlasInPatientStealthSpace.fv{region,1}.faces;
    leftAssociativeVertices = AccollaSTNAtlasInPatientStealthSpace.fv{region,1}.vertices;
else
    leftAssociativeFaces = AccollaSTNAtlas.fv{region,1}.faces;
    leftAssociativeVertices = AccollaSTNAtlas.fv{region,1}.vertices;
end;
leftAssociativePatch = patch('Vertices',leftAssociativeVertices,'Faces',leftAssociativeFaces, ...
    'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
    'AmbientStrength', 0.15, 'Clipping','on', ...
    'FaceAlpha', 0.1, 'HandleVisibility','off');
material('dull');
%
if stealth
    rightAssociativeFaces = AccollaSTNAtlasInPatientStealthSpace.fv{region,2}.faces;
    rightAssociativeVertices = AccollaSTNAtlasInPatientStealthSpace.fv{region,2}.vertices;
else
    rightAssociativeFaces = AccollaSTNAtlas.fv{region,2}.faces;
    rightAssociativeVertices = AccollaSTNAtlas.fv{region,2}.vertices;
end;
rightAssociativePatch = patch('Vertices',rightAssociativeVertices,'Faces',rightAssociativeFaces, ...
    'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
    'AmbientStrength', 0.15, 'Clipping','on', ...
    'FaceAlpha', 0.1, 'HandleVisibility','off');
material('dull');

function displayLimbicSTN(fig,stealth)
%
% Limbic area
%
global AccollaSTNAtlas;
global AccollaSTNAtlasInPatientStealthSpace;
global leftLimbicPatch;
global rightLimbicPatch;
% global outDirectory;
% fullFileName = strcat(outDirectory,'\FindContacts_Results.mat');
% load(fullFileName);
% defFN = strcat(outDirectory,'\','y_ea_normparams_saved.nii');
region = 2;
faceColor = [0 1 0]; % green
figure(fig);
if stealth
    leftLimbicFaces = AccollaSTNAtlasInPatientStealthSpace.fv{region,1}.faces;
    leftLimbicVertices = AccollaSTNAtlasInPatientStealthSpace.fv{region,1}.vertices;
else
    leftLimbicFaces = AccollaSTNAtlas.fv{region,1}.faces;
    leftLimbicVertices = AccollaSTNAtlas.fv{region,1}.vertices;
end;
leftLimbicPatch = patch('Vertices',leftLimbicVertices,'Faces',leftLimbicFaces, ...
    'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
    'AmbientStrength', 0.15, 'Clipping','on', ...
    'FaceAlpha', 0.1, 'HandleVisibility','off');
material('dull');
%
if stealth
    rightLimbicFaces = AccollaSTNAtlasInPatientStealthSpace.fv{region,2}.faces;
    rightLimbicVertices = AccollaSTNAtlasInPatientStealthSpace.fv{region,2}.vertices;
else
    rightLimbicFaces = AccollaSTNAtlas.fv{region,2}.faces;
    rightLimbicVertices = AccollaSTNAtlas.fv{region,2}.vertices;
end;
rightLimbicPatch = patch('Vertices',rightLimbicVertices,'Faces',rightLimbicFaces, ...
    'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
    'AmbientStrength', 0.15, 'Clipping','on', ...
    'FaceAlpha', 0.1, 'HandleVisibility','off');
material('dull');


function displayMotorSTN(fig,stealth)
%
% Motor area
%
global AccollaSTNAtlas;
global AccollaSTNAtlasInPatientStealthSpace;
global leftMotorPatch;
global rightMotorPatch;
% global outDirectory;
% fullFileName = strcat(outDirectory,'\FindContacts_Results.mat');
% load(fullFileName);
% defFN = strcat(outDirectory,'\','y_ea_normparams_saved.nii');
figure(fig);
faceColor = [1 0 0]; % red
if stealth
    leftMotorFaces = AccollaSTNAtlasInPatientStealthSpace.fv{3,1}.faces;
    leftMotorVertices = AccollaSTNAtlasInPatientStealthSpace.fv{3,1}.vertices;
else
    leftMotorFaces = AccollaSTNAtlas.fv{3,1}.faces;
    leftMotorVertices = AccollaSTNAtlas.fv{3,1}.vertices;
end;
leftMotorPatch = patch('Vertices',leftMotorVertices,'Faces',leftMotorFaces, ...
    'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
    'AmbientStrength', 0.15, 'Clipping','on', ...
    'FaceAlpha', 0.1, 'HandleVisibility','off');
material('dull');
%
if stealth
    rightMotorFaces = AccollaSTNAtlasInPatientStealthSpace.fv{3,2}.faces;
    rightMotorVertices = AccollaSTNAtlasInPatientStealthSpace.fv{3,2}.vertices;
else
    rightMotorFaces = AccollaSTNAtlas.fv{3,2}.faces;
    rightMotorVertices = AccollaSTNAtlas.fv{3,2}.vertices;
end;
rightMotorPatch = patch('Vertices',rightMotorVertices,'Faces',rightMotorFaces, ...
    'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
    'AmbientStrength', 0.15, 'Clipping','on', ...
    'FaceAlpha', 0.1, 'HandleVisibility','off');
material('dull');

% --- Executes on button press in STEP1.
function STEP1_Callback(hObject, eventdata, handles)
% hObject    handle to STEP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.DICOMtoNIITime,'String','---');
timerVal = tic;
OK = step1(handles);
if ~OK
    error('Step1 failed.');
else
    elapsedSeconds = toc(timerVal);
    set(handles.DICOMtoNIITime,'String',sprintf('%6.2f',elapsedSeconds/60));
end;

% --- Executes on button press in STEP2.
function STEP2_Callback(hObject, eventdata, handles)
% hObject    handle to STEP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.InterpolateMRTime,'String','---');
timerVal = tic;
OK = step2(handles);
if ~OK
    error('Step2 failed.');
else
    elapsedSeconds = toc(timerVal);
    set(handles.InterpolateMRTime,'String',sprintf('%6.2f',elapsedSeconds/60));
end;

% --- Executes on button press in STEP3.
function STEP3_Callback(hObject, eventdata, handles)
% hObject    handle to STEP3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.CTRegistrationTime,'String','---');
timerVal = tic;
OK = step3(handles);
if ~OK
    error('Step3 failed.');
else
    elapsedSeconds = toc(timerVal);
    set(handles.CTRegistrationTime,'String',sprintf('%6.2f',elapsedSeconds/60));
end;

% --- Executes on button press in STEP4.
function STEP4_Callback(hObject, eventdata, handles)
% hObject    handle to STEP4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.NormalizationTime,'String','---');
timerVal = tic;
OK = step4(handles);
if ~OK
    error('Step4 failed.');
else
    elapsedSeconds = toc(timerVal);
    set(handles.NormalizationTime,'String',sprintf('%6.2f',elapsedSeconds/60));
end;

% --- Executes on button press in STEP5.
function STEP5_Callback(hObject, eventdata, handles)
% hObject    handle to STEP5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ApplyNormTime,'String','---');
timerVal = tic;
OK = step5(handles);
if ~OK
    error('Step5 failed.');
else
    elapsedSeconds = toc(timerVal);
    set(handles.ApplyNormTime,'String',sprintf('%6.2f',elapsedSeconds/60));
end;

% --- Executes on button press in STEP6.
function STEP6_Callback(hObject, eventdata, handles)
% hObject    handle to STEP7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.LeadReconstructionTime,'String','---');
timerVal = tic;
OK = step6(handles);
if ~OK
    error('Step5 failed.');
else
    elapsedSeconds = toc(timerVal);
    set(handles.LeadReconstructionTime,'String',sprintf('%6.2f',elapsedSeconds/60));
end;

% --- Executes on button press in STEP7.
function STEP7_Callback(hObject, eventdata, handles)
% hObject    handle to STEP9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ContactIDTime,'String','---');
timerVal = tic;
OK = step7(handles);
if ~OK
    error('Step7 failed.');
else
    elapsedSeconds = toc(timerVal);
    set(handles.ContactIDTime,'String',sprintf('%6.2f',elapsedSeconds/60));
end;

% --- Executes on button press in STEP8.
function STEP8_Callback(hObject, eventdata, handles)
% hObject    handle to STEP9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
skipManual = false;
OK = step8(handles,skipManual);

% --- Executes on button press in STEP9.
function STEP9_Callback(hObject, eventdata, handles)
% hObject    handle to STEP9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OK = step9(handles);

% --- Executes on button press in STEP10.
function STEP10_Callback(hObject, eventdata, handles)
% hObject    handle to STEP10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
unattended = false;
OK = step10(handles,unattended);

% --- Executes on button press in STEP11.
function STEP11_Callback(hObject, eventdata, handles)
% hObject    handle to STEP11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OK = step11(handles);

% --- Executes on button press in STEP12.
function STEP12_Callback(hObject, eventdata, handles)
% hObject    handle to STEP12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OK = step12(handles);

% --- Executes on button press in ShowCoregistration.
function ShowCoregistration_Callback(hObject, eventdata, handles)
% hObject    handle to ShowCoregistration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global outDirectory;
global softGreen;
global gray;
set(handles.ShowCoregistration,'enable','off');
set(handles.ShowCoregistration,'BackgroundColor',[240 240 240]/255);
anatFileName =         strcat(outDirectory,'\',      'anat.nii');
registeredCTFileName = strcat(outDirectory,'\','rpostop_ct.nii');
if (exist(anatFileName,'file') == 2) && ...
        (exist(registeredCTFileName,'file') == 2)
    set(handles.ShowCoregistration,'String','OK,takes ~15-30 sec');
    pause on;
    pause(0.1); % give button label a chance to update
    fig = figure('Name','Co-registration of CT (green) to MR (pink).');
    WFK_ea_show_ctcoregistration(fig);
    set(handles.ShowCoregistration,'enable','on');
    set(handles.ShowCoregistration,'BackgroundColor',softGreen);
    set(handles.ShowCoregistration,'String','Show coregistration');
else
    set(handles.ShowCoregistration,'enable','off');
    set(handles.ShowCoregistration,'BackgroundColor',gray);
    set(handles.ShowCoregistration,'String','Files not found.')
    pause on;
    pause(2.0);
end;

% --- Executes on button press in ShowNormalization.
function ShowNormalization_Callback(hObject, eventdata, handles)
% hObject    handle to ShowNormalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global outDirectory;
global codePath;
global softGreen;
global gray;
set(handles.ShowNormalization,'enable','off');
set(handles.ShowNormalization,'BackgroundColor',[240 240 240]/255);
% [outRoot,~,~] = fileparts(outDirectory);
% outRoot = strcat(outRoot,'\');
mniWiresFileName = strcat(codePath,'templates\mni_wires.nii');
warpedMRFileName = strcat(outDirectory,'\','glanat.nii');
if (exist(mniWiresFileName,'file') == 2) && ...
        (exist(warpedMRFileName,'file') == 2)
    set(handles.ShowNormalization,'String','OK, takes ~15 sec');
    pause on;
    pause(0.5); % give button label a chance to update
    % fig = figure('Name','Normalization of patient to MNI wire frame.');
    WFK_ea_show_normalization(warpedMRFileName,mniWiresFileName);
    set(handles.ShowNormalization,'enable','on');
    set(handles.ShowNormalization,'BackgroundColor',softGreen);
    set(handles.ShowNormalization,'String','Show normalization');
else
    set(handles.ShowNormalization,'enable','off');
    set(handles.ShowNormalization,'BackgroundColor',gray);
    set(handles.ShowNormalization,'String','Files not found.')
    pause on;
    pause(2.0);
end;

function bool = ResultsExist()
%
%  Answer true if the results file for this patient exists in the expected
%  directory with the expected name.
%
global outDirectory;
fullFileName = strcat(outDirectory,'\FindContacts_Results.mat');
fid = fopen(fullFileName,'r');
if (fid == -1) % -1 means could not open the file.
    bool = false;
else
    bool = true;
    fclose(fid);
end;

% --- Executes on button press in ReloadResults.
function ReloadResults_Callback(hObject, eventdata, handles)
% hObject    handle to ReloadResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%  Look up coords in ea_reconstruction.mat and display.
%
global darkGreen;
global outDirectory;
global ACinPatientCoord;
global PCinPatientCoord;
% global LeftLeadModel;
% global RightLeadModel;
set(handles.ProcessingStepText,'String','Reloading results.');
set(handles.CurrentText,'String',' ');
set(handles.TotalCountText,'String',' ');
pause on;
pause(0.5);  % let display update.
fileExists = ResultsExist();
if ~fileExists
    set(handles.ProcessingStepText,'String','FindContacts_Results.mat not found.');
    set(handles.CurrentText,'String',' ');
    set(handles.TotalCountText,'String',' ');
    return;
end;
fullFileName = strcat(outDirectory,'\FindContacts_Results.mat');
load(fullFileName);
set(handles.LeftContactCoordinatesTable,'Data',results.leftMNICoordinates);
set(handles.RightContactCoordinatesTable,'Data',results.rightMNICoordinates);
set(handles.LeftContactsStealthCoordinates,'Data',results.leftStealthCoordinates);
set(handles.RightContactsStealthCoordinates,'Data',results.rightStealthCoordinates);
set(handles.LeftContactCoordinatesTable,'ForegroundColor',darkGreen);
set(handles.RightContactCoordinatesTable,'ForegroundColor',darkGreen);
set(handles.LeftContactsStealthCoordinates,'ForegroundColor',darkGreen);
set(handles.RightContactsStealthCoordinates,'ForegroundColor',darkGreen);
ACinPatientCoord = results.ACinPatientCoord;
PCinPatientCoord= results.PCinPatientCoord;
set(handles.ProcessingStepText,'String','Reloading results...done.');
set(handles.CurrentText,'String',' ');
set(handles.TotalCountText,'String',' ');


% --- Executes on button press in Step8Bypass.
function Step8Bypass_Callback(hObject, eventdata, handles)
% hObject    handle to Step8Bypass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
skipManual = true;
OK = step8(handles,skipManual);

% --- Executes on button press in RunAllStepsButton.
function RunAllStepsButton_Callback(hObject, eventdata, handles)
% hObject    handle to RunAllStepsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%  The goal of FindContacts is to find the coordinates of the contacts of
%  the DBS leads in a patient given the patient's pre-operative MRI and
%  post-operative CT.  The procedure is based on the methods used in the
%  LEAD-DBS toolbox, with some modifications to make the processing as
%  automatic as possible (ie., with the least amount of user intervention
%  and fewest manual steps).
%
%  The steps in the processing are as follows:
%  1) Convert the patient's DICOM images to Nifty format (.nii files)
%  2) Reslice the pre-operative MR file (anat.nii).
%  3) Co-register the post-operative CT to the pre-operative MRI using the
%     BrainFit routine.
%  4) Normalize the post-operative CT to MNI coordinate space using the SPM
%     DARTEL function to find the deformation field.
%  5) Apply the deformation field to the MRI and CT files.
%  6) Identify the likely trajectories of the leads in the CT based on the
%     artifact caused by the leads in the CT imaging.
%  7) Identify the likely contact locations in the lead trajectories by 
%     looking for the "donut holes" in the artifact caused by the ring
%     electrodes.
%  8) Skip the manual review, and just relabel the left lead and right lead 
%     coordinates so that the coordinates with positive X-axis values are identified
%     as being for the right lead, and the coordinates with negative X-axis
%     values are identified as being for the left lead.
%  9) Back-translate the MNI coordinates to patient Stealth space.
% 10) Write the results to the FindContacts_Results.mat file in the folder
%     for this patient.
%
%   -- Bill Kaemmerer, September 20, 2016
%
set(handles.RunButton,'enable','off');
set(handles.RunAllStepsButton,'enable','off');
set(handles.RunAllStepsButton,'BackgroundColor',[255 102 102]/255);
set(handles.RunAllStepsButton,'String','(running all steps)');
set(handles.TotalRunTime,'String',' --- ');
set(handles.STEP1,'enable','off');
set(handles.STEP2,'enable','off');
set(handles.STEP3,'enable','off');
set(handles.STEP4,'enable','off');
set(handles.STEP5,'enable','off');
set(handles.STEP6,'enable','off');
set(handles.STEP7,'enable','off');
set(handles.STEP8,'enable','off');
set(handles.Step8Bypass','enable','off');
set(handles.STEP9,'enable','off');
set(handles.STEP10,'enable','off');
set(handles.STEP11,'enable','off');
set(handles.STEP12,'enable','off');
timerVal = tic;
STEP1_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP2_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP3_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP4_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP5_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP6_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP7_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
Step8Bypass_Callback(hObject,eventdata,handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
STEP9_Callback(hObject, eventdata, handles);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
unattended = true;
step10(handles,unattended);
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
set(handles.STEP1,'enable','on');
set(handles.STEP2,'enable','on');
set(handles.STEP3,'enable','on');
set(handles.STEP4,'enable','on');
set(handles.STEP5,'enable','on');
set(handles.STEP6,'enable','on');
set(handles.STEP7,'enable','on');
set(handles.STEP8,'enable','on');
set(handles.Step8Bypass','enable','on');
set(handles.STEP9,'enable','on');
set(handles.STEP10,'enable','on');
set(handles.STEP11,'enable','on');
set(handles.STEP12,'enable','on');
set(handles.RunButton,'enable','on');
set(handles.RunAllStepsButton,'enable','on');
set(handles.RunAllStepsButton,'BackgroundColor',[0 209 0]/255);
set(handles.RunAllStepsButton,'String','Run All Steps');
elapsedSeconds = toc(timerVal);
set(handles.TotalRunTime,'String',sprintf('%6.2f minutes',elapsedSeconds/60));
set(handles.ProcessingStepText,'String','RunAllSteps DONE!');


% --- Executes on button press in ProcessMultiplePatientsButton.
function ProcessMultiplePatientsButton_Callback(hObject, eventdata, handles)
% hObject    handle to ProcessMultiplePatientsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
global outDirectory;
%  Get parent folder from user.
parentPatientDirectory = uigetdir();
if (parentPatientDirectory == 0)  % User cancelled, didn't choose a folder.
    return;
end;
numChar = length(parentPatientDirectory);  % length of the name of the directory
if numChar < 18
    displayName = parentPatientDirectory;
else
    displayName = strcat(parentPatientDirectory(1:5),'...',parentPatientDirectory(end-10:end));
end;
set(handles.ParentFolder,'String',displayName);
%  Get list of patients that are within the parent folder.
patientFolders = dir(parentPatientDirectory);
numPotential = length(patientFolders) - 2; % don't count the '.' and '..' directory entries
patientList = cell(1,1);  % just start small
msgDicoms = cell(numPotential,1);  % to report to user patients missing DICOM directories.
msgLeads = cell(numPotential,1); % to report to user patients missing lead info.
numPatients = 0;
numMissingDicoms = 0;
numMissingLeadInfo = 0;
for i = 1:numPotential
    if (patientFolders(i+2).isdir) % be sure this is a patient folder
        outDirectory = strcat(parentPatientDirectory,'\',patientFolders(i+2).name);
        [~,patientName,~] = fileparts(outDirectory);
        OKDicoms = dicomDirectoriesExist(outDirectory);
        if ~OKDicoms
            numMissingDicoms = numMissingDicoms + 1;
            msgDicoms{numMissingDicoms,1} = sprintf('%s is missing DICOM/MR or DICOM/CT',patientName);
        end;
        justChecking = true;
        OKLeads = readLeadModels(handles,justChecking,patientName);
        if ~OKLeads
            numMissingLeadInfo = numMissingLeadInfo + 1;
            msgLeads{numMissingLeadInfo,1} = sprintf('%s is missing LeadModels.xlsx file with correct patient name.',patientName);
        end;
        if (OKDicoms && OKLeads)
            numPatients = numPatients + 1;
            patientList{numPatients,1} = outDirectory;
        end;
    end;
end;
if numMissingDicoms > 0
 popUpSpot = [20 100 700 400];
    missingDicomPopUp = figure('MenuBar','none','Name','Patients missing DICOM/MR or DICOM/CT','Position',popUpSpot);
    uitable('Parent',missingDicomPopUp,'ColumnName',{'Patient'},'Data',msgDicoms,...
        'ColumnWidth',{500},'Position',[30 60 550 300]);
end;
if numMissingLeadInfo > 0
popUpSpot = [30 150 700 400];
    missingLeadInfoPopUp = figure('MenuBar','none','Name','Patients missing LeadInfo.xlsx with expected patient name','Position',popUpSpot);
    uitable('Parent',missingLeadInfoPopUp,'ColumnName',{'Patient'},'Data',msgLeads,...
        'ColumnWidth',{500},'Position',[30 60 550 300]);
end;
msg1 = sprintf('Out of %d patient folders found, %d = ready for processing, %d = missing DICOMs, %d = missing LeadModels.xlsx; Proceed?',...
    numPotential, numPatients, numMissingDicoms, numMissingLeadInfo);
choice = questdlg(msg1, ...
    'Proceed?','YES','No','YES');
if (~strcmp(choice,'YES'))
    return;
end;
batchTimer = tic();  % start timer for the whole batch run
if numMissingDicoms > 0
    close(missingDicomPopUp);
end;
if numMissingLeadInfo > 0
    close(missingLeadInfoPopUp);
end;
set(handles.SelectOutputFolder,'enable','off');
set(handles.RunButton,'enable','off');
set(handles.RunAllStepsButton,'enable','off');
numSuccess = 0;
numFailures = 0;
msgSuccessOrFailure = cell(numPatients,3);
set(handles.TotalNumberOfPatients,'String',sprintf('%d',numPatients));
for pt = 1:numPatients
    resetGUI(handles);
    patientTimer = tic();  % start timer for this patient
    outDirectory = patientList{pt,1};
    [~,patientName,~] = fileparts(outDirectory);
    set(handles.outputFolder,'String',patientName);
    set(handles.CurrentPatientNumber,'String',sprintf('%d',pt));
    try
        justChecking = false;
        OK = readLeadModels(handles,justChecking,patientName);
        % pause on;  % for test purposes only
        % pause(3.0);
        if OK
            RunAllStepsButton_Callback(hObject, eventdata, handles);
            msgSuccessOrFailure{pt,1} = patientName;
            msgSuccessOrFailure{pt,2} = 'Successfully completed';
            numSuccess = numSuccess + 1;
        else
            msgSuccessOrFailure{pt,1} = patientName;
            msgSuccessOrFailure{pt,2} = 'Failed -- LeadModels.xlsx for this patient not found.';
            numFailures = numFailures + 1;
        end;
    catch
        msgSuccessOrFailure{pt,1} = patientName;
        msgSuccessOrFailure{pt,2} = 'Failed -- something went wrong.';
        numFailures = numFailures + 1;
    end;
    elapsedSeconds = toc(patientTimer);
    msgSuccessOrFailure(pt,3) = {sprintf('%6.2f minutes',elapsedSeconds/60)};
end;
popUpSpot = [200 200 700 400];
report = figure('MenuBar','none','Name','Results of batch run:','Position',popUpSpot);
uitable('Parent',report,'ColumnName',{'Patient','Outcome','Run time'},'Data',msgSuccessOrFailure,...
    'ColumnWidth',{200,200,200},'Position',[30 60 650 300]);
set(handles.SelectOutputFolder,'enable','on');
set(handles.RunButton,'enable','on');
set(handles.RunAllStepsButton,'enable','on');
elapsedSeconds = toc(batchTimer);
msg = sprintf('All done.  Total batch run time = %6.2f minutes.  Close everything?',elapsedSeconds/60);
choice = questdlg(msg, ...
    'Close this application?','YES','No','YES');
if (strcmp(choice,'YES'))
    close all force;
end;

function resetGUI(handles)
% Clear any previous patient's data from the screen
set(handles.LeftContactCoordinatesTable,'Data',[]);
set(handles.RightContactCoordinatesTable,'Data',[]);
set(handles.LeftContactsStealthCoordinates,'Data',[]);
set(handles.RightContactsStealthCoordinates,'Data',[]);
set(handles.ProcessingStepText,'String',' ');
set(handles.CurrentText,'String',' ');
set(handles.TotalCountText,'String',' ');
set(handles.DICOMtoNIITime,'String',' ');
set(handles.InterpolateMRTime,'String',' ');
set(handles.CTRegistrationTime,'String',' ');
set(handles.NormalizationTime,'String',' ');
set(handles.ApplyNormTime,'String',' ');
set(handles.LeadReconstructionTime,'String',' ');
set(handles.ContactIDTime,'String',' ');
set(handles.TotalRunTime,'String',' ');
subplot(4,7, 7, 'align' ); axis off; cla;
subplot(4,7,14, 'align' ); axis off; cla;
subplot(4,7,21, 'align' ); axis off; cla;
subplot(4,7,28, 'align' ); axis off; cla;
subplot(4,7, 6, 'align' ); axis off; cla;
subplot(4,7,13, 'align' ); axis off; cla;
subplot(4,7,20, 'align' ); axis off; cla;
subplot(4,7,27, 'align' ); axis off; cla;

function OK = dicomDirectoriesExist(outDirectory)
% Answer true if /DICOM/MR and /DICOM/CT exist as subfolders
% of the outDirectory provided.
MR = strcat(outDirectory,'/DICOM/MR');
CT = strcat(outDirectory,'/DICOM/CT');
ansMR = exist(MR,'dir');  % returns 7 if the directory is found.
ansCT = exist(CT,'dir');  % returns 7 if the directory is found.
OK = (ansMR == 7) && (ansCT == 7);

function CurrentPatientNumber_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentPatientNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentPatientNumber as text
%        str2double(get(hObject,'String')) returns contents of CurrentPatientNumber as a double


% --- Executes during object creation, after setting all properties.
function CurrentPatientNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentPatientNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function TotalNumberOfPatients_Callback(hObject, eventdata, handles)
% hObject    handle to TotalNumberOfPatients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TotalNumberOfPatients as text
%        str2double(get(hObject,'String')) returns contents of TotalNumberOfPatients as a double


% --- Executes during object creation, after setting all properties.
function TotalNumberOfPatients_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalNumberOfPatients (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function OK = readLeadModels(handles,justChecking,patientName)
% Check to see if the current patient's leadModels can be read from the
% expected Excel file in the outDirectory.  If so, return OK == true.
% If justChecking == true, then don't actually set the global variables and
% the GUI radio buttons.  But if justChecking == false, do set the globals
% and the radio buttons as well.
global outDirectory;
global LeftLeadModel;
global RightLeadModel;
OKLeft = false;
OKRight = false;
leadModelsFileName = strcat(outDirectory,'\','LeadModels.xlsx');
% check to see if this patient's leadModels can be obtained from an expected Excel file
fid = fopen(leadModelsFileName,'r');
if ~(fid == -1)
    fclose(fid);
    [~,txt,~] = xlsread(leadModelsFileName,'B1:B3');
    patientNameFromFile = txt{1,1};
    if ~strcmp(patientNameFromFile,patientName);
        OK = false;
        return;
    end;
    leftLeadModel = txt{2,1};
    rightLeadModel = txt{3,1};
    switch leftLeadModel
        case {'3387'}
            if ~justChecking
                LeftLeadModel = 'Medtronic 3387';
                set(handles.LeftLeadButtonGroup,'SelectedObject',handles.Left3387);
            end;
            OKLeft = true;
        case {'3389'}
            if ~justChecking
                LeftLeadModel = 'Medtronic 3389';
                set(handles.LeftLeadButtonGroup,'SelectedObject',handles.Left3389);
            end;
            OKLeft = true;
        case {'None'}
            if ~justChecking
                LeftLeadModel = 'None';
                set(handles.LeftLeadButtonGroup,'SelectedObject',handles.LeftNone);
            end;
            OKLeft = true;
        otherwise
            OKLeft = false;
    end;
    switch rightLeadModel
        case {'3387'}
            if ~justChecking
            RightLeadModel = 'Medtronic 3387';
            set(handles.RightLeadButtonGroup,'SelectedObject',handles.Right3387);
            end;
            OKRight = true;
        case {'3389'}
            if ~justChecking
            RightLeadModel = 'Medtronic 3389';
            set(handles.RightLeadButtonGroup,'SelectedObject',handles.Right3389);
            end;
            OKRight = true;
        case {'None'}
            if ~justChecking
            RightLeadModel = 'None';
            set(handles.RightLeadButtonGroup,'SelectedObject',handles.RightNone);
            end;
            OKRight = true;
        otherwise
            OKRight = false;
    end;
end;
OK = OKLeft && OKRight;
