
%% parameters
% file names
name = 'comptest_Akira'; %subject (experiment) name
outfolder =  ['subject/Subj_' name '/']; %name of the folder containing the subject's data 


load(sprintf('%sres.mat',outfolder)); %participant's responces
tgArray= table2array(res(:,12)); 



%% trigger values
TgGrand= 250; %grand start/end
TgMsk  = 240; %masker onset
TgTgt  = 230; %target onset
TgOff  = 220; %stream offset
TgAns  = 210; %answer input
TgAuth = [200 201]; %authenticity (correct/incorrect)
TgCAns = [060 098 160 198]; %correct answer (161 - 198)
TgIAns = [110 149]; %input answer (111 - 148)
TgSNR  = [100 105]; %SNR pattern (-12/-18)
TgSpt  = [106 109]; %Spatial pattern (front/back)

%% convert triggers and find missing triggers

numEvents = size(events,2); %number of triggers
co1  =1; %counter
co2 = 1; %counter2
for i =1:numEvents
    if (events(i) == TgMsk) && (events(i+1) == TgTgt) && (events(i+2) == TgOff) && (events(i+3) == TgAns) && all(events(i+4:i+8) ~= TgMsk)
        expTriggers(co1,:) = events(i+4:i+8);
        correctindx(co1) = i;
        co1 = co1+1;
    elseif (i+1<numEvents) && ((events(i) == TgMsk) || (events(i+1) == TgTgt))
        missedTgMsk(co2) = i;
        missedTgTgt(co2) = i+1;
        co2 = co2+1;
    end
end

