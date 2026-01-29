% BPF
% - Band Pass Filter
% BPF(x, fs, cf1, cf2, norder)
% 

% version history
% 20240515 organized by Akira Takeuchi (originary made by Rai Sato)

function y = BPF(x, fs, cf1, cf2, norder)

arguments
    x =  rand(100,100); %original waveform
    fs = 100; %sampling rate of the waveform
    cf1 = 0; %filter low edge 
    cf2 = 0; %filter high edge 
    norder = 230; %order of filtering
end

% y = randn(1,10*fs)*0.1; % make 10 seconds noise
% n = 10000;
% n = 1000;
% n = 100;
n = norder;

Ny = fs/2;
Wn = [cf1 cf2]/(Ny);
h = fir1(n,Wn);

y = flipud(fftfilt(h,flipud(fftfilt(h,x))));