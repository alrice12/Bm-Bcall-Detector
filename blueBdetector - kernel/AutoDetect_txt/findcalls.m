function findcalls (rIdx, halfblock, block, gap, offset, startTime, endTime, filename, hdr, ftype, in_fid, out_fid, DISPLAY)

% Adapted from David Mellinger's 
% smk 100219

%%%%%%%%%%%%%%%%%%%%%%%%% configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the spectrogram correlation kernel:
% 
% %2011-GofAK
% startF    = [48.50 48.01 47.65 47.42];	% Hz
% endF      = [48.01 47.65 47.42 47.06];	% Hz
% startT    = [0 1.5 3 4.5];		% s
% endT      = [1.5 3 4.5 10];	% s
% bandwidth = 2.0;	% Hz

%2008-SOCAL29E December		
startF    = [48.67 48.43 47.63 47.26];	% Hz	
endF      = [48.43 47.63 47.26 46.80];	% Hz	
startT    = [0 1.5 3 4.5];		% s
endT      = [1.5 3 4.5 10];	% s	
bandwidth = 2.0;	% Hz	

% %2012-OCNMS
% startF    = [47.48 47.09 46.65 46.37];	% Hz
% endF      = [47.09 46.65 46.37 45.93];	% Hz
% startT    = [0 1.5 3 4.5];		% s
% endT      = [1.5 3 4.5 10];	% s
% bandwidth = 2.0;	% Hz

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
thresh = 41;

% Define the spectrogram parameters:
gramParams = struct( ...
    'frameSizeS', 2.0, ...	% spectrogram frame size, s
    'overlapFrac', 0.5, ...	% fraction in (0,1)
    'zeroPadFrac', 0);		% fraction in (0,1)
%%%%%%%%%%%%%%%%%%%%%%%%%% end of configuration %%%%%%%%%%%%%%%%%%%%%%%%%%

% Read in data
data = ioReadXWAV(in_fid, hdr, startTime, endTime, hdr.nch, ...  % can also hard-code channel
    ftype, filename);

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

writecalls (hdr, rIdx, halfblock, startTime, offset, peakS, score, out_fid);

end