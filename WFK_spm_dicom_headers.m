function hdr = WFK_spm_dicom_headers(handles, msg, P, essentials)
% Read header information from DICOM files
% FORMAT hdr = spm_dicom_headers(P [,essentials])
% P          - array of filenames
% essentials - if true, then only save the essential parts of the header
%
% hdr        - cell array of headers, one element for each file.
%
% Contents of headers are approximately explained in:
% http://medical.nema.org/standard.html
%
% This code may not work for all cases of DICOM data, as DICOM is an
% extremely complicated "standard".
%__________________________________________________________________________
% Copyright (C) 2002-2014 Wellcome Trust Centre for Neuroimaging

% John Ashburner
% $Id: spm_dicom_headers.m 6431 2015-05-08 18:24:28Z john $
%
% WFK edited version of spm_dicom_headers, to allow user to get feedback
% on progress of work via a GUI.
%   -- Bill Kaemmerer (WFK)  June 10, 2016
%


if nargin<4, essentials = false; end  % changed from nargin<2 -- WFK

dict = readdict;
j    = 0;
hdr  = {};
% if size(P,1)>1, spm_progress_bar('Init',size(P,1),'Reading DICOM headers','Files complete'); end
set(handles.ProcessingStepText,'String',msg);
set(handles.TotalCountText,'String',sprintf('%d',size(P,1)));
pause on;
for i=1:size(P,1)
    set(handles.CurrentText,'String',sprintf('%d',i));
    pause(0.001);  % to give the GUI a chance to update -- WFK
    tmp = spm_dicom_header(P(i,:),dict);
    if ~isempty(tmp)
        if isa(essentials,'function_handle')
            tmp = feval(essentials,tmp);
        elseif essentials
            tmp = spm_dicom_essentials(tmp);
        end
        if ~isempty(tmp)
            j      = j + 1;
            hdr{j} = tmp;
        end
    end
    % if size(P,1)>1, spm_progress_bar('Set',i); end
end
% if size(P,1)>1, spm_progress_bar('Clear'); end
set(handles.ProcessingStepText,'String','Done reading headers.');
pause(0.01);


%==========================================================================
% function dict = readdict(P)
%==========================================================================
function dict = readdict(P)
if nargin<1, P = 'spm_dicom_dict.mat'; end
try
    dict = load(P);
catch
    fprintf('\nUnable to load the file "%s".\n', P);
    rethrow(lasterror);
end

