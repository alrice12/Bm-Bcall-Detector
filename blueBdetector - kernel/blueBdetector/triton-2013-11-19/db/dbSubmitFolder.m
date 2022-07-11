function dbSubmitFolder(varargin)
% Folder option for dbSubmit
% Single optional argument is the folder location. Include the final \
% e.g. C:\Windows\ , not C:\Windows
% Lines 74/75 interchangable for overwriting.
%
%Some prompt layout adapted from autodet_dir
%Author: sherbert  11/20/2013
%--------------------------------------------------------------------------
%Detection Directory Input

if isempty(varargin)
    %Prompt options:
    indir = uigetdir('','Select Import Directory');
    indir = strcat(indir,'\');
    if strcmp(indir,'\')
        disp('Canceled Button Pushed')
        return
    else
        disp('Input file directory: ')
        disp(indir)
        disp(' ')
    end
end

if length(varargin) == 1
    indir = varargin{1};
elseif length(varargin) > 1
    disp('Incorrect number of input arguments')
    disp('Please specify a directory, or use dbSubmitFolder() for a prompt')
    return;
end

%Store list of .xls and xml files within indir
indir_ls = dir(indir);
indir_names = {indir_ls.name}';
xls_match = strfind(indir_names, '.xls');
xml_match = strfind(indir_names, '.xml');
for xidx=1:length(xls_match)
    xlss(xidx,1) = isempty(xls_match{xidx,1});
end
xls = xlss == 0;
xls_ls = indir_names(xls);
xlscount = num2str(length(xls_ls));
%Display number of input files
disp(['Number of Input XLS: ', xlscount])
for xidx=1:length(xml_match)
    xmls(xidx,1) = isempty(xml_match{xidx,1});
end
xml = xmls == 0;
xml_ls = indir_names(xml);
xmlcount = num2str(length(xml_ls));
%Display number of input files
disp(['Number of Input XML: ', xmlcount])

%cell array for in files
import_files = cell(1,length(xls_ls)+length(xml_ls));

%populate cell array with files to be uploaded
%beginning with xls
for idx=1:length(xls_ls)
    filename = strcat(indir,xls_ls{idx});
    import_files{idx}=filename;
end

%append cell array with xml files
xlslength = length(xls_ls);
for idx=1+xlslength:length(import_files)
    filename = strcat(indir,xml_ls{idx-xlslength});
    import_files{idx}=filename;
end

q=dbInit('Server','bandolero.ucsd.edu');

%report = dbSubmit('QueryHandler',q,'Overwrite',true,import_files);
report = dbSubmit('QueryHandler',q,import_files);
success = strfind(report,'<Success>');
failure = strfind(report,'<Failure>');
error = strfind(report,'<Error>');

disp('------------SUMMARY------------');
disp(['Successful Imports: ', num2str(length(success))]);
disp(['Failed Imports: ', num2str(length(failure))]);

1;


