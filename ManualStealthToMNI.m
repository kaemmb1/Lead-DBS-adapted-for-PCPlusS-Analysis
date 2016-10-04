function varargout = ManualStealthToMNI(varargin)
% MANUALSTEALTHTOMNI MATLAB code for ManualStealthToMNI.fig
%      MANUALSTEALTHTOMNI, by itself, creates a new MANUALSTEALTHTOMNI or raises the existing
%      singleton*.
%
%      H = MANUALSTEALTHTOMNI returns the handle to a new MANUALSTEALTHTOMNI or the handle to
%      the existing singleton*.
%
%      MANUALSTEALTHTOMNI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANUALSTEALTHTOMNI.M with the given input arguments.
%
%      MANUALSTEALTHTOMNI('Property','Value',...) creates a new MANUALSTEALTHTOMNI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ManualStealthToMNI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ManualStealthToMNI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ManualStealthToMNI

% Last Modified by GUIDE v2.5 04-Oct-2016 12:54:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ManualStealthToMNI_OpeningFcn, ...
                   'gui_OutputFcn',  @ManualStealthToMNI_OutputFcn, ...
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

% --- Executes just before ManualStealthToMNI is made visible.
function ManualStealthToMNI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ManualStealthToMNI (see VARARGIN)

% Choose default command line output for ManualStealthToMNI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global codePath;  % directory root for ext_libs\BRAINSFit\
% [codePath,codeFolder,~] = fileparts(pwd); -- a future possibility
codePath = 'C:\WFK\lead_dbs_extracts\';
global ReadyToRun;
ReadyToRun = false;
% global PatientFolderName;
% PatientFolderName = [];
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
global darkRed;
gray = [240 240 240]/255;
darkGray = [96 96 96]/255;
brightGreen = [51 204 0]/255;
darkGreen = [0 148 0]/255;
softGreen = [193 221 198]/255;
blue = [0 0 1];
darkRed = [148 0 0]/255;
global unsavedResults;
unsavedResults = false;

% --- Outputs from this function are returned to the command line.
function varargout = ManualStealthToMNI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function StatusText_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function StatusText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in SelectOutputFolder.
function SelectOutputFolder_Callback(hObject, eventdata, handles)
% hObject    handle to SelectOutputFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global outDirectory;
outDirectory = uigetdir();
if (outDirectory == 0)  % user cancelled operation
    set(handles.StatusText,'String','Patient folder selection cancelled.');
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
justChecking = false;
readLeadModels(handles,justChecking,patientName);
reloadResults(handles)
checkReadyToRun(handles);

