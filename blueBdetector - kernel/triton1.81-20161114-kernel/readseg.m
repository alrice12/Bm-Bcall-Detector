function readseg
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% readseg.m
%
% previously rdtseg.m
%
% read a segment of data from opened file
%
%
% 060203 - 060227 smw
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global PARAMS DATA

check_time      % check to see if ok plot start time (PARAMS.plot.dvec or 
                % PARAMS.plot.dnum)

DATA = [];  % clear DATA matrix

if PARAMS.ftype == 1        % wav file
    skip = floor((PARAMS.plot.dnum - PARAMS.start.dnum) * 24 * 60 * 60 * PARAMS.fs);   % number of samples to skip over
    % %
    PARAMS.tseg.samp = ceil( PARAMS.tseg.sec * PARAMS.fs );	% number of samples in segment
    DATA = wavread( [PARAMS.inpath PARAMS.infile], [skip+1 skip+PARAMS.tseg.samp] );
    DATA = DATA(:,PARAMS.ch).*2^15;     % un-normalize wavread
elseif PARAMS.ftype == 2    % xwav file
    index = PARAMS.raw.currentIndex;
    if PARAMS.nBits == 16
        dtype = 'int16';
    elseif PARAMS.nBits == 32
        dtype = 'int32';
    else
        disp_msg('PARAMS.nBits = ')
        disp_msg(PARAMS.nBits)
        disp_msg('not supported')
        return
    end
    skip = floor((PARAMS.plot.dnum - PARAMS.raw.dnumStart(index)) * 24 * 60 * 60 * PARAMS.fs);   % number of samples to skip over
    % %
    PARAMS.tseg.samp = ceil( PARAMS.tseg.sec * PARAMS.fs );	% number of samples in segment
    fid = fopen([PARAMS.inpath PARAMS.infile],'r');
    fseek(fid,PARAMS.xhd.byte_loc(index) + skip*PARAMS.nch*PARAMS.samp.byte,'bof');
    DATA = fread(fid,[PARAMS.nch,PARAMS.tseg.samp],dtype);
    fclose(fid);
    DATA = DATA(PARAMS.ch,:);
    if PARAMS.xgain > 0
        DATA = DATA ./ PARAMS.xgain(1);
    end
end

PARAMS.save.dnum = PARAMS.plot.dnum;    % save it for next time

