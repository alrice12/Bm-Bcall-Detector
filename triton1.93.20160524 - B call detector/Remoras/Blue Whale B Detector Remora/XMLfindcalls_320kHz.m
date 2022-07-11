function XMLfindcalls_320kHz (rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, DISPLAY, dxml, params,rf_secs)

% Adapted from David Mellinger's 
% smk 100219
import tethys.nilus.*; %JAXB Package
%%%%%%%%%%%%%%%%%%%%%%%%% configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the spectrogram correlation kernel:

%2011-SOCAL
startF    = [46 45.4 44.7 44.1];	% Hz
endF      = [45.4 44.7 44.1 43.5];	% Hz
startT    = [0 1.5 3 4.5];		% s
endT      = [1.5 3 4.5 10];	% s
bandwidth = 2.0;	% Hz

% %2011-OCNMS
% startF    = [47.67 47.13 46.59 46.23];	% Hz
% endF      = [47.13 46.59 46.23 45.43];	% Hz
% startT    = [0 1.5 3 4.5];		% s
% endT      = [1.5 3 4.5 10];	% s
% bandwidth = 2.0;	% Hz

% % %Be4 kernel
% startF    = [55 57.5 57.6];	% Hz
% endF      = [57.5 57.6 57.6];	% Hz
% startT    = [0 1 2];		% s
% endT      = [1 2 3];	% s
% bandwidth = 3.0;	% Hz
% 
% % %Right Whale Lisa kernel
% startF    = [100];	% Hz
% endF      = [150];	% Hz
% startT    = [0];		% s
% endT      = [1];	% s
% bandwidth = 10.0;	% Hz


% Define the peak detection parameters:
nbdS = 5.0;
thresh = 37;

% Define the spectrogram parameters:
gramParams = struct( ...
    'frameSizeS', 2.0, ...	% spectrogram frame size, s
    'overlapFrac', 0.5, ...	% fraction in (0,1)
    'zeroPadFrac', 0);		% fraction in (0,1)
%%%%%%%%%%%%%%%%%%%%%%%%%% end of configuration %%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%% XML construction from configuration %%%%%%%%%%%%%%%%%%%%
if params == true
    eFreq=[];
    eTime=[];
    vFreq=[];
    vTime=[];
    %BmB det parameter names/values(e for element name, v for value)
    for pdx=1:length(startF)+1
        eFreq=[eFreq;java.lang.String(strcat('Freq',sprintf('%d',pdx),'_Hz'))];
        eTime=[eTime;java.lang.String(strcat('Time',sprintf('%d',pdx),'_s'))];
        if pdx<length(startF)
            vFreq=[vFreq; startF(pdx)];
            vTime=[vTime; startT(pdx)];
        else
            vFreq=[vFreq; endF(pdx-1)];
            vTime=[vTime; endT(pdx-1)];
        end
    end
    %parameter names
    eBlock = 'Block_s';
    eBandw = 'Bandwidth_Hz';
    eThresh = 'Threshold';
    eNeighb = 'Neighboorhood';
    %parameter values
    vBlock = block;
    vBandw = bandwidth;
    vThresh= thresh;
    vNeighb = nbdS;
    
    %create parameter tags
    tags=[];
    for tdx=1:length(eFreq)
        tTime=Tag(eTime(tdx),vTime(tdx));
        tFreq=Tag(eFreq(tdx),vFreq(tdx));
        tags=[tags,tTime,tFreq];
    end
    tags = [tags, Tag(eBlock,vBlock),Tag(eBandw,vBandw), ...
           Tag(eThresh,vThresh), Tag(eNeighb,vNeighb)];
    
    %ADD the params to our Detections
    dxml.addAlgorithmParameters(tags);
end
%%%%%%%%%%%%%%%%%%%%%%  END XML CONSTRUCTION  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%





% Read in data
try
data = ioReadXWAV(in_fid, hdr, startTime, endTime, hdr.nch, ...  % can also hard-code channel
    ftype, filename);
catch e
    disp(['Corrupt xwav file: ', filename]);
    disp(['Processed up to:  ', num2str(startTime), ' seconds']);
    e2=MException('XWavError:CorruptAfterSeconds', num2str(startTime));
    e= addCause(e,e2);
    throw(e);
end

%[spec f t] = fft_rapt_specgram(data, hdr.fs, nfft, overlap, ...
%    min_freq, max_freq);


% Make spectrogram
[gram,fRate,gramParams] = davespect(data, gramParams, hdr.fs);

% Make spectrogram correlation kernel, correlate it with spectrogram.
[ker,vOff,hOff] = multiKernel(startF, endF, startT, endT, bandwidth, hdr.fs, ...
    fRate, gramParams.frameSize, gramParams.zeroPad, gramParams.nOverlap, 1);
detFn = dumbConv(gram, ker, vOff);

%         Can also do  ...
%             showKernel(ker, hdr.fs, fRate)    % to image the kernel

peakIx = dpeaks(detFn, round(nbdS*fRate), thresh);
score = detFn(peakIx);
peakS = ((peakIx-1)/fRate + hOff);
%             disp('Detection times:')


% Display the results: first the spectrogram, using some heuristics for
% intensity scaling and frequency limits, and then the detection function.
if DISPLAY > 0
    subplot(211)
    med = median(gram(:)); mx = max(gram(:));  % used for intensity scaling
    imagesc([0 nCols(gram)/fRate], [0 hdr.fs/2], gram, [med + (mx-med)*[.25 1]])
%     set(gca, 'YDir', 'normal','XLim', [0 block], 'YLim', [startF(1)+(endF(4)-startF(1))*[2.0 -1.0]])
    colormap(jet)
    ylabel('Hz')
    title('spectrogram of blue whale band')


    subplot(212)
    plot(hOff + (0 : length(detFn)-1)/fRate, detFn)	% detection function
    set(gca, 'XLim', [0 block], 'YLim',[0 max(detFn)*1.05])  % hOff + [0 length(detFn)-1]/fRate ...instead of 60.
    title(['detection function of block ',num2str(rIdx),', startTime ',num2str(startTime+(floor(gap))),', endTime ',num2str(endTime+(floor(gap)))])
    xlabel('time, s')


    hold on
    plot(get(gca, 'XLim'), [thresh thresh], 'r')	% threshold
    plot(peakS, get(gca,'YLim')*[1.1;0.9]*ones(1,length(peakS)), 'r*') % detections
    hold off

    %             pause
end

XMLwritecalls_320kHz (hdr, rIdx, halfblock, startTime, offset, peakS, score, out_fid, in_fid, dxml,rf_secs);

end