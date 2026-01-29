% Spatial Attention EEG analysis for BDF/EDF/CSV - step 4 % 
% - evoked response
%
% required Add-ons
% - EEGLAB
% - Symbolic Math Toolbox
% required functions
% - 
% required setting files
% - 

% v1  
% 20230111 for Biosemi with 16 channel
% 20230318 adapted subject numbers
% v2 
% 20230322 adapted all BDF/EDF/CSV
% 20230328 processed data save
% 20230804 applied BPF [1.5 8], added date identification
% 20240131 vertical lines for ERP analysis
% 20250716 function utils folder
% 20250814 A1A2 re-reference option

%%%!!check!!%%%%%
% name, tgArray, fpass

clearvars; close all;
% pname = 'R:\06_Tutorials\EEGanalysisWorkshop2022\example_ISNT';

%% parameters
%get folder name
folders = struct2table(dir('subject/s*'));
prompt = 'Chose folder name:';  % prompt message
[foldInd,tf] = listdlg('PromptString',prompt,'SelectionMode','single','ListSize',[400 750],'ListString',folders.name); % option selection window
experiment_name = folders.name{foldInd,:}; %subject (experiment) name
outfolder =  sprintf('subject/%s/', experiment_name); %name of the output folder containing the subject's data 

% get filenames
fnameMsk = strcat(outfolder, 'step3_epochs_Msk_', experiment_name, '_ICAprocessedAfterRejections.mat'); %Masker based epoched EEG data file name with its path
fnameTgt = strcat(outfolder, 'step3_epochs_Tgt_', experiment_name, '_ICAprocessedAfterRejections.mat'); %Target based epoched EEG data file name with its path
titlename = strrep(experiment_name, '_', ' '); %name for figure title (replaced '_' to blank)
disp(['Processing: ' experiment_name]) %make sure the processing data

% get behavioral data
resfile = ls([outfolder '/res*']);
load(resfile(1:end-1)); %participant's responses
tgArray= table2array(res(:,12)); %extract answer section

% filter settings
fpass = [1.5 8]; %frequency of low/hi cut (Hz)
fsFilt = 230; %order of filtering
reref = 'A'; % DSI-24 re-reference 'A':A1A2/'O':O1O2

% trial information
if length(extractBefore(experiment_name, "_jp20")) == 6 %Japanese or not
    Cols = ["kuro", "aka", "shiro", "midori"]; %color options
else 
    Cols = ["blue", "red", "white", "green"]; %color variations
end
Nums = 1:8; %number variations
SNRs = [-12 -18]; %signal noise ratio variations
Spat = ["front", "back"]; %spatial pattern variations

numCols = length(Cols); %number of color variety
numNums = length(Nums); %number of number variety
numSNRs = length(SNRs); %number of SNR variety
numSpat = length(SNRs); %number of Spatial pattern variety

baselinedur = 0.3; %duration of baseline (sec)
shorteststs = 1.5; %minimum target start time (sec)
targetdur   = 2.8; %target duration (sec)

%% trigger values
TgGrand= 250; %grand start/end
TgMsk  = 240; %masker onset
TgTgt  = 230; %target onset
TgOff  = 220; %stream offset
TgAuth = [200 201]; %authenticity (correct/incorrect)
TgCAns = [060 098 160 198]; %correct answer (161 - 198)
TgIAns = [110 149]; %input answer (111 - 148)
TgSNR  = [100 105]; %SNR pattern (-12/-18)
TgSpt  = [106 109]; %Spatial pattern (front/back)

%% load MASKER based file
load(fnameMsk) %load Masker based EEG
numChMsk = size(epochs_Gd,2); %number of channels on masker
epochs_Gd_temp=epochs_Gd; %temporal signal for filtering
for i =1:size(epochs_Gd,3)
    epochs_Gd(:,:,i) = utils.BPF(double(squeeze(epochs_Gd_temp(:,:,i))), fs, fpass(1), fpass(2), fsFilt); % BPF = band pass filter
end

%% common parameters

