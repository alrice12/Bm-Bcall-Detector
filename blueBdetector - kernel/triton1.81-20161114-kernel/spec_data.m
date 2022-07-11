function [chartR, chartW, orderR, project, headers, parameters] = spec_data(filename)
% [chartR, chartW, orderR, project, headers, frequency] = spec_data(filename)
% Read specifications for allowable detections

[num, txt, raw] = xlsread(filename,'Effort');

headers = txt(1,:);
r = 1;
w = 1;
p = 1;
f = 1;

% Locate the headers that we need.
HumanReadable = ~cellfun(@isempty, regexp(headers, 'Group|Common Name|Call'));
MachineReadable = ~cellfun(@isempty, regexp(headers, 'Group|Species Code|Call'));
Parameters = ~cellfun(@isempty, regexp(headers, 'Parameter.*'));

% make charts for the reading and writing inputs
chartR = txt(2:end, HumanReadable);
chartW = txt(2:end, MachineReadable);
parameters = txt(2:end, Parameters);

treeR = zeros(1,size(chartR, 2));
treeW = zeros(1,size(chartW, 2));

[ly,lx] = size(chartR);
orderR = zeros(ly,lx);

% [ly,lx] = size(chartW);
% orderW = zeros(ly,lx);
% disp(length(chart))
% disp(length(chart(1)))

prev = [];
for x = 1:size(chartR, 2)
    for y = 1:length(chartR)
        % Look for new name that we have not seen before
        if ~strcmp(chartR(y,x),'') && ~strcmp(chartR(y,x),prev)
            treeR(x) = treeR(x) + 1;
        end
        orderR(y,x) = treeR(x);
        prev = chartR(y,x);
    end
end

[nump, txtp, rawp] = xlsread(filename, 'MetaData');
project = {};
projdata(:,1)= txtp(2:length(txtp));

for y = 1:length(projdata)
    if ~strcmp(projdata(y,1), '')
    project{length(project) + 1} = projdata{y};
    end
end



