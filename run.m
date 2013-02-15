% settings
% test, perlin, zc, forceIt, numIt, targetError, pNoiseRange
settings(:, 1) = [0, 0, 0, 0, 0, 0.01, 0];
settings(:, 2) = [0, 0, 0, 0, 0, 0.001, 0];
settings(:, 3) = [0, 0, 0, 0, 0, 0.0001, 0];
settings(:, 4) = [0, 0, 1, 0, 0, 0.01, 0];
settings(:, 5) = [0, 0, 1, 0, 0, 0.001, 0];
settings(:, 6) = [0, 0, 1, 0, 0, 0.0001, 0];
settings(:, 7) = [0, 1, 1, 0, 0, 0.01, 0];
settings(:, 8) = [0, 1, 1, 0, 0, 0.001, 0];
settings(:, 9) = [0, 1, 1, 0, 0, 0.0001, 0];

%parameters
% xfadewidth, windowsize, ndictitems
params(:, 1) = [128, 512, 100];
params(:, 2) = [128, 512, 1000];
params(:, 3) = [128, 1024, 100];
params(:, 4) = [128, 1024, 1000];
params(:,5) = [256, 512, 100];
params(:,6) = [256, 512, 1000];
params(:,7) = [256, 1024, 100];
params(:,8) = [256, 1024, 1000];

% granular params
% granular, grainsize, randreorder, convblend, randrev, pitchshift
gParams(:,1) = [1, 4, 1, 1, 1, 1];
gParams(:,2) = [1, 32, 1, 1, 1, 1];
gParams(:,3) = [1, 128, 1, 1, 1, 1];
gParams(:,4) = [1, 256, 1, 1, 1, 1];
gParams(:,5) = [1, 128, 0, 0, 0, 1];
gParams(:,6) = [1, 256, 0, 0, 0, 1];
gParams(:,7) = [1, 128, 0, 0, 1, 0];
gParams(:,8) = [1, 256, 0, 0, 1, 0];
gParams(:,9) = [1, 128, 0, 1, 0, 0];
gParams(:,10) = [1, 256, 0, 1, 0, 0];
gParams(:,11) = [1, 128, 1, 0, 0, 0];
gParams(:,12) = [1, 256, 1, 0, 0, 0];
gParams(:,13) = [0, 0, 0, 0, 0, 0];

sampleRate = 44100;
audioPath = '/Users/aboik/Documents/MATLAB/audio_mosaic/audio/';

source = 'many_birds.wav';
target = 'many_birds.wav';
%for i = 1:9
%    for j = 1:8
%        audio = mosaic_2(audioPath, source, target, settings(:,i), params(:,j), gParams(:,1));
%        wavwrite(audio, sampleRate, sprintf('birds%d,%d.wav', i, j));
%    end
%end
for i = 13:13
    audio = mosaic_2(audioPath, source, target, settings(:,3), params(:,8), gParams(:,i));
    wavwrite(audio, sampleRate, sprintf('birds_g%d.wav', i));
end