% OstGrand= onsets(events==TgGrand); %index of grand start/end
% OstMsk  = onsets(events==TgMsk); %index of masker onset
% OstTgt  = onsets(events==TgTgt); %index of target onset
% OstOff  = onsets(events==TgOff); %index of stream offset
% OstCAns = events(find((TgCAns(1)<=events).*(events<=TgCAns(2))+(TgCAns(3)<=events).*(events<=TgCAns(4)))); %index of correct answer (161 - 198)
% OstIAns = events(find((TgIAns(1)<=events).*(events<=TgIAns(2)))); %index of input answer (111 - 148)
% OstAuth = events(ismember(events,TgAuth)); %index of authenticity (correct/incorrect)
% OstSpt  = events(ismember(events,TgSpt)); %index of Spatial pattern (front/back)
% OstSNR  = events(ismember(events,TgSNR)); %index of SNR pattern (-12/-18)

OstCAns = tgArray(:,1); %index of correct answer (161 - 198)
OstIAns = tgArray(:,2); %index of input answer (111 - 148)
OstAuth = tgArray(:,3); %index of authenticity (correct/incorrect)
OstSpt  = tgArray(:,4); %index of Spatial pattern (front/back)
OstSNR  = tgArray(:,5); %index of SNR pattern (-12/-18)

%% make MASKER figure

OstSptMsk = OstSpt(GdTr_final); %final values of spatial pattern on masker 

figure;
    % 4...Fz
    % 8...Cz
    % 12..Pz (DSI-24>No Pz)
    % 14..O1
    % 16..O2 (DSI-24>15..O2)
if size(epochs_Gd,2)+length(BadChannels) == 20 %DSI-24
    disp('Device: DSI-24')
    Hotch = [4 8]; % Fz and Cz
    if reref == 'A' 
        Coldch = [9 18]; %A1 and A2
    else 
        Coldch = [14 15]; % O1 and O2
    end
else %Biosemi
    disp('Device: Biosemi')
    Hotch = [4 8]; % Fz and Cz
    Coldch = [14 16]; % O1 and O2
end

ch1 = 'Fz';
ch2 = 'Cz';

yscale = 10; %scale of y axis
legends = {ch1, ch2, 'Onset'};

t = -baselinedur: 1/fs : shorteststs-1/fs; %sample to second conversion
streamdur = 256*(baselinedur+shorteststs); %plot stream duration

co = 1;
for i = 1:numSpat
    numTrial = length(find(OstSptMsk==TgSpt(i)));
    MeanEp = mean(epochs_Gd(1:streamdur,1:numChMsk,find(OstSptMsk==TgSpt(i))),3); %culculate avarage of front
    plotEp = MeanEp(:,[Hotch(1) Hotch(2)])-MeanEp(:,[Coldch(1) Coldch(2)])/2-MeanEp(:,[Coldch(2) Coldch(1)])/2; %subtraction from center channel
    saveEpMsk(:,:,i) = plotEp; %saveEpMsk(EEG, channel, Spatial Pattern)

    subplot(numSpat,1,co);
    plot(t,plotEp); hold on;  
    ylim([-yscale yscale]); 
    xlim([-baselinedur shorteststs]); 
    line([0;0], get(gca, 'ylim')); hold off;
    title(sprintf('Spatial Pattern: %s, %d trials',Spat(i), numTrial));
    xlabel('time[s]');    

    co = co + 1;
end

sgtitle(sprintf('Final evoked response [%s] for Masker onset BPF[%0.1f-%0.1f]', titlename, fpass))
legend(legends(:), 'location', 'southeast');
saveas(gcf, strcat(outfolder, 'final_EvokedResponse_Msk_', reref, '_', experiment_name, '_filt', '.pdf'))

%% load Target file

load(fnameTgt) %load Target based EEG
numChTgt = size(epochs_Gd,2); %number of channels on target
epochs_Gd_temp=epochs_Gd; %temporal signal for filtering
for i =1:size(epochs_Gd,3)
    epochs_Gd(:,:,i) = utils.BPF(double(squeeze(epochs_Gd_temp(:,:,i))), fs, fpass(1), fpass(2), fsFilt); % BPF = band pass filter
end

%% make TARGET figure

OstSNRTgt = OstSNR(GdTr_final); %final values of SNR on target 
OstSptTgt = OstSpt(GdTr_final); %final values of spatial pattern on target 

figure;

t = -baselinedur: 1/fs : targetdur-1/fs; %sample to second conversion
streamdur = 256*(baselinedur+targetdur); %plot stream duration
legends = {ch1, ch2, '"ready"','"[color]"','"[number]"', '50ms', '200ms'};

