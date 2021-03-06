function report = dbSubmit(varargin)
% dbSubmit(OptionalArgs, Files)
% Submit files to the database.  Files may be a single filename,
% a cell array of filenames, or omitted in which case a GUI prompts
% for a single file submission
% 
% OptionalArgs:
% 'QueryHandler', queryH - A handle to the Xquery interface.  If omitted
%          dbInit() will be called to produce one.
% The following optional arguments only apply when files are passed in:
% 'Collection', name - To which collection will these be added.
%          Default is 'Detections'.
% 'Overwrite', true|false - Overwrite spreadsheet if it is already
%          in the repository
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
overwrite = false;  % don't overwrite
queryH = [];  % empty handler, will be created or picked up from varargin
collection = 'Detections';

% Process non-server related optional arguments
idx = 1;
while idx < length(varargin) && ischar(varargin{idx})
    % Set options and eliminate from argument list so that
    % we may pass whatever remains to the server initialization
    switch varargin{idx}
        case 'Overwrite'
            overwrite = varargin{idx+1} ~= false;
            varargin(idx:idx+1) = [];
        case 'QueryHandler'
            queryH = varargin{idx+1};
            varargin(idx:idx+1) = [];
        case 'Collection'
            collection = varargin{idx+1};
            varargin(idx:idx+1) = [];
        otherwise
            idx = idx+2;
    end
end
            
global PARAMS;  % Triton parameters

dbJavaPaths();

if isempty(queryH)
    queryH = dbInit(varargin{:});
end

%import the function
import dbxml.uploader.*;

% Retrieve the uniform resource locator from query handler
url = char(queryH.getURLString());

if isempty(Files)
    % no arguments, pop up dialog with directory set appropriately
    if exist('PARAMS', 'var') & isfield('PARAMS', 'indir')  % Triton initialized?
        wdir = PARAMS.indir;  %  use Triton directory
    else
        wdir = pwd;  % Use Matlab directory
    end
    dbxml.uploader.ImportFrame.launch(url, wdir);
else
    url = queryH.getURLString();  % Server address
    result = dbxml.uploader.Importer.ImportFiles(url, collection, ...
        Files, '', '', overwrite);
    fprintf('%s\n', char(result));
    report = char(result);
end
