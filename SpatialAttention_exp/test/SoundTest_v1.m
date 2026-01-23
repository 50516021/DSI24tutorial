% Sound test v1%%%
% - check sound and speaker configuration
%   play sine tone from all the channel one by one 
%   used for sound check and measurement
%
% required Add-ons
% - Psychtoolbox
% required functions
% - 
% required setting files
% - 

% v1  
% 20231114 for multichannel sound test
% 20260122 amended comments, re-organize audio prep part


function [] = SoundTest_v1(numSpk, numIter) 

% numSpk  = 2; %number of speakers
% numIter = 2; %number of iteration 

%% audio parameters

buffer   = 100; %playback buffer size
fs       = 48000; % sample rate for audio
volume   = 1; % stimuli volume
vol_sin  = 0.3; %sintone volume
dur_pink = 6.5; %pink noise duration

%% audio info acquisition

InitializePsychSound %PsychTool Box
out = PsychPortAudio('GetDevices'); %get sound device information for Psychtool box
prompt = 'Choose Audio device'; % prompt message
[DevID_indx,tf] = listdlg('PromptString',prompt,'SelectionMode','single','ListSize',[200 150],'ListString',{out.DeviceName}); % option selection window
DevID = DevID_indx - 1; %the ID of Psychtoolbox starts with 0

pahandle = PsychPortAudio('Open', DevID, [], 2, fs, numSpk, buffer); % must be the same parameters with the current AUDIO Hardware such as FS, etc.

%% Sine wave Generation

dt = 1/fs;           % seconds per sample
SinDur = .05;             % duration [sec]
t = (0:dt:SinDur-dt)';   % seconds
F = 1000;                % Sine wave frequency (hertz)
sinwave = sin(2*pi*F*t)*vol_sin;
    
%% Pink Noise Generation

Pnoise=pinknoise(fs*dur_pink);

%% play

for i=1:numIter
    for j = 1:numSpk
        for k = 1:j
            sintone = zeros(numSpk,length(sinwave));
            sintone(j,:) = sinwave;
            PsychPortAudio('Volume', pahandle, volume);
            PsychPortAudio('FillBuffer', pahandle, sintone);   % load stimuli stimulus
            PsychPortAudio('Start',pahandle);               % playback
            WaitSecs(0.1);
        end
    
        testsound = zeros(numSpk,length(Pnoise));
        testsound(j,:) = Pnoise;
        PsychPortAudio('Volume', pahandle, volume);
        PsychPortAudio('FillBuffer', pahandle, testsound);   % load stimuli stimulus
        PsychPortAudio('Start',pahandle);               % playback
    end
end


end
 
 
        