co = 1;
for i = 1:numSpat
    for j = 1:numSNRs
        numTrial = length(intersect(find(OstSNRTgt==TgSNR(numSNRs-j+1)),find(OstSptTgt==TgSpt(i))));
        MeanEp = mean(epochs_Gd(1:streamdur,1:numChTgt,intersect(find(OstSNRTgt==TgSNR(numSNRs-j+1)),find(OstSptTgt==TgSpt(i)))),3); %culculate avarage of front
        plotEp = MeanEp(:,[Hotch(1) Hotch(2)])-MeanEp(:,[Coldch(1) Coldch(2)])/2-MeanEp(:,[Coldch(2) Coldch(1)])/2; %subtraction from center channel
        saveEpTgt(:,:,i,j) = plotEp; %saveEpTgt(EEG, channel, Spatial Pattern(f>b), SNR(-18>-12))

        subplot(numSpat,numSNRs,co);
        plot(t,plotEp); hold on;  
        ylim([-yscale yscale]); 
        xlim([-baselinedur targetdur]); 
        line([0;0], get(gca, 'ylim'),'Color','r'); hold on;
        line([1;1], get(gca, 'ylim'),'Color','g'); hold on;  
        line([2.1;2.1], get(gca, 'ylim'),'Color','b'); hold on; 
        line([0.05;0.05], get(gca, 'ylim'),'LineStyle','--'); hold on;
        line([0.2;0.2],   get(gca, 'ylim'),'LineStyle','--'); hold off; 
        title(sprintf('SNR: %s dB, Spatial Pattern: %s, %d trials',string(SNRs(numSNRs-j+1)),Spat(i), numTrial));
        xlabel('time[s]');    
    
        co = co + 1;
    end
end

sgtitle(sprintf('Final evoked response [%s] for Target onset BPF[%0.1f-%0.1f]', titlename, fpass))
legend(legends(:), 'location', 'southeast');
saveas(gcf, strcat(outfolder, 'final_EvokedResponse_Tgt_', reref, '_', experiment_name,'_filt', '.pdf'))

%% Target figure for colors

OstCAnsTgt = OstCAns(GdTr_final); %final values of correct Answer on target 
OstCAnsTgt_color = fix(mod(OstCAnsTgt,100)/10); %final values of correct answers' color on target (6,7,8,9)

figure;

for i = 1:numCols      
    MeanEp = mean(epochs_Gd(1:streamdur,1:numChTgt,find(OstCAnsTgt_color==(i+5))),3); %culculate avarage of front
    plotEp = MeanEp(:,[Hotch(1) Hotch(2)])-MeanEp(:,[Coldch(1) Coldch(2)])/2-MeanEp(:,[Coldch(2) Coldch(1)])/2; %subtraction from center channel
    numTrial = sum(OstCAnsTgt_color==(i+5));
    saveEpCol(:,:,i) = plotEp; %saveEpCol(EEG, channel, color)

    subplot(numCols/2,numCols/2,i);
    plot(t,plotEp); hold on;  
    ylim([-yscale yscale]); 
    xlim([-baselinedur targetdur]); 
    line([0;0], get(gca, 'ylim'),'Color','r'); hold on;
    line([1;1], get(gca, 'ylim'),'Color','g'); hold on;  
    line([2.1;2.1], get(gca, 'ylim'),'Color','b'); hold on; 
    line([0.05;0.05], get(gca, 'ylim'),'LineStyle','--'); hold on;
    line([0.2;0.2],   get(gca, 'ylim'),'LineStyle','--'); hold off; 
    title(sprintf('Color: %s,  %d trials',Cols(i), numTrial));
    xlabel('time[s]');    
    
end

sgtitle(sprintf('Final evoked response [%s] for Target onset and color BPF[%0.1f-%0.1f]', titlename, fpass))
legend(legends(:), 'location', 'southeast');
saveas(gcf, strcat(outfolder, 'final_EvokedResponse_TgtCol_', reref, '_', experiment_name,'_filt', '.pdf'))

%% save processed data
date = datestr(now,'yyyymmdd');
if reref    
    save_filename = strcat(outfolder, 'step4_plotdata_', reref, '_', date, '_',  experiment_name, '.mat');
else
    save_filename = strcat(outfolder, 'step4_plotdata_', date, '_',  experiment_name, '.mat');
end
save(save_filename,'saveEpMsk','saveEpTgt','saveEpCol');
disp(strcat(save_filename, ' has been saved'))


