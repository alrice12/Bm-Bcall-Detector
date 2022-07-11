function autodet(filename, outfile)

% scroll through xwav file - adapted from Shyam's BatchClassifyBlueCalls
% smk 100219

% ideal for window lengths greater than 1 raw file (75s).  As is, raw file
% length in seconds must be hard-coded.  If raw files are ever NOT 75s,
% code must be adapted.

% % Hardcode Option:
% filename = 'H:\data\SOCAL45H\SOCAL45H_disks01-04_df100\SOCAL4$_disk01_111006_170600.df100.x.wav';
% textfile = 'I:\data\SOCAL33N.txt';

block = 2250;   % s
startTime = 0;
halfblock = block/2;

ftype = 2; %confirm xwav
if isempty(strfind(filename, '.x.wav'))
    ftype = 1;
end

%Write xwav file name into excel sheet
in_fid = fopen(filename, 'r');   % Open audio data
out_fid = fopen(outfile, 'a');   % Open xls file to write to
% fprintf(out_fid, '%s\n', filename); % print xwav file name

% colhds = {'Det Start Time', 'Det Score'};
% xlswrite(outfile,colhds,'Sheet1','A1')
% row_start = 2;

hdr = ioReadXWAVHeader(filename, 'ftype', ftype); %read in header info


% Trying to avoid hardcoding number of seconds in a raw file.  Does not
% work yet bc raw files are not equal when scheduled.
% rawsec = 1:(length(hdr.raw.dnumStart));
% for r = 2:length(hdr.raw.dnumStart)
%     raw = datevec((hdr.raw.dnumStart(r))-hdr.raw.dnumStart(r-1));
%     rawsec(r) = (raw(5)*60)+raw(6);

%     make sure raw files lengths are all equal.
% %     if rawsec(r) ~= rawsec(r-1)
% %         disp('raw files are not equal size')
% %         return
% %     end
% end


% Index each block.  Find total number of seconds in xwav, divide by 
% length of a raw file
totalsec = (length(hdr.raw.dnumStart))*75; %number of raw files * 75s
blocknum = floor(totalsec/block); %how many times will the whole window fit
blkfit = blocknum*block; %how many seconds will fit the block
extra = totalsec-blkfit; %total seconds left over
extraraw = extra/75; %total raw files left over to process
%process extra separately

% Find scheduled gaps in Duty Cycle data
% The offset will be used when calculating the real time of detections in
% writeBcalls function
for rIdx = 1:length(hdr.raw.dnumStart)
    if rIdx <= 1
        gap = 0;
        offset = 0;
    else
        gap(rIdx) = floor((hdr.raw.dnumStart(rIdx) - ...
            hdr.raw.dnumEnd(rIdx-1)) * 24 * 60 * 60);

        % Calculate the cumulative offset in scheduled gaps per raw file
        offset(rIdx) = offset(rIdx-1) + floor((hdr.raw.dnumStart(rIdx) - ...
            hdr.raw.dnumEnd(rIdx-1)) * 24 * 60 * 60); % will give cumulative gap time so far
    end
end

% Here we go...

% for blockIdx = 1:blocknum  %scroll through blocks
%     fprintf('Analyzing block %2d of %d ...\n', blockIdx, blocknum);
   
    % While we are in range for the current block...
    while startTime + block <= blkfit
        
        endTime = startTime + block;
        
        fprintf('Analyzing %2d - %d of %d seconds ...\n', startTime, (startTime+halfblock), totalsec);

        findcalls(rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, 0);

        startTime = startTime + halfblock;         
    end
    
    % Process the last remaining segment thats < 1 block but is
    % at least 1 halfblock long
    if startTime + halfblock <= blkfit;
        
        endTime = startTime + halfblock;

        fprintf('Analyzing %2d - %d of %d seconds ...\n', startTime, endTime, totalsec);
        
        findcalls(rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, 0);

        startTime = startTime + halfblock;
    end

    rawblk = 75; %hardcoding at 75s (length of raw file) will ensure that 
    % all raw files left over are processed
    halfraw = 75/2;
    
    fprintf ('\nProcess any "extra" ...\n')
    %Process the extra raw files
    while startTime + rawblk <= totalsec
        
        endTime = startTime + rawblk;
        
        fprintf('Analyzing %.1f - %.1f of %d seconds ...\n', startTime, (startTime+halfraw), totalsec);
        
        findcalls(rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, 0);

        startTime = startTime + halfraw;
    end
    
    fprintf ('\n...last bit.\n')
    %Process last remaining bit of extra
    if startTime + halfraw <= totalsec
        endTime = startTime + halfraw;
        
        fprintf('Analyzing %.1f - %.1f of %d seconds.\n', startTime, endTime, totalsec);
        
        findcalls(rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, 0);
        
    end

    fclose(in_fid);
    fclose(out_fid);
    
end
