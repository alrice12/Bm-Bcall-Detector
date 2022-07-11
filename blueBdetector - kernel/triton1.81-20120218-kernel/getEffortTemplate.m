function template = getEffortTemplate()
% Return the name of the effort template.

RootDir = fileparts(which('triton'));
template = fullfile(RootDir, 'log_data', 'Detection_Effort_template.xls');
