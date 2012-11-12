function pointer = findZeroCrossing(sourceAudio, dictPointer, zcRange)
    pointer = -1;
    zDist = inf('double');
    k = dictPointer;
    for j = 0:zcRange
        if (((k+j) < length(sourceAudio)) && (k+j-1 > 0))
            if ((sign(sourceAudio(k+j)) ~= sign(sourceAudio(k+j-1))) && ...
                (abs(sourceAudio(k+j)) < zDist))
                pointer = k+j;
                zDist = abs(sourceAudio(k+j));
                break;
            end
        end
        if (((k-j) > 0) && (k-j+1 < length(sourceAudio)))
            if ((sign(sourceAudio(k-j)) ~= sign(sourceAudio(k-j+1))) && ...
                (abs(sourceAudio(k-j)) < zDist))
                pointer = k-j;
                zDist = abs(sourceAudio(k-j));
                break;
            end
        end
    end
    
    % failure to locate suitable zero crossing
    if (pointer == -1)
        pointer = dictPointer;
    end