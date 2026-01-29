%%% jackknife_comp - jackknife comparison between two situations v2 %%% 
%%% - Jackknife analysis for single signal
%%%
%%% required Add-ons
%%% - 
%%% - 
%%% required functions
%%% - 
%%%
%%% required setting files
%%% - 

%%% v1  
%%% 20231030 inbetween subject comparison (for step6-v1)
%%% v3
%%% 20231224 two instructions 'experiment_mTRF_feasibility_v4.m' (non-duratio/slice)
%%% v4 
%%% 20240221 subtraction plot from step6 v4
%%% 20240313 Jacknife

function [signalA, PeakValueA, PeakIndexA] = jackknife_comp_v2(signalA, fs, t, t_stt, t_end)

arguments
    signalA double %index: signal([sample],[subject])
    signalB double
    fs      double
    t = [1:size(signalA,1)]/fs;
    t_stt = t(1);   %start time [second]
    t_end = t(end); %end time [second]
end

if size(signalA) ~= size(signalB) 
    fprintf('the size if the signals should be the same')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Jackknife analysis example
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% n_of_subj=10;
% len_sample = 900;
% 
% fs = 300;
% 
% signalA = rand (len_sample,n_of_subj)-0.5;
% signalB = rand (len_sample,n_of_subj)-0.5;

len_sample = size(signalA,1);
n_of_subj  = size(signalA,2);
jk = 1; % Jackknife ~+--



subjs1 = [1:n_of_subj];
for k = 1:n_of_subj
    subjects = setdiff(subjs1,k);
    jk_signalA(:,k) = squeeze(mean(signalA(:,subjects),2));
    % jk_signalB(:,k) = squeeze(mean(signalB(:,subjects),2));
end
if jk == 1
    signalA = jk_signalA;
    % signalB = jk_signalB;
end

%%%%%%%%%%% calculating features %%%%%%%%%%%
toin=find( (t>t_stt) .* (t<t_end));
[PeakValueA, PeakIndexA] = max(signalA(toin,:));
% [PeakValueB, PeakIndexB] = max(signalB(toin,:)); 
PeakIndexA = PeakIndexA + toin(1); %compensation
% PeakIndexB = PeakIndexB + toin(1);

%%%%% <- You can add ratio or difference features between two conditions
%%%%% like SNR. -> You'll use the feature to compute t-score, p values
%%%%% etc.

%% plot

%%%%%%%%%%% plot for Jackknife'ed data %%%%%%%%%%%
if jk == 1
    coef  = n_of_subj - 1;
else
    coef = 1;
end

% figure;
% hold on; 
% plot(t, mean(signalA,2),'r')
% plot(t, mean(signalB,2),'b')

% xlim ([-0.2, 2]);

%%% Patch: Standard error
h = patch([t'; flipud(t')], ...
    [mean(signalA(:,:),2) + coef * std(signalA(:,:),0,2)/sqrt(size(signalA,2)); ...
    flipud(mean(signalA(:,:),2) - coef * std(signalA(:,:),0,2)/sqrt(size(signalA,2)))], ...
    [1 0.7 0.7]);
set(h,'EdgeColor','None'); hold on;
% h = patch([t'; flipud(t')], ...
%     [mean(signalB(:,:),2) + coef *  std(signalB(:,:),0,2)/sqrt(size(signalB,2)); ...
%     flipud(mean(signalB(:,:),2) - coef * std(signalB(:,:),0,2)/sqrt(size(signalB,2)))], ...
%     [0.7 0.7 1]);
% set(h,'EdgeColor','None'); hold on;

plot(t, mean(signalA,2),'r'); hold on;
% plot(t, mean(signalB,2),'b'); hold on;

% legend ('signalA', 'signalB' );
% ylim([0.5, 1.05])



% %%%%%%%%%%% Two-sample ttest for Jackknife'ed data %%%%%%%%
% % https://en.wikipedia.org/wiki/Student%27s_t-test#Equal_or_unequal_sample_sizes,_similar_variances_(1/2_%3C_sX1/sX2_%3C_2)
% m1 = mean(PeakValueA);
% m2 = mean(PeakValueB);
% s1 = std(PeakValueA)*(length(PeakValueA)-1);
% s2 = std(PeakValueB)*(length(PeakValueB)-1);
% 
% n1 = length(PeakValueA);
% n2 = length(PeakValueB);
% sp = sqrt( ((n1-1)*s1^2 + (n2-1)*s2^2) / (n1 + n2 - 2) );
% denom = m1 - m2;
% numer = sp * sqrt(1/n1 + 1/n2);
% tscore = denom / numer;
% % Then enter your tscore to the web-based p-value calculater at:
% % https://www.socscistatistics.com/pvalues/tdistribution.aspx
% % The above tscore was 2.49, DF was (n1-1) + (n2-1) = 56,
% % hypothesis was two-tailed.
% pvalue = 0.015769;  %<-

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%