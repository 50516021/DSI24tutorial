% RMA calculation for ERP version 2 % 
% - calculate RMS of evoked response data from the subject list
%
% required Add-ons
% - 
% required functions
% - 
% required setting files
% - 

% v1  
% 20250818 functionized RMS calculation
% v2
% 20260123 renewed subID format (unified with behavioral analysis - 'sXX format')


function [EEG_Msk, EEG_Tgt, rmsMsk, rmsTgt, num_sub_indep, num_sub_inter] = RMScal_v2(nums, sub_dir, subList, EEGopt)

% unpack parameters

Snum  = nums.Snum;
numCh = nums.numCh;
numSPTvar = nums.numSPTvar;
numSNRvar = nums.numSNRvar;

EEGfiletag_options = EEGopt.EEGfiletag_options;
fsEEG         = EEGopt.fsEEG;
baselinedur   = EEGopt.baselinedur;
maxrange_Msk  = EEGopt.maxrange_Msk;
maxrange_Tgt  = EEGopt.maxrange_Tgt;
latency_width = EEGopt.latency_width;

OSflag = utils.OSdetection_v1; %OS system detection

%% Load individual data

maxMsk     = zeros(Snum, numCh, numSPTvar);
maxMsk_ind = zeros(Snum, numCh, numSPTvar);
maxTgt     = zeros(Snum, numCh, numSPTvar, numSNRvar);
maxTgt_ind = zeros(Snum, numCh, numSPTvar, numSNRvar);

for i = 1:Snum
        
    subID = string(subList.ID(i));

    % get participants folder path
    % experiment name %
    folders = struct2table(dir(strcat(sub_dir, subID, '_*')));

    % get folder name (full repetition amount)
    if iscell(folders.name)
        sub_dir_tmp = strcat(sub_dir, folders.name{1}, '/');
    else
        sub_dir_tmp = strcat(sub_dir, strcat(folders.name), '/');
    end
    
    EEGfile = ls(strcat(sub_dir_tmp, EEGfiletag_options)); %find response file

    % EEG file path settring according to OS 
    if OSflag(1) == "1" %Mac
        EEGfile = EEGfile(1:end-1); %extract unnecessary character
    elseif OSflag(1) == "2" %Windows
        EEGfile = [sub_dir_tmp EEGfile];
    end
    load(EEGfile); %participant's responses
    
    [maxMsk(i,:,:),   maxMsk_ind(i,:,:)]   = max(plotEpMsk(round(fsEEG*(baselinedur+maxrange_Msk(1)):fsEEG*(baselinedur+maxrange_Msk(2))),:,:));
    [maxTgt(i,:,:,:), maxTgt_ind(i,:,:,:)] = max(plotEpTgt(round(fsEEG*(baselinedur+maxrange_Tgt(1)):fsEEG*(baselinedur+maxrange_Tgt(2))),:,:,:));
    %Index: maxMsk(subject, channel, Spatial Pattern)   
    %Index: maxTgt(subject, channel, Spatial Pattern, SNR)   

    EEG_Msk(:,i,:,:)   = saveEpMsk(:,:,:);
    EEG_Tgt(:,i,:,:,:) = saveEpTgt(:,:,:,:);
    %Index: EEG_Msk(EEG, subject, channel, Spatial Pattern(f>b)) 
    %Index: EEG_Tgt(EEG, subject, channel, Spatial Pattern(f>b), SNR(-18>-12)) 

end

%% Average latency

ave_latency_Msk = mean(maxMsk_ind(:,:,:),[1:4]); %averaged latency indices
ave_latency_Tgt = mean(maxTgt_ind(:,:,:,:),[1:4]);

ave_latency_Msk_rng = round(ave_latency_Msk + fsEEG*(baselinedur+maxrange_Msk(1) + [-latency_width, latency_width])); %indice of rms range (extracted + baseline + maxrange)
ave_latency_Tgt_rng = round(ave_latency_Tgt + fsEEG*(baselinedur+maxrange_Tgt(1) + [-latency_width, latency_width]));

num_sub_indep = sum(subList.SCS == 1);
num_sub_inter = sum(subList.SCS == 2);

%% RMS calculation

rmsMsk = squeeze(rms(EEG_Msk(ave_latency_Msk_rng(1):ave_latency_Msk_rng(2),:,:,:)));
rmsTgt = squeeze(rms(EEG_Tgt(ave_latency_Tgt_rng(1):ave_latency_Tgt_rng(2),:,:,:,:)));