function checkReadyToRun(handles)
% Verify we have what we need to do the translation of coordinates
% from Stealth space to MNI space, using this patient's deformation field.
%
global darkGreen;
global gray;
global darkRed;
global outDirectory;
global defFN;
defFN = strcat(outDirectory,'\','y_ea_inv_normparams_saved.nii');
fid = fopen(defFN,'r');
if (fid > 0)
    fclose(fid);
    set(handles.ReadManualStealthCoordinatesFromFile,'BackgroundColor',darkGreen);
    set(handles.ReadManualStealthCoordinatesFromFile,'enable','on');
    set(handles.ConvertToMNICoordinates,'BackgroundColor',gray);
    set(handles.ConvertToMNICoordinates,'enable','off');
else
    set(handles.StatusText,'String','Could not open required deformation field file for this patient.');
    set(handles.ReadManualStealthCoordinatesFromFile,'enable','off');
    set(handles.ConvertToMNICoordinates,'BackgroundColor',darkRed);
    set(handles.ConvertToMNICoordinates,'enable','off');
end;

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

function reloadResults(handles)
%
%  Load results from FindContacts_Results.mat.
%
global outDirectory;
global ACinPatientCoord;
global PCinPatientCoord;
global results;
set(handles.StatusText,'String','Reloading results.');
pause on;
pause(0.5);  % let display update.
fileExists = resultsExist();
if ~fileExists
    set(handles.StatusText,'String','FindContacts_Results.mat not found.');
    return;
end;
fullFileName = strcat(outDirectory,'\FindContacts_Results.mat');
load(fullFileName);
ACinPatientCoord = results.ACinPatientCoord;
PCinPatientCoord= results.PCinPatientCoord;
[~,patientName,~] = fileparts(outDirectory);
msg = sprintf('OK, reloaded results for %s from %s.',patientName,fullFileName);
set(handles.StatusText,'String',msg);
% outputOriginalStealthCoord();  % TEMPORARY FOR DEVELOPMENT PURPOSES ONLY

function outputOriginalStealthCoord()
% For development purposes:  this function outputs the MNI and stealth coordinates
% (from lead-dbs, not the manual coordinates) with high decimal place precision to 
% a text file (.csv) for reading into an Excel spreadsheet and comparing to
% other calculations.  Specifically, it can be seen that the stealth
% coordinates from the lead-dbs, when, translated back to MNI coordinates
% via the WFK_transformToMNI(coprd) and WFK_applyDeformationField(coord,defFromStealth)
% functions as in ConvertToMNICoordinates_Callback (see below) results in
% the computedMNI coordinates disagreeing with the original MNI coordinates
% by less than or equal to 0.0619 mm on the Left and less than or equal to
% 0.1681 mm on the Right, in the case of patient ahebb-a15j.
% 
global results;
global outDirectory;
fileN = strcat(outDirectory,'\temp.csv');
fid = fopen(fileN,'w');
coord = results.leftStealthCoordinates;
fprintf(fid,'Left Stealth Coordinates\n');
for r = 1:4
    for c = 1:3
        fprintf(fid,'%30.20f,',coord(r,c));
    end;
    fprintf(fid,'\n');
end;
coord = results.rightStealthCoordinates;
fprintf(fid,'Right Stealth Coordinates\n');
for r = 1:4
    for c = 1:3
        fprintf(fid,'%30.20f,',coord(r,c));
    end;
    fprintf(fid,'\n');
end;
coord = results.leftMNICoordinates;
fprintf(fid,'Left MNI Coordinates\n');
for r = 1:4
    for c = 1:3
        fprintf(fid,'%30.20f,',coord(r,c));
    end;
    fprintf(fid,'\n');
end;
coord = results.rightMNICoordinates;
fprintf(fid,'Right MNI Coordinates\n');
for r = 1:4
    for c = 1:3
        fprintf(fid,'%30.20f,',coord(r,c));
    end;
    fprintf(fid,'\n');
end;
fclose(fid);

function bool = resultsExist()
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

function resetGUI(handles)
global gray;
global unsavedResults;
set(handles.LeftContactsStealthCoordinates,'Data',[]);
set(handles.RightContactsStealthCoordinates,'Data',[]);
set(handles.LeftContactsMNICoordinates,'Data',[]);
set(handles.RightContactsMNICoordinates,'Data',[]);
set(handles.ReadManualStealthCoordinatesFromFile,'BackgroundColor',gray);
set(handles.ReadManualStealthCoordinatesFromFile,'enable','off');
set(handles.ConvertToMNICoordinates,'BackgroundColor',gray);
set(handles.ConvertToMNICoordinates,'enable','off');
set(handles.ConvertToMNICoordinates,'BackgroundColor',gray);
set(handles.ConvertToMNICoordinates,'enable','off');
set(handles.SaveToPatientsResultsFile,'BackgroundColor',gray);
set(handles.SaveToPatientsResultsFile,'enable','off');
set(handles.STEP11,'enable','off');
set(handles.STEP12,'enable','off');
unsavedResults = false;

% --- Executes on button press in ReadManualStealthCoordinatesFromFile.
function ReadManualStealthCoordinatesFromFile_Callback(hObject, eventdata, handles)
% hObject    handle to ReadManualStealthCoordinatesFromFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%  THIS IS JUST A STUB FOR NOW
%  CURRENTLY, READS MNI COORDS FROM RESULTS;
%  IN FUTURE, SHOULD READ STEALTH COORDS FROM A FILE.
%
global darkGreen;
global outDirectory;
[~,patientName,~] = fileparts(outDirectory);
filterSpec = strcat(outDirectory,'\','*.xlsx');
[FileName,PathName,FilterIndex] = uigetfile(filterSpec,...
    sprintf('Select the Excel file containing manual Stealth coordinates for %s.',patientName));
if (FilterIndex == 0)  % means the user cancelled the operation
    set(handles.StatusText,'String','File selection cancelled.');
    return;
end;
[num,txt,~] = xlsread(strcat(PathName,FileName));
expectedKeyword = 'Manual Stealth Coordinates';
keyword = txt{1,1};
if ~strcmp(keyword,expectedKeyword)
    msg = sprintf('"%s" (without quotes) expected to be in top left cell of spreadsheet; %s found instead.',expectedKeyword,keyword);
    set(handles.StatusText,'String',msg);
    return;
end;
patientNameFromFile = txt{1,3};
if ~strcmp(patientNameFromFile,patientName);
    msg = sprintf('Patient name read from file was %s and not %s',patientNameFromFile,patientName);
    set(handles.StatusText,'String',msg);
    return;
end;
leftCoordinates = num(1:4,1:3);
rightCoordinates = num(1:4,5:7); % skip over the labels column that yields NaNs
set(handles.LeftContactsStealthCoordinates,'Data',leftCoordinates);
set(handles.RightContactsStealthCoordinates,'Data',rightCoordinates);
set(handles.LeftContactsStealthCoordinates,'ForegroundColor',darkGreen);
set(handles.RightContactsStealthCoordinates,'ForegroundColor',darkGreen);
set(handles.ConvertToMNICoordinates,'BackgroundColor',darkGreen);
set(handles.ConvertToMNICoordinates,'enable','on');
msg = sprintf('OK, Manual Stealth coordinates read for %s from %s.',patientName,FileName);
set(handles.StatusText,'String',msg);
set(handles.STEP12,'enable','on'); % STEP12 = Stealth, STEP11 = MNI
%
%  Go ahead and "press the ConvertToMNICoordinates" for the user; the
%  button on the screen still has a purpose, since the user may wish to
%  manually edit the Stealth Coordinates on the GUI screen, and then
%  convert them.
%
ConvertToMNICoordinates_Callback(hObject, eventdata, handles);
%  Automatically calling the following is OK, as it will not
%  overwrite a previously existing file of results without user permission.
SaveToPatientsResultsFile_Callback(hObject, eventdata, handles);


% --- Executes on button press in ConvertToMNICoordinates.
function ConvertToMNICoordinates_Callback(hObject, eventdata, handles)
% hObject    handle to ConvertToMNICoordinates (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
%  THIS IS JUST A STUB FOR NOW, converts from MNI coordinates to
%  patient's stealth coordinates.
%  In the future, this should convert from manual stealth coordinates
%  to MNI coordinates using the reverse of this transformation.
%
global darkGreen;
global outDirectory;
global LeftLeadModel;
global RightLeadModel;
global ACinMNICoord;
global ACinPatientCoord;
global ACinStealthCoord;
global PCinMNICoord;
global PCinPatientCoord;
global PCinStealthCoord;
global unsavedResults;
defFromMNI = strcat(outDirectory,'\','y_ea_normparams_saved.nii');
defFromStealth = strcat(outDirectory,'\','y_ea_inv_normparams_saved.nii');
% Get the coordinates to be converted from the GUI screen.
leftStealthCoordinates = get(handles.LeftContactsStealthCoordinates,'Data');
rightStealthCoordinates = get(handles.RightContactsStealthCoordinates,'Data');
pause on;
pause(0.1);
%
%  Find the AC, PC, and midpoint (MC) in the Patient's space.
%
%  Note that the AC is NOT at 0,0,0 in the MNI template.
%
% MNIac = [ 0.250   1.298 -5.003]; % from ea_mni2acpc code by lead_dbs
% MNIpc = [-0.188 -24.756 -2.376];
ACinMNICoord = [ 0.250   1.298 -5.003]; % from ea_mni2acpc code by lead_dbs
PCinMNICoord = [-0.188 -24.756 -2.376];
ACinPatientCoord = WFK_applyDeformationField(ACinMNICoord,defFromMNI);
PCinPatientCoord = WFK_applyDeformationField(PCinMNICoord,defFromMNI);
ACinStealthCoord = WFK_transformToStealth(ACinPatientCoord);
PCinStealthCoord = WFK_transformToStealth(PCinPatientCoord);
%
% The above globals are used by the WFK_transformToStealth function.
%
if ~strcmp(LeftLeadModel,'None')
    set(handles.StatusText,'String','Translating LEFT coords');
    pause(0.1);
    leftPatientCoord = WFK_transformToMNI(leftStealthCoordinates);
    leftMNICoord = WFK_applyDeformationField(leftPatientCoord,defFromStealth);
    set(handles.LeftContactsMNICoordinates,'Data',leftMNICoord);
    set(handles.LeftContactsMNICoordinates,'ForegroundColor',darkGreen);
    pause(0.1);
end;

if ~strcmp(RightLeadModel,'None')
    set(handles.StatusText,'String','Translating RIGHT coords');
    pause(0.1);
    rightPatientCoord = WFK_transformToMNI(rightStealthCoordinates);
    rightMNICoord = WFK_applyDeformationField(rightPatientCoord,defFromStealth);
    set(handles.RightContactsMNICoordinates,'Data',rightMNICoord);
    set(handles.RightContactsMNICoordinates,'ForegroundColor',darkGreen);
    pause(0.1);
end;
set(handles.StatusText,'String','Translation completed.');
unsavedResults = true;
pause(0.1);
set(handles.SaveToPatientsResultsFile,'BackgroundColor',darkGreen);
set(handles.SaveToPatientsResultsFile,'enable','on');
set(handles.STEP11,'enable','on');  % STEP12 = Stealth, STEP11 = MNI

% --- Executes on button press in SaveToPatientsResultsFile.
function SaveToPatientsResultsFile_Callback(hObject, eventdata, handles)
% hObject    handle to SaveToPatientsResultsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%  This function puts the current contents of the GUI tables into the
%  results structure, and saves the results to a new file of results for
%  this patient.
%
global codePath;
global unsavedResults;
global outDirectory;
global results;
global AccollaSTNAtlasInPatientStealthSpace;
global AccollaSTNAtlas;
AccollaSTNAtlasInPatientStealthSpace = results.AccollaSTNAtlasInPatientStealthSpace;
fName = strcat(codePath,'atlases\STN-Subdivisions (Accolla 2014)\atlas_index.mat');
load(fName);
AccollaSTNAtlas = atlases;
results.leftManualStealthCoordinates = get(handles.LeftContactsStealthCoordinates,'Data');
results.rightManualStealthCoordinates = get(handles.RightContactsStealthCoordinates,'Data');
results.leftManualMNICoordinates = get(handles.LeftContactsMNICoordinates,'Data');
results.rightManualMNICoordinates = get(handles.RightContactsMNICoordinates,'Data');
if isempty(results.leftManualMNICoordinates) && isempty(results.rightManualMNICoordinates)
    set(handles.StatusText,'String','Patient coords unavail-nothing saved.');
else
    [~,patientName,~] = fileparts(outDirectory);
    fullFileName = strcat(outDirectory,'\Updated_FindContacts_Results.mat');
    % Don't overwrite an existing file without checking first.
    fid = fopen(fullFileName,'r');
    if (fid ~= -1) % -1 means could not open the file; otherwise, already exists
        msg = sprintf('An Updated_FindContacts_Results.mat for %s already exists.  Overwrite?',patientName);
        choice = questdlg(msg, ...
            'Overwrite?','Yes','NO','NO');
        if (~strcmp(choice,'Yes'))
            fclose(fid);
            set(handles.StatusText,'String','File not changed.');
            return;
        else
            fclose(fid);
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
        x = results.leftManualMNICoordinates(contact,1);
        y = results.leftManualMNICoordinates(contact,2);
        z = results.leftManualMNICoordinates(contact,3);
        for region = 1:3  % 1 = assoc; 2 = limbic; 3 = motor
            faces = AccollaSTNAtlas.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlas.fv{region,hemi}.vertices;
            leftInside(contact,region) = WFK_isContactInRegion(x,y,z,faces,vertices,flipNorms);
        end;
    end;
    results.leftManualMNIContactInAssocLimbicMotorSTN = leftInside;
    % Now for the right hemisphere.
    rightInside = zeros(4,3);
    hemi = 1; % Using 2=LEFT, 1=RIGHT as this is what corresponds to LEAD-DBS and thus presumably the atlas.
    for contact = 1:4
        x = results.rightManualMNICoordinates(contact,1);
        y = results.rightManualMNICoordinates(contact,2);
        z = results.rightManualMNICoordinates(contact,3);
        for region = 1:3  % 1 = assoc; 2 = limbic; 3 = motor
            faces = AccollaSTNAtlas.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlas.fv{region,hemi}.vertices;
            rightInside(contact,region) = WFK_isContactInRegion(x,y,z,faces,vertices,flipNorms);
        end;
    end;
    results.rightManualMNIContactInAssocLimbicMotorSTN = rightInside;
    %
    % NOW, DO IT AGAIN FOR THE STEALTH COORDINATES, USING THE ATLAS 
    % THAT WAS PREVIOUSLY CONVERTED TO STEALTH SPACE (see step9).
    %
    leftInside = zeros(4,3);
    hemi = 2; % Using 2=LEFT, 1=RIGHT as this is what corresponds to LEAD-DBS and thus presumably the atlas.
    for contact = 1:4
        x = results.leftManualStealthCoordinates(contact,1);
        y = results.leftManualStealthCoordinates(contact,2);
        z = results.leftManualStealthCoordinates(contact,3);
        for region = 1:3  % 1 = assoc; 2 = limbic; 3 = motor
            faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.vertices;
            leftInside(contact,region) = WFK_isContactInRegion(x,y,z,faces,vertices,flipNorms);
        end;
    end;
    results.leftManualStealthContactInAssocLimbicMotorSTN = leftInside;
    % Now for the right hemisphere.
    rightInside = zeros(4,3);
    hemi = 1; % Using 2=LEFT, 1=RIGHT as this is what corresponds to LEAD-DBS and thus presumably the atlas.
    for contact = 1:4
        x = results.rightManualStealthCoordinates(contact,1);
        y = results.rightManualStealthCoordinates(contact,2);
        z = results.rightManualStealthCoordinates(contact,3);
        for region = 1:3  % 1 = assoc; 2 = limbic; 3 = motor
            faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.faces;
            vertices = AccollaSTNAtlasInPatientStealthSpace.fv{region,hemi}.vertices;
            rightInside(contact,region) = WFK_isContactInRegion(x,y,z,faces,vertices,flipNorms);
        end;
    end;
    results.rightManualStealthContactInAssocLimbicMotorSTN = rightInside;
    %
    %  Write out the  results structure.
    %
    fileName = strcat(outDirectory,'\Updated_FindContacts_Results');
    save(fileName,'results');
    msg = strcat(fileName,'.mat written.');
    if length(msg) > 100
        trunc = msg(end-100:end);
        msg = strcat(msg(1:10),'...',trunc);
    end;
    set(handles.StatusText,'String',msg);
    unsavedResults = false;
end


% *************************************************************************
% Start of CODE RETAINED FROM FindContacts.m
%**************************************************************************

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
% global AccollaSTNAtlas;
global showAssociativeSTN;
global showLimbicSTN;
global showMotorSTN;
% regions using the AccollaSTNAtlas.
% fName = strcat(codePath,'atlases\STN-Subdivisions (Accolla 2014)\atlas_index.mat');
% load(fName);
% AccollaSTNAtlas = atlases;
[~,patientName,~] = fileparts(outDirectory);
title = sprintf('MNI Space - patient %s',patientName);
fig = figure('Name',title,'Toolbar','none','Units','normalized','OuterPosition',[0.25,0.15,0.4,0.8],...
    'WindowStyle','normal');
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
set(handles.StatusText,'String','3D plot displayed.');
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
% global AccollaSTNAtlas;
global showAssociativeSTNStealth;
global showLimbicSTNStealth;
global showMotorSTNStealth;
% regions using the AccollaSTNAtlas.
% fName = strcat(codePath,'atlases\STN-Subdivisions (Accolla 2014)\atlas_index.mat');
% load(fName);
% AccollaSTNAtlas = atlases;
[~,patientName,~] = fileparts(outDirectory);
title = sprintf('Patient''s Stealth Space - patient %s',patientName);
fig = figure('Name',title,'Toolbar','none','Units','normalized','OuterPosition',[0.15,0.15,0.4,0.8],...
    'WindowStyle','normal');
toolBar = uitoolbar(fig);
assoc = zeros(16,16,3);
assoc(:,:,3) = 1;  % blue
showAssociativeSTNStealth = uitoggletool(toolBar,'CData',assoc,'TooltipString','Toggle Associative STN');
showAssociativeSTNStealth.State = 'on';
showAssociativeSTNStealth.OnCallback = @toggleAssociativeSTNStealth;
showAssociativeSTNStealth.OffCallback = @toggleAssociativeSTNStealth;
limbic = zeros(16,16,3);
limbic(:,:,2) = 1;  % green
showLimbicSTNStealth = uitoggletool(toolBar,'CData',limbic,'TooltipString','Toggle Limbic STN');
showLimbicSTNStealth.State = 'on';
showLimbicSTNStealth.OnCallback = @toggleLimbicSTNStealth;
showLimbicSTNStealth.OffCallback = @toggleLimbicSTNStealth;
motor = zeros(16,16,3);
motor(:,:,1) = 1;  % red
showMotorSTNStealth = uitoggletool(toolBar,'CData',motor,'TooltipString','Toggle Motor STN');
showMotorSTNStealth.State = 'on';
showMotorSTNStealth.OnCallback = @toggleMotorSTNStealth;
showMotorSTNStealth.OffCallback = @toggleMotorSTNStealth;
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
set(handles.StatusText,'String','3D Stealth plot displayed.');
OK = true;

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

function drawLead(fig,stealth,side,handles)
global AccollaSTNAtlas;
global AccollaSTNAtlasInPatientStealthSpace;
% global outDirectory;
% fullFileName = strcat(outDirectory,'\FindContacts_Results.mat');
% load(fullFileName);
% defFN = strcat(outDirectory,'\','y_ea_normparams_saved.nii');
figure(fig);
if side == 1
    if stealth
        Coords = get(handles.LeftContactsStealthCoordinates,'Data');
    else
        Coords = get(handles.LeftContactsMNICoordinates,'Data');
    end;
    hemi = 2;  % for atlas
else
    if stealth
        Coords = get(handles.RightContactsStealthCoordinates,'Data');
    else
        Coords = get(handles.RightContactsMNICoordinates,'Data');
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

function toggleAssociativeSTNStealth(toggle,action)
global leftAssociativePatchStealth;
global rightAssociativePatchStealth;
if strcmp(action.EventName,'On')
    set(leftAssociativePatchStealth,'Visible','on');
    set(rightAssociativePatchStealth,'Visible','on');
end;
if strcmp(action.EventName,'Off')
    set(leftAssociativePatchStealth,'Visible','off');
    set(rightAssociativePatchStealth,'Visible','off');
end;
    
function toggleLimbicSTNStealth(toggle,action)
global leftLimbicPatchStealth;
global rightLimbicPatchStealth;
if strcmp(action.EventName,'On')
    set(leftLimbicPatchStealth,'Visible','on');
    set(rightLimbicPatchStealth,'Visible','on');
end;
if strcmp(action.EventName,'Off')
    set(leftLimbicPatchStealth,'Visible','off');
    set(rightLimbicPatchStealth,'Visible','off');
end;

function toggleMotorSTNStealth(toggle,action)
global leftMotorPatchStealth;
global rightMotorPatchStealth;
if strcmp(action.EventName,'On')
    set(leftMotorPatchStealth,'Visible','on');
    set(rightMotorPatchStealth,'Visible','on');
end;
if strcmp(action.EventName,'Off')
    set(leftMotorPatchStealth,'Visible','off');
    set(rightMotorPatchStealth,'Visible','off');
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
global leftAssociativePatchStealth;
global rightAssociativePatchStealth;
region = 1;
left = 1;
right = 2;
faceColor = [0 0 1]; % blue
figure(fig);
if stealth
    faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,left}.faces;
    verts = AccollaSTNAtlasInPatientStealthSpace.fv{region,left}.vertices;
    leftAssociativePatchStealth = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
    faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,right}.faces;
    verts = AccollaSTNAtlasInPatientStealthSpace.fv{region,right}.vertices;
    rightAssociativePatchStealth = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
else
    faces = AccollaSTNAtlas.fv{region,left}.faces;
    verts = AccollaSTNAtlas.fv{region,left}.vertices;
    leftAssociativePatch = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
    faces = AccollaSTNAtlas.fv{region,right}.faces;
    verts = AccollaSTNAtlas.fv{region,right}.vertices;
    rightAssociativePatch = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
end;

function displayLimbicSTN(fig,stealth)
%
% Limbic area
%
global AccollaSTNAtlas;
global AccollaSTNAtlasInPatientStealthSpace;
global leftLimbicPatch;
global rightLimbicPatch;
global leftLimbicPatchStealth;
global rightLimbicPatchStealth;
region = 2;
left = 1;
right = 2;
faceColor = [0 1 0]; % green
figure(fig);
if stealth
    faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,left}.faces;
    verts = AccollaSTNAtlasInPatientStealthSpace.fv{region,left}.vertices;
    leftLimbicPatchStealth = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
    faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,right}.faces;
    verts = AccollaSTNAtlasInPatientStealthSpace.fv{region,right}.vertices;
    rightLimbicPatchStealth = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
else
    faces = AccollaSTNAtlas.fv{region,left}.faces;
    verts = AccollaSTNAtlas.fv{region,left}.vertices;
    leftLimbicPatch = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
    faces = AccollaSTNAtlas.fv{region,right}.faces;
    verts = AccollaSTNAtlas.fv{region,right}.vertices;
    rightLimbicPatch = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
end;

function displayMotorSTN(fig,stealth)
%
% Motor area
%
global AccollaSTNAtlas;
global AccollaSTNAtlasInPatientStealthSpace;
global leftMotorPatch;
global rightMotorPatch;
global leftMotorPatchStealth;
global rightMotorPatchStealth;
region = 3;
left = 1;
right = 2;
faceColor = [1 0 0]; % red
figure(fig);
if stealth
    faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,left}.faces;
    verts = AccollaSTNAtlasInPatientStealthSpace.fv{region,left}.vertices;
    leftMotorPatchStealth = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
    faces = AccollaSTNAtlasInPatientStealthSpace.fv{region,right}.faces;
    verts = AccollaSTNAtlasInPatientStealthSpace.fv{region,right}.vertices;
    rightMotorPatchStealth = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
else
    faces = AccollaSTNAtlas.fv{region,left}.faces;
    verts = AccollaSTNAtlas.fv{region,left}.vertices;
    leftMotorPatch = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
    faces = AccollaSTNAtlas.fv{region,right}.faces;
    verts = AccollaSTNAtlas.fv{region,right}.vertices;
    rightMotorPatch = patch('Vertices',verts,'Faces',faces, ...
        'FaceColor',faceColor,'EdgeColor','none','FaceLighting','gouraud', ...
        'AmbientStrength', 0.15, 'Clipping','on', ...
        'FaceAlpha', 0.1, 'HandleVisibility','off');
    material('dull');
end;

%
% *************************************************************************
% END of CODE RETAINED FROM FindContacts.m
%**************************************************************************


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

% Give user a chance to save any unsaved results, first.\
%
global unsavedResults;
if unsavedResults
        choice = questdlg('Latest results not saved.  Close anyway?', ...
        'Close without saving?','Yes','NO','NO');
    if ~strcmp(choice,'Yes')
        return;
    end;
end;
delete(hObject);
