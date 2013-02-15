clear all;

% settings

test = 0; % if this is set to 1, the script will try to re-create the source perfectly

targetError = 0.0001;

audioPath = '/Users/aboik/Documents/MATLAB/audio_mosaic/audio/';
sourceAudioName = 'thriller_sample.wav';
targetAudioName = 'gangnam.wav'; % overridden if test = 1

if (test)
    targetAudioName = sourceAudioName;
end

xfadeWidth = 512*4; % Number of samples in crossfade on either side of clip
windowSize = 512*4; % Change the multiplier to change window size
nDictionaryItems = 1000; % Number of items in the dictionary (overridden if test = 1)
nWindowsInSrc = 1; % Length of dictionary clips in windows
sampleRate = 44100;

% Load audio samples
targetAudio = wavread(strcat(audioPath, targetAudioName));
sourceAudio = wavread(strcat(audioPath, sourceAudioName));

% Matrix transposition to row vector
[m,n] = size(targetAudio);
[m2,n2] = size(sourceAudio);

if n==1
    targetAudio = targetAudio';
end
if n2==1
    sourceAudio = sourceAudio';
end

% Trim target audio to multiple of windowSize
nTargetWindows = floor(length(targetAudio) / windowSize);
targetAudio = targetAudio(1:(nTargetWindows*windowSize));


if (test)
    nDictionaryItems = round(nTargetWindows/2);
end

% Create dictionary from source Audio
nSamples = windowSize * nWindowsInSrc;
dictPointers = zeros(nDictionaryItems,1);

for i = 1:nDictionaryItems
    if(test)
        dictPointers(i) = 1 + (i-1)*windowSize;
    else
        dictPointers(i) = round(random('unif',1+xfadeWidth, ...
            length(sourceAudio)-nSamples-xfadeWidth+1));
    end
end

% Compute spectrograms (this can be collapsed with previous loop)
targetSg = abs(spectrogram(targetAudio, windowSize, 0, windowSize, 44100));
nBins = windowSize / 2 + 1;
dictSpectGrams = zeros(nBins, nDictionaryItems, nWindowsInSrc);

for i = 1:nDictionaryItems
    tmpAudio = sourceAudio(dictPointers(i):(dictPointers(i)+nSamples-1));
    dictSpectGrams(:,i,:) = abs(spectrogram(tmpAudio, ...
        windowSize, 0, windowSize, 44100));
end


% Call fitactivations in a loop until the score doesn't change that much
nReconstrWindows = nTargetWindows+nWindowsInSrc-1;
activations = ones(nDictionaryItems, nReconstrWindows);
scores = [];
done = 0;
i = 1;
while(~done)
    fprintf('i = %d\n', i);
    [activations Yrecon score W] = fitactivations(targetSg, ...
        dictSpectGrams, activations);
    fprintf('score = %d\n', score);
    scores(i) = score;
    if(i > 1)
        if(abs(scores(i)-scores(i-1)) < targetError)
            done = 1;
        end
    end
    i = i + 1;
end

% Reconstruct the target audio using dictionary
reconstructedAudio = zeros(windowSize * nReconstrWindows, 1);

% There may be a faster way to do this
for i = 1:nDictionaryItems
    if (mod(i,10) == 0)
        fprintf('dictionary item: %d\n', i);
    end
    activation = activations(i,:);
    
    % Insert windowSize-1 zeros between each activation, so we can convolve
    tmp = [activation; zeros(windowSize-1, length(activation))];
    expandedActivation = reshape(tmp, [], 1);
    
    % Create temp clip of the audio to be be convolved
    head = dictPointers(i);
    tail = dictPointers(i)+nSamples-1;
    tmpAudio = sourceAudio(head:tail);
    
    % Create crossfade sections beyond the head and tail of the clip
    halfWidth = xfadeWidth/2;
    
    if (head > halfWidth)
        fadeIn = sourceAudio((head-halfWidth):(head-1));
    else
        fadeIn = zeros(halfWidth, 1);
    end
    
    %%if (tail <= halfWidth) 
    if (tail <= (length(sourceAudio)-halfWidth))
        fadeOut = sourceAudio((tail+1:tail+halfWidth));
    else
        fadeOut = zeros(halfWidth, 1);
    end
    
    % Create the crossfade shape
    rampIn  = ((0:(xfadeWidth-1))/xfadeWidth)';
    rampOut = (((xfadeWidth-1):-1:0)/xfadeWidth)';
    crossfade = [rampIn; ones(windowSize-xfadeWidth,1); rampOut];
    
    % Concatenate the fades to the clip and crossfade
    [m,n] = size(fadeOut);
    if m==1
        fadeOut = fadeOut';
    end
    [m,n] = size(fadeIn);
    if m==1
        fadeIn = fadeIn';
    end
    [m,n] = size(tmpAudio);
    if m==1
        tmpAudio = tmpAudio';
    end
    tmpAudio = [fadeIn; tmpAudio; fadeOut];
    
    tmpAudio = (tmpAudio).*(crossfade);
    
    
    % Convolve with the associate dictionary item and add to targetAudio   
    reconstructedAudio = reconstructedAudio + conv(expandedActivation, ...
        tmpAudio, 'same');
    
    % figure;
    % plot(reconstructedAudio(1:(1024*5)));
end

% Normalize the target audio and play result
reconstructedAudio = reconstructedAudio / max(abs(reconstructedAudio));
soundsc(reconstructedAudio, sampleRate);
wavwrite(reconstructedAudio, sampleRate, 'audio_out.wav');











