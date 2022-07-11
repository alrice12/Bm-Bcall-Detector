function ckFirmware()
%
% function sets parameters based on firmware version from hrp disk header
% called from write_hrp2xwavs.m
% called after read_rawHARPhead which gets firmware version
%
% 101029 smw

global PARAMS

% compression flag: no compression = 0, compression = 1
% firmwareVersion is 10 characters long
fver1 = PARAMS.head.firmwareVersion(1);
if strcmp(fver1,'1')
    PARAMS.cflag = 0;      % no compression
    PARAMS.ctype = -1;      % no compression type
elseif strcmp(fver1,'V')
    fver2 = str2num(PARAMS.head.firmwareVersion(2:5));
    if fver2 == 2.01
        PARAMS.cflag = 0;      % no compression
        PARAMS.ctype = -1;      % no compression type
    elseif fver2 == 2.02
        PARAMS.cflag = 1;      % compression
        fver3 = PARAMS.head.firmwareVersion(6);
        if strcmp(fver3,'Q')
            PARAMS.ctype = 0;
        elseif strcmp(fver3,'R') || strcmp(fver3,'r')
            fver4 = PARAMS.head.firmwareVersion(7:10);
            if strcmp(fver4,'_SSD') % 'V2.02R_SSD'
                PARAMS.ctype = 0;
            else
                PARAMS.ctype = 1;      % 'V2.02R    '  or V2.02R_1
            end
        else
            disp('Error: unknown compression firmware version')
            disp(PARAMS.head.firmwareVersion)
            return
        end
    elseif fver2 == 2.20
        PARAMS.cflag = 1;       % ie compression
        PARAMS.ctype = 1;
    elseif fver2 == 2.10
        PARAMS.cflag = 0;      % no compression
        PARAMS.ctype = -1;      % no compression type
        PARAMS.nch = 4;
    else
        disp('Error: unknown compression firmware version')
        disp(PARAMS.head.firmwareVersion)
        return
    end
else
    disp('Error: Unknown firmware version:')
    disp(PARAMS.head.firmwareVersion)
    return
end