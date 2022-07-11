% Initialize audio package
global BaseAudioDir;
if exist([getenv('HOME'), '/matlab/audio'], 'dir')
  BaseAudioDir = [ getenv('HOME'), '/matlab/audio'];
else
  error('Unable to find BaseAudioDir')
end

path(path, [BaseAudioDir, '/corpus']);
path(path, [BaseAudioDir, '/hmm']);
path(path, [BaseAudioDir, '/vq']);
path(path, [BaseAudioDir, '/gausssel']);
path(path, [BaseAudioDir, '/spline']);
path(path, [BaseAudioDir, '/stat']);
path(path, [BaseAudioDir, '/util']);
path(path, [BaseAudioDir, '/sigproc']);
path(path, [BaseAudioDir, '/vis']);
path(path, [BaseAudioDir, '/lib']);
path(path, [BaseAudioDir, '/experiment']);
path(path, [BaseAudioDir, '/tracking']);
path(path, [BaseAudioDir, '/tracking/helper']);
path(path, [BaseAudioDir, '/demo']);

% Seed random number generators
rand('state', sum(clock)*100);
randn('state', sum(clock)*100);
