function h = loadbar(string,handle, x)

if nargin < 2
h = waitbar(0,'Loading please wait...','Name',string);
hw=findobj(h,'Type','Patch');
set(hw,'FaceColor',[0 .6 0]) % change the color bar to green

elseif nargin == 3
    waitbar(x,handle,string);
end


    