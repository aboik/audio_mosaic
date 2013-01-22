% from http://freespace.virgin.net/hugo.elias/models/m_perlin.htm

function noise = perlinNoise(x)
    noise = 0;
    p = 1/4; % persistence
    n = 3; % num_octaves - 1
    
    for i = 0:n
        freq = 2^i;
        ampl = p^i;
        noise = noise + InterpolatedNoise(x*freq, i) * ampl;
    end
end

function noise = InterpolatedNoise(x, n)
    
    v1 = SmoothedNoise(x,n);
    v2 = SmoothedNoise(x + 1,n);
    noise = Cosine_Interpolate(v1, v2, x);

end

function noise = SmoothedNoise(x, n)
    noise = Noise(x,n)/2 + Noise(x-1,n)/4 + Noise(x+1,n)/4;
    
end

function noise = Noise(x, n)
    fprintf('firstx')
    x
    switch n
        case 0
            x = xor(fix(x*2^(-13)), x);
            fprintf('x')
            x
            noise = (1.0 - ( (x * (x * x * 15731 + 789221) + 1376312589) ...
                & hex2dec('7fffffff')) / 1073741824.0);
        case 1
            x = fix(x*2^(-13)) ^ x;
            fprintf('x')
            x
            noise = (1.0 - ( (x * (x * x * 15809 + 789977) + 1376314783) ...
                & hex2dec('7fffffff')) / 1097436863.0);
        case 2
            x = fix(x*2^(-13)) ^ x;
            fprintf('x')
            x
            noise = (1.0 - ( (x * (x * x * 16699 + 789713) + 1376313067) ...
                & hex2dec('7fffffff')) / 1123550209.0);
        case 3
            x = fix(x*2^(-13)) ^ x;
            noise = (1.0 - ( (x * (x * x * 16519 + 790451) + 1376314307) ...
                & hex2dec('7fffffff')) / 1003550287.0);
        case 4
            x = fix(x*2^(-13)) ^ x;
            noise = (1.0 - ( (x * (x * x * 16451 + 790613) + 1376313907) ...
                & hex2dec('7fffffff')) / 1253965813.0);
        case 5
            x = fix(x*2^(-13)) ^ x;
            noise = (1.0 - ( (x * (x * x * 16609 + 789511) + 1376314811) ...
                & hex2dec('7fffffff')) / 1457211193.0);
    end
    fprintf('basenoise');
    noise
end

function interpolation = Cosine_Interpolate(a, b, x)
    ft = x * 3.1415927;
    f = (1 - cos(ft)) * .5;
    
    interpolation = a*(1-f) + b*f;
end
