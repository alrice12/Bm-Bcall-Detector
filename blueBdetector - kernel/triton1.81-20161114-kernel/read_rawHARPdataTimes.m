function [dvec , dvec2] = read_rawHARPdataTimes(filename,d,numFile)
%
% 080904 smw stolen from read_rawHARPdataTimes.m to output each of the
% time stamps in one raw data file (i.e., 60000 per raw file - not the dirlist times)
%
% usage: >> [dvec] = read_rawHARPdata(filename,d,numFile)
%       dvec == date vector -> format: [yyyy mm dd HH MM SS.mmm]
%       data == one raw HARP file of 2-byte data
%       filename == FileSystem file name for raw HARP disk data
%       d = 1 -> display some stuff in command window, = 0 then no display
%       numFile == file number per raw HARP disk data
%
% this function reads one raw HARP disk data file, typically 60000 sectors
% the first timing header will be read and used.  Use a data header (not
% directory listing) timing checker to see if each sector (block) is
% contiguous
%
%   smw 050919
%
% units for HARP raw disk are bytes, sectors, and files
% 1 byte == 8 bits
% 1 sector == 512 bytes
% 1 file == 60000 sectors

global PARAMS

% check to see if file exists - return if not
if ~exist(filename)
    disp(['Error - no file ',filename])
    return
end

% display flag: display values = 1
if d
    dflag = 1;
else
    dflag = 0;
end

% read raw HARP dirlist (and disk header from within read_rawHARPdir)
read_rawHARPdir(filename,0);

if numFile > PARAMS.head.nextFile
    disp(['Error - last raw file = ',num2str(PARAMS.head.nextFile)])
    disp(['You chose filenumber = ', num2str(numFile)])
    return
end

% open raw HARP file
fid = fopen(filename,'r');
% fod = fopen('F:\DATA\TestData\testdata.bin','w');

% skip to 1st dir sector of data (raw file number)
fseek(fid,512*PARAMS.head.dirlist(numFile,1),'bof');

tic
% loop over the number of sectors for this file
% data = zeros(1,60000*250);

ftype = 2;
if ftype == 1
    nSectPerRaw = 60000;
    nBytesPerRaw = 500;
    tailblk = 0;
elseif ftype == 2
    nSectPerRaw = 58000;
    nBytesPerRaw = 496;
%     nSampPerRaw = 248;   % number of samples per data block
    tailblk = 4;    % skip the last two 'samples' ie 4 bytes
    
end

nrawFiles = 1;
nsect = nrawFiles * nSectPerRaw;   % number of sectors to check
dvec = zeros(nsect,7);
dvec2 = zeros(nsect,6);
count = 1;

dv = fread(fid,12,'uint8');
dvec(1,1:7) = [dv(2) dv(1) dv(4) dv(3) dv(6) dv(5) ...
   little2big_2byte([dv(8) dv(7)])];
% data = fread(fid,250,'int16')';
% fwrite(fod,fread(fid,250,'int16'),'int16');

% for ii = 2:PARAMS.dirlist(numFile,10)
for ii = 2:nsect
%     fseek(fid,500,0);
    fseek(fid,nBytesPerRaw,0);
        fseek(fid,tailblk,0);
    %     data(250*(ii-1)+1:250*ii) = fread(fid,250,'int16','l');
    %     data = [data fread(fid,250,'int16')'];
    %    fwrite(fod,fread(fid,250,'int16'),'int16');
    dv = fread(fid,12,'uint8');
    dvec(ii,1:7) = [dv(2) dv(1) dv(4) dv(3) dv(6) dv(5) ...
         little2big_2byte([dv(8) dv(7)])];

    count = count + 1;
%     if dflag && count == 60000
    if dflag && count == nSectPerRaw
        disp(['data block [sector] = ',num2str(ii)])    % give the user some feed back during this long process
        count = 0;
    end
end

dvec2 = [dvec(:,1:5) dvec(:,6)+ 0.001.*dvec(:,7)];

% close FileSystem file
fclose(fid);
% fclose(fod);

if d
    figure(5)
    tflag = 1;
    if tflag
         plot(datenum(dvec2))
%      plot(datenum(dvec2),'-o')
%           plot(datenum(dvec2),'-.')

  
    datetick('y',13)
    
    else
         plot(dvec(:,6)+ 0.001.*dvec(:,7))
    end
    grid on
    xlabel('Sector #')
    ylabel('Time')
    title(['Sector Time Stamp - buffer write ',num2str(numFile),' - ',num2str(numFile + nrawFiles - 1)])
    
    
    figure(6)
    ddnum = diff(datenum(dvec2)).*(24*60*60);
    plot(ddnum)
    
    xlabel('Sector #')
    ylabel('Time Difference (s)')
    title(['Sector Time Stamp - buffer write ',num2str(numFile),' - ',num2str(numFile + nrawFiles - 1)])
    
end


toc