![MBARC_logos_mod](https://user-images.githubusercontent.com/54909460/178321398-1af754d7-38cb-4a7f-9c47-fdfeb6151b9b.jpg)

# Bm-Bcall-Detector        
Automatically detects blue whale B calls using spectrogram correlation

Detects blue whale B calls by matching spectrograms of the sound recording in [Triton](https://github.com/MarineBioAcousticsRC/Triton.git) to a template spectrogram of a blue whale call, called the kernel. This template matches the third harmonic of a typical blue whale B call and must be updated within and between years.

Outputs an XML file with the start time of individual B calls

## Notes:
1. This code is for use with xwavs. See the [Wiki](https://github.com/alrice12/Bm-Bcall-Detector/wiki) for a tutorial on running the code
2. If you have wavs, use the [BlueWhaleBcall-Detector](https://github.com/MarineBioAcousticsRC/Triton/tree/master/Remoras/BlueWhaleBcall-Detector)
3. This detector should eventually be turned into an official [Triton](https://github.com/MarineBioAcousticsRC/Triton.git) remora

## Reference:

1. Širović A, Rice A, Chou E, Hildebrand JA, Wiggins SM, Roch MA (2015) Seven years of blue and fin whale call abundance in the Southern California Bight. Endanger Species Res 28:61–76. https://doi.org/10.3354/esr00676
