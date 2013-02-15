function audio_out = granulate(audio_in, grain_size, random_reordering, conv_blend, random_reversal, pitch_shift)
% divide audio_in into size/grain_size number of grains. Every grain
% is assigned a number. If random_reordering is true, each grain slot will
% be filled with a random grain (repeats allowed). If conv_blend is true,
% a random grain will be convolved with each grain. If pitch_shift is >0,
% the pitch will be randomly shifted according to the desired amount. If
% random_reversal is true, some grains will be reversed.
reversal_prob = 0.5;

num_grains = round(length(audio_in) / grain_size);


grain_samples = zeros(grain_size, num_grains);
for i=1:num_grains
    grain_samples(:,i) = audio_in((i-1)*grain_size+1:(i-1)*grain_size+grain_size);
end

audio_out = audio_in;

% random reorder
if (random_reordering)
    for i =1:num_grains
        j = randi(num_grains,1);
        audio_out((i-1)*grain_size+1:(i-1)*grain_size+grain_size) = ...
            grain_samples(:,j);
    end
end

if (conv_blend)
    for i=1:num_grains
        j = randi(num_grains,1);
        audio_out((i-1)*grain_size+1:(i-1)*grain_size+grain_size) = ...
            conv(audio_out((i-1)*grain_size+1:(i-1)*grain_size+grain_size), ...
                audio_out((j-1)*grain_size+1:(j-1)*grain_size+grain_size), 'same');
    end
end

if (random_reversal)
    for i=1:num_grains
        if (rand(1) > reversal_prob)
            audio_out((i-1)*grain_size+1:(i-1)*grain_size+grain_size) = ...
                reverse(audio_out((i-1)*grain_size+1:(i-1)*grain_size+grain_size));
        end
    end
end

if (pitch_shift > 0)
    for i=1:num_grains
        shift_val = round(randi(100,1)*pitch_shift);
        sample = audio_out((i-1)*grain_size+1:(i-1)*grain_size+grain_size);
        e = pvoc(sample, double(shift_val)/100.0, length(sample));
        f = resample(e, grain_size, length(e));
        audio_out((i-1)*grain_size+1:(i-1)*grain_size+grain_size) = f;
    end
end





end

function out = reverse(in)
    out = zeros(length(in),1);
    for i=1:length(in)/2
        out(i) = in(length(in)-i+1);
        out(length(in)-i+1) = in(i);
    end
end