function dbSubmit(varargin)
% dbSubmit(OptionalArgs, Files)
% Submit files to the database.  Files may be a single filename,
% a cell array of filenames, or omitted in which case a GUI prompts
% for a single file submission
% 
% OptionalArgs:
% 'Overwrite', true|false - Overwrite spreadsheet if it is already
%          in the repository
% 'QueryHandler', queryH - A handle to the Xquery interface.  If omitted
%          dbInit() will be called to produce one.
%
% The Server, Port, and whether or not to use a secure socket layer
% can also be specified, see dbInit for details.
%
% Files may be:
%   omitted - A dialog requests a file to upload
%   a string - Single file upload
%   or multiple files as a cell array, all of which are uploaded

% When invoked from a GUI, the first two arguments contain the 
% callback object and a reserved argument.  We remove these
if length(varargin) >= 2 && isnumeric(varargin{1}) && ishandle(varargin{1})
    varargin(1:2) = [];
end

% User passed in file list if # of args is odd & > 0
if length(varargin) > 0 && mod(length(varargin), 2) == 1
    % Remove final
    Files = varargin{end};
    if ischar(Files)
        Files = {Files};
    end
    varargin(end) = [];  % Only server options should remain
else
    Files = [];
end

% defaults
overwrite = {};  % don't overwrite
queryH = [];  % empty handler, will be created or picked up from varargin

% Process non-server related optional arguments
idx = 1;
while idx < length(varargin) && ischar(varargin{idx})
    % Set options and eliminate from argument list so that
    % we may pass whatever remains to the server initialization
    switch varargin{idx}
        case 'Overwrite'
            if varargin{idx+1}
                overwrite = {'-o'};
            end
            varargin(idx:idx+1) = [];
        case 'QueryHandler'
            queryH = varargin{idx+1};
            varargin(idx:idx+1) = [];
        otherwise
            idx = idx+2;
    end
end
            
global PARAMS;  % Triton parameters

% If the Java classes were not in Triton's java directory,
% we expect them to be in the same directory as this
% function.
jdir = fullfile(fileparts(mfilename('fullpath')), 'java');

% Add Java archive and directories to the path if not already on it.
jtargets = {'xmlrpc_upload.jar', 'dbxmlJavaClient.jar'};
localpath = javaclasspath;  % current path
for idx=1:length(jtargets)
    if sum(cellfun(@(x) isempty(x), strfind(localpath, jtargets{idx}))) == 0
        javaaddpath(fullfile(jdir, jtargets{idx})); 
    end
end

if isempty(queryH)
    queryH = dbInit(varargin{:});
end


%import the function
import edu.ucsd.cetus.XmlDBUp.*;

% Retrieve the uniform resource locator from query handler
url = char(queryH.getURLString());

if isempty(Files)
    % no arguments, pop up dialog with directory set appropriately
    if exist('PARAMS', 'var') & isfield('PARAMS', 'indir')  % Triton initialized?
        wdir = PARAMS.indir;  %  use Triton directory
    else
        wdir = pwd;  % Use Matlab directory
    end
    edu.ucsd.cetus.XmlDBUp({overwrite{:}, '-d', wdir, url});
else
    bad = zeros(length(Files), 1);
    for fidx = 1:length(Files)
        File = Files{fidx};
        % verify file exists
        if ~ exist(File, 'file')
            bad(fidx) = 1;
        end
        [dir, fname, ext] = fileparts(File);
        if isempty(dir)
            args = overwrite;
        else
            args = {overwrite{:}, '-d', dir};
        end
        edu.ucsd.cetus.XmlDBUp({args{:}, '-f', [fname, ext], url});            
    end
    if sum(bad) > 0
        BadFiles = sprintf('%s ', Files{bad});
        error('Files %s do not exist', BadFiles);
    end
end
