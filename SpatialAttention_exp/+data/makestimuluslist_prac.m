function [stimulusTable] = makestimuluslist_SNR_EEGv4_prac(sbjname)

%%% 20220308 v2:new CRM: started improvement only for single talker %%%
%%% 20220322 v3:adjusted masker length and various SNR %%%
%%% 20221022 v4:for experiment v4 %%%
%%% 20221109   even number of colors
%%%%%%%%%%%% make sure the particular number is assigned to 'standardAmount'  

%% make dir
% sbjname = 'test';
% spatial = 1;
mkdir(sprintf('data/%s',sbjname))

%% variables
% spatialpattern = 1
                    % 1...left - right
                    % 2...left - backcenter
numSP = 2; % number of spatial pattern
sn = [-12 -6]; %signal/noise ratio
numSNR = size(sn,2); % number of SNR
numGen = 2; % male:taker0 and female:taker1) (number of gender)
numCol = 4; %colors: blue, red, white, green
numSph = 4; % speech amount (repeatation of the same situation(SP, SNR, Gen)) 
%!numSph should be a multiple of numCol to use all the colors evenly!
%note: 
%----- if numSph< 8 numbers are random
%----- if numSph>=8 use 1-8 and additional numbers are random
totalamount = numSP * numSNR * numGen * numSph;
sign = '00'; %fixed: Charlie

fs = 48000; % frequency sampling rate
StartRange = [1.5 3.5]*fs; % taget's startv time range (sec)

%% make list
listnum = 1;

%%% extract speech list
Targetlisttemp = cell(3*7,1);
for i = 0:3
    color = strcat('0',string(i)); %color index
    for j = 0:7
        number = strcat('0',string(j)); % (speech) number index            
        Targetlisttemp{listnum} = strcat(sign, color, number);
        listnum = listnum + 1;
    end          
end

%%% make entire list
listnum = 1;
Target = cell(totalamount,1);
StartTime = zeros(totalamount,1);

for i = 1:numGen
    talker = (i-1)*4; % talker index
    for j = 1:numSNR
        SNRlist(listnum:listnum+numSP*numCol*numSph-1) = sn(j);
        for k = 1:numSP    
            SPlist(listnum:listnum+numCol*numSph-1) = k;
            for l = 1:numCol 
                for m =1:numSph/numCol
                    if m <= 8 && numSph/numCol>=8
                        Target{listnum} = strcat(Targetlisttemp{8*(l-1)+m}); %include all numbers at least
                    else
                        Target{listnum} = strcat(Targetlisttemp{8*(l-1)+randi([1 8])}); % in case of the number of speeches exceeds 8
                    end
                    StartTime(listnum) = randi(StartRange); %store start time
    
                    stimulusDataList(listnum) = strcat(string(talker), Target{listnum});
                    listnum = listnum + 1;
                end
            end
        end          
    end
end

% randomize lists
randomlist = randperm(totalamount); %sort order randomly
SNRlist = SNRlist(randomlist);
SPlist = SPlist(randomlist);
stimulusDataList = stimulusDataList(randomlist);
%% make stimulus table

stimulusTable = table((1:totalamount)',(1:totalamount)', stimulusDataList', SPlist', zeros(totalamount,2), zeros(totalamount,2), zeros(totalamount,2), StartTime, SNRlist');
stimulusTable.Properties.VariableNames = {'No.' 'PlayOrder' 'StimulusCharactor' 'SpatialPosition' 'Responce' 'Answer' 'ResponceTime' 'StartTime' 'SNR'};

