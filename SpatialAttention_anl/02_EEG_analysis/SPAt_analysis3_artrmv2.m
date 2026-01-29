% Spatial Attention EEG analysis for BDF/EDF/CSV - step 3 % 
% - artifact removal 2 - ICA based
%
% required Add-ons
% - EEGLAB
% required functions
% - 
% required setting files
% - 

% v1  
% 20230110 for Biosemi with 16 chnannel
% 20230219 for DSI-24 with 19 channel
% 20230318 adapted subject numbers
% 20230325 added Goodchannels
% 20230330 slightly changed file names

clearvars; close all;

%% parameters
pname = '';
%get folder name
folders = struct2table(dir('subject/s*'));
prompt = 'Chose folder name:';  % prompt message
[foldInd,tf] = listdlg('PromptString',prompt,'SelectionMode','single','ListSize',[400 700],'ListString',folders.name); % option selection window
experiment_name = folders.name{foldInd,:}; %subject (experiment) name
outfolder =  sprintf('subject/%s/', experiment_name); %name of the output folder containing the subject's data 

% get filenames
OnsetOpt = ["Msk" "Tgt"]; %options of onsets
prompt = 'Chose onset option:';  % prompt message
[OnsetOptInd,tf] = listdlg('PromptString',prompt,'SelectionMode','single','ListSize',[200 200],'ListString',OnsetOpt); % option selection window

data_name = strcat(OnsetOpt(OnsetOptInd), '_', experiment_name);
fnameS1 = strcat(outfolder, 'step1_', data_name, '.mat'); %epoched EEG data file name with its path for step1
fnameS2 = strcat(outfolder, 'step2_', data_name, '_afterRejections_ica.set'); %epoched EEG data file name with its path for step2
disp(['----- Processing:' char(data_name), ' -----']) %make sure the processing data

% % determin onset value
% if onsetinfo{1}=="Msk_"
%     OstTg = 240; %triger value of maskers
% elseif onsetinfo{1}=="Tgt_"
%     OstTg = 230; %triger value of targets
% else
%     disp('Check the onset info')
% end

%% load files
[ALLEEG, EEG, CURRENTSET, ALLCOM] = eeglab;
EEG = pop_loadset('filename',char(fnameS2), ...
    'filepath',pname);
epochs_pre = permute(EEG.data,[2,1,3]);
chs_removed = EEG.chs_removed;
pop_selectcomps(EEG, 1:EEG.nbchan );

%sh 
figure; 
plot(mean(epochs_pre,3));hold on; 
line([128 640;128 640], get(gca, 'ylim'));
title(sprintf('Before removal (%s)',data_name))
xticklabels;
set(gcf,'position',[1   216   560   420]);
%sh

keyboard;
% saveas(gcf, strcat(outfolder, 'step3_', data_name, 'ICA.pdf'))

close all;

comps = find(EEG.reject.gcompreject);
EEG = pop_subcomp( EEG, comps, 0);

% EEG.rejected = comps;
% EEG = pop_saveset( EEG, 'filename',[subjID 'ica_removed.set'], ...
%     'filepath','R:\\inychoi\\EEGdata\\CCT_CI\\');
epochs = permute(EEG.data,[2,1,3]); %epochs(samples, channels, trials)
% keyboard

load(strcat(fnameS1),'t','fs');
load(strcat(outfolder, "step2_", data_name, "_extraction.mat"),'GoodTrials','BadChannels','chs')
% HitOrMiss = HitOrMiss(GoodTrials);

%%% Second bad-trial rejection can go here %%%
toi = find( (0.1<t) .* (t<2.5) ); %time of interest. for epochsNO
mx = squeeze(max(max(abs(epochs(toi,:,:)))));
figure
set(gcf,'position',[1   216   560   420])
histogram(mx,50)
title(data_name)
drawnow();
thresT = str2double(input('thres? ','s'));
gt = find(mx<thresT); %index of good trials
title(sprintf('%s, used threshould: %d',data_name, thresT));

pdfname = append(outfolder, 'step3_', data_name, '_thTr2nd', '.pdf');
print(pdfname,'-dpdf');

epochs_Gd    = epochs(:,:,gt); %epochs of good trials
% HitOrMiss = HitOrMiss(gt);
GdTr_final = GoodTrials(gt); %final index of good trials
allchs = 1:size(epochs,2); %all channel numbers 
% Goodchannels = chs(chs ~= BadChannels); %final index of good channels
%%%%%%%%%%%%%%%%%%

