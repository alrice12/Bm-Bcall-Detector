function ltsa_delimiter

global PARAMS HANDLES

axes(HANDLES.subplt.ltsa)

xlim = get(get(HANDLES.fig.main,'CurrentAxes'),'XLim');
sec = floor((xlim(2)-xlim(1))/0.0173);
set = xlim(1);
v = zeros(1,sec);
x = zeros(2,sec/2);
i = 0;

for k=1:sec
[rawIndex,tBin] = getIndexBin(set);
tbinsz = PARAMS.ltsa.tave / (60*60);
ctime_dnum = PARAMS.ltsa.dnumStart(rawIndex) + (tBin - 0.5) * tbinsz /24;

v(k) = ctime_dnum;
    if k > 1 && (v(k)- v(k-1)) > .0015 
        i = i+1;
        x(1,i) = set - 0.0180;
        x(2,i) = set;
    end
set = set + 0.0180;
end

length = i;

yA = [min(PARAMS.ltsa.f),max(PARAMS.ltsa.f)];

for k = 1:length
x1A = [x(1,k),x(1,k)];
x2A = [x(2,k),x(2,k)];
L = (x2A + x1A)/2;
line(L,yA,'Color','w','LineWidth',2,'LineStyle','--');

end