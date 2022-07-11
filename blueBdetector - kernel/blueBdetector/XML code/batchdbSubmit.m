clear all;

d = dir('F:\Detections\XML to submit\New folder\*.xml');
for i=1:length(d)
    filename = d(i,1).name;
    dbSubmit(filename);
end