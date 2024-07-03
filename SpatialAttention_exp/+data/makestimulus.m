%%%  makestimulus %%% 
%%% - 
%%%
%%% #required Add-ons
%%% - 
%%% #required functions
%%% - 
%%% #required setting files
%%% - 

%%% v1
%%% function script for stimulus



function [stimulus, duration] = makestimulus(target, fs, Spat, starttime, SNR, numSpk)


%% function variable
% %%% given
%     target = "4000206"; % target name
%     Spat = 2; % 0-1-2  
%     starttime = str2num('132143'); % start time in 48k Hz 
%     SNR = -6; % signal to noise ratio

%%% fixed
    SPch = [ ... % left - left
            0 1 0; ... % left - right
            0 0 1];... % left - backcenter
                  
    tailblank = 0.5 *fs;
    d_fifo = 9.9; %duration of fadein/fadeout
    targetDur   = 2.80; %target duration (s)
    onsetReady  = 0.00; %onset of 'ready' (s)
    onsetColor  = 1.00; %onset of color (s)
    onsetNumber = 2.10; %onset of number (s)
    Cols = ["blue", "red", "white", "green"]; %color options

    path_target = '../stimuli/target/';
    path_masker = '../stimuli/masker/';

%% name preparation
    names = split(target,'',1);
    talker = names(2);
    color  = Cols(str2double(names(6))+1);
    number = str2double(names(8))+1;

    [wavReady,tfs]  = audioread(sprintf('%st%s_ready.wav',path_target, talker)); % read target file
    [wavColor,tfs]  = audioread(sprintf('%st%s_%s.wav',path_target,talker, color)); % read target file
    [wavNumber,tfs] = audioread(sprintf('%st%s_%d.wav',path_target,talker, number)); % read target file

    %%% resampling
    wavReady  = resample(wavReady, fs, tfs);
    wavColor  = resample(wavColor, fs, tfs);
    wavNumber = resample(wavNumber, fs, tfs);

%% audio file preparation

    wavTgt = zeros(targetDur*fs,1);
    wavTgt(onsetReady*fs + 1:length(wavReady)) = wavReady;
    wavTgt(onsetColor*fs + 1:onsetColor*fs + length(wavColor)) = wavColor;
    wavTgt(onsetNumber*fs + 1:onsetNumber*fs + length(wavNumber)) = wavNumber;

    wavTgt = fadein(d_fifo,wavTgt,fs);  wavTgt = fadeout(d_fifo,wavTgt,fs);
    [wavMsk,mfs] = audioread([path_masker, 'masker_spch_orch.wav']); % read masker file

    %%% resample 
    [P,Q] = rat(fs/tfs);   wavTgt = resample(wavTgt, P, Q);
    [P,Q] = rat(fs/mfs);   wavMsk = resample(wavMsk, P, Q);
    
    %%% dajust file duration
    durTgt = length(wavTgt); 
    duration = starttime + durTgt + tailblank;
    wavMsk = wavMsk(1*fs:1*fs+duration-1,1);

    %%% S/N configuration %%%
    L = rms(wavMsk) * 10^(SNR/20)/ rms(wavTgt); %SNR = 20*log10(rms(target)/rms(masker))
    wavTgt = L* wavTgt;   
    %     SNR = 20*log10(rms(wavfile*volume)/rms(masker)); %for check
    
%% mix target and masker
    
    %%% add blanks
    blank1 = zeros(starttime,1); % make silent blanks
    blank2 = zeros(tailblank,1);  
    wavTgtfull = zeros(duration,1);
    wavTgtfull(:,1) = [blank1; wavTgt; blank2]; % add blanks

    %%% mix
    wavMsk = fadein(d_fifo,wavMsk,fs);  wavMsk = fadeout(d_fifo,wavMsk,fs);   
    stimulus = zeros(duration, numSpk); % make sure the amount of channels
    
    stimulus(:,1) = wavTgtfull;
    stimulus(:,2) = wavMsk * SPch(Spat,2);
    stimulus(:,3) = wavMsk * SPch(Spat,3);
    
end