% epochsH = epochs(:,:,events==23);
% epochsL = epochs(:,:,events==17);
% % HitOrMissH = HitOrMiss(events==23);
% % HitOrMissL = HitOrMiss(events==17);
% 
% % SNRH
% epochs = epochsH;
% HitOrMiss = HitOrMissH;
% save([savepath 'epochs_CCT_' subjID '_ICAprocessedAfterRejections_SNRH_byIC.mat'],'epochs','t','comps','chs_removed','BadChannels','HitOrMiss');
save(strcat(outfolder, 'step3_epochs_', data_name, '_ICAprocessedAfterRejections.mat'),'epochs_Gd','GdTr_final','t','comps','chs','BadChannels','gt','fs');

% SNRL
% epochs = epochsL;
% % HitOrMiss = HitOrMissL;
% % save([savepath 'epochs_CCT_' subjID '_ICAprocessedAfterRejections_SNRL_byIC.mat'],'epochs','t','comps','chs_removed','BadChannels','HitOrMiss');
% save([outfolder 'epochs_CCT_' subjID '_ICAprocessedAfterRejections_SNRL_byIC.mat'],'epochs','t','comps','chs_removed','BadChannels');


%% make figure for all channels 
    % 4...Fz
    % 8...Cz
    % 12..Pz (DSI-24>No Pz)
    % 14..O1
    % 16..O2 (DSI-24>15..O2)
baselinedur = 0.3; %duration of baseline (sec)
shorteststs = 1.5; %minimum start time (sec)

%read location files
numCh = length(allchs);
if numCh == 20 %DSI-24
    disp('Device: DSI-24')
    locs    = struct2table(readlocs('../01_OriginalData/LocationFiles/DSI-24 Channel Locations w.ced')); %channel configuration file for numCh channels (DSI-24)   
    Hotch = [4 8]; % Fz and Cz
    Coldch = [14 15]; % O1 and O2
else %Biosemi
    disp('Device: Biosemi')
    locfile = strcat('../01_OriginalData/LocationFiles/BioSemiElecCoor_', num2str(numCh), '.txt'); %channel configuration file for numCh channels (Biosemi)
    locs    = struct2table(readlocs(locfile,'filetype','xyz')); %load channel configuration file 
    Hotch = [4 8]; % Fz and Cz
    Coldch = [14 16]; % O1 and O2
end

legendsnum=cellstr(locs.labels); %all channels

ch1 = 'Fz';
ch2 = 'Cz';

t = -baselinedur: 1/256 : shorteststs-1/256; %sample to second conversion

figure; 

subplot(2,1,1);
plot(t,mean(epochs_pre(1:256*(baselinedur+shorteststs),allchs,:),3));hold on; 
line([0;0], get(gca, 'ylim'));
title('Before removal')
legend(legendsnum(allchs));

subplot(2,1,2);
plot(t,mean(epochs_Gd(1:256*(baselinedur+shorteststs),allchs,:),3));hold on; 
line([0;0], get(gca, 'ylim'));
title(sprintf('After removing %02i components',length(comps)))
legend(legendsnum(allchs));
saveas(gcf, strcat(outfolder, 'step3_', data_name, '_evokedWaveforms_BeforeAndAfterICAafterRejections_byIC.pdf'))

%% make figure for Fz and Cz

talker = 0;
target = '000001';
yscale = 10;
legends = {ch1, ch2, 'Startpoint'};
MeanEp_bf = mean(epochs_pre(1:256*(baselinedur+shorteststs),:,:),3); %culculate avarage
MeanEp_af = mean(epochs_Gd(1:256*(baselinedur+shorteststs),:,:),3);
plotEp_bf = MeanEp_bf(:,[Hotch(1) Hotch(2)])-MeanEp_bf(:,[Coldch(1) Coldch(2)])/2-MeanEp_bf(:,[Coldch(2) Coldch(1)])/2; %subtraction from center channel
plotEp_af = MeanEp_af(:,[Hotch(1) Hotch(2)])-MeanEp_af(:,[Coldch(1) Coldch(2)])/2-MeanEp_af(:,[Coldch(2) Coldch(1)])/2; %subtraction from center channel

figure; 
%before ICA
subplot(2,1,1);
plot(t, plotEp_bf)    
ylim([-yscale yscale]); 
xlim([-baselinedur shorteststs]); hold on;
plot(0*ones(2,1),ylim); hold on;
title('Before removal')
%after ICA
subplot(2,1,2);
plot(t, plotEp_af) 
ylim([-yscale yscale]); 
xlim([-baselinedur shorteststs]); hold on;
plot(0*ones(2,1),ylim); hold on;
title(sprintf('After removing %02i components',length(comps)))

legend(legends(:), 'location', 'southeast');
saveas(gcf, strcat(outfolder, 'step3_', data_name, '_evokedWaveforms_BeforeAndAfterICAafterRejections_simple_byIC.pdf'))

disp(['----- Processed: ' char(data_name), ' -----']) %make sure the processed data