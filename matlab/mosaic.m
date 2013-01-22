%function reconstructedAudio = mosaic(targetError, windowSize, nDictionaryItems, ...
%                                    forceIterations, numIterations, xfadeWidth,  ...
%                                      perlin, snapToZeroCrossings)
    clear all;

    % settings

    test = 1; % if this is set to 1, the script will try to re-create the source perfectly
    perlin = 0; % if this is set to 1, perlin noise will be applied to the dictionary pointers
                % during reconstruction
    snapToZeroCrossings = 0; % if this is set to 1, the dictionary pointers will snap to the
                            % nearest zero-crossing during reconstruction
                
    perlinNoiseRange = 1000; % max fluctation in header/tail pointer
    zcRange = 100; % range to look for zero crossings
    forceIterations = 0;
    numIterations = 0;
    targetError = 0.0001;

    audioPath = '/Users/aboik/Documents/MATLAB/audio_mosaic/audio/';
    sourceAudioName = 'many_birds.wav';
    targetAudioName = 'many_birds.wav'; % overridden if test = 1

    if (test)
        targetAudioName = sourceAudioName;
    end
    xfadeWidth = 512;%  Number of samples in crossfade on either side of clip
    windowSize = 1024*2; % Change the multiplier to change window size
    orig_windowSize = windowSize; % copy of windowSize
    nDictionaryItems = 100; % Number of items in the dictionary (overridden if test = 1)
    nWindowsInSrc = 1; % Length of dictionary clips in windows
    sampleRate = 44100;

    % Load audio samples
    targetAudio = wavread(strcat(audioPath, targetAudioName));
    sourceAudio = wavread(strcat(audioPath, sourceAudioName));

    % Trim target audio to multiple of windowSize
    nTargetWindows = floor(length(targetAudio) / windowSize);
    targetAudio = targetAudio(1:(nTargetWindows*windowSize));

    % Matrix transposition to row vector
    [m,n] = size(targetAudio);
    [m2,n2] = size(sourceAudio);

    if n>m
        targetAudio = targetAudio';
    end
    if n2>m2
        sourceAudio = sourceAudio';
    end

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
    if(~forceIterations)
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
    else
        for i=1:numIterations
            [activations Yrecon score W] = fitactivations(targetSg, ...
                dictSpectGrams, activations);
        end
    end

    % Reconstruct the target audio using dictionary
    reconstructedAudio = zeros(windowSize * nReconstrWindows, 1);

    % There may be a faster way to do this
    for i = 1:nDictionaryItems
        if (mod(i,10) == 0)
            fprintf('dictionary item: %d\n', i);
        end
        activation = activations(i,:);

        % Create temp clip of the audio to be be convolved
        head = dictPointers(i);
        tail = dictPointers(i)+nSamples-1;

        % Insert windowSize-1 zeros between each activation, so we can convolve
        tmp = [activation; zeros(orig_windowSize-1, length(activation))];
        expandedActivation = reshape(tmp, [], 1);
        
        % Apply Perlin noise to head and tail pointers
        if (perlin)
            headNoise = perlinNoise(head, length(sourceAudio));
            tailNoise = perlinNoise(tail, length(sourceAudio));
            if (rand(1) > 0.5)
                head = int32(head + headNoise*perlinNoiseRange);
                tail = int32(tail + tailNoise*perlinNoiseRange);
            else
                head = int32(head - headNoise*perlinNoiseRange);
                tail = int32(tail - tailNoise*perlinNoiseRange);
            end
            % make sure we don't go out of bounds
            head = max(1, head);
            tail = min(length(sourceAudio), max(1,tail));
        end
        
        if (snapToZeroCrossings)
            % Find nearest zero-crossing of head
            head = findZeroCrossing(sourceAudio, head, zcRange);
            % Find nearest zero-crossing of tail
            tail = findZeroCrossing(sourceAudio, tail, zcRange);
        end
        
        tmpAudio = sourceAudio(head:tail);
        
        % change window size
        windowSize = length(tmpAudio);

      

        % Create crossfade sections beyond the head and tail of the clip
        if (xfadeWidth > windowSize)
            xfadeWidth = windowSize;
        end
        halfWidth = xfadeWidth/2;
        
        if (head > halfWidth)
            fadeIn = sourceAudio((head-halfWidth):(head-1));
        else
            fadeIn = zeros(halfWidth, 1);
        end

        if (tail <= (length(sourceAudio)-halfWidth))
            fadeOut = sourceAudio((tail+1:tail+halfWidth));
        else
            fadeOut = zeros(halfWidth, 1);
        end
        
          
        % transpose to correct dimensions
        %[m,n] = size(fadeOut);
        %if m==1
        %    fadeOut = fadeOut';
        %end
        %[m,n] = size(fadeIn);
        %if m==1
        %    fadeIn = fadeIn';
        %end
        %[m,n] = size(tmpAudio);
        %if m==1
        %    tmpAudio = tmpAudio';
        %end

        % Create the crossfade shape
        rampIn  = ((0:(xfadeWidth-1))/xfadeWidth)';
        rampOut = (((xfadeWidth-1):-1:0)/xfadeWidth)';
        crossfade = [rampIn; ones(windowSize-xfadeWidth,1); rampOut];
        % Concatenate the fades to the clip and crossfade
        tmpAudio = [fadeIn; tmpAudio; fadeOut];
        [m,n] = size(tmpAudio); % force tmpAudio dims
        [m2,n2] = size(crossfade); % force crossfade dims
        if m == 1
            tmpAudio = tmpAudio';
        end
        if m2 == 1
            crossfade = crossfade';
        end
        tmpAudio = tmpAudio.*crossfade;

        
        
        % Convolve with the associate dictionary item and add to targetAudio   
        
        convolution = conv(expandedActivation, tmpAudio, 'same');
        reconstructedAudio = reconstructedAudio + conv(expandedActivation, ...
            tmpAudio, 'same');

        % figure;
        % plot(reconstructedAudio(1:(1024*5)));
    end

    % Normalize the target audio and play result
    reconstructedAudio = reconstructedAudio / max(abs(reconstructedAudio));
    soundsc(reconstructedAudio, sampleRate);
    wavwrite(reconstructedAudio, sampleRate, 'audio_out.wav');
