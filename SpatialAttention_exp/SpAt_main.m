%  SpAt_main % 
% - main experiment script of EEG measurement on CRM (SRT) test
%
% #required Add-ons
% - Psychportaudio
% 
% 
% #required functions
% - data/
% -- makestimuluslist.m
%   stimulus list maker (all stimulus info included)
% -- makestimulus.m
%   stimulus maker for v4
% - utils/
% -- oscread.m
%
% -- oscwrite.m
% 
% #required setting files
% 
% #latest updates
% 20240503 minor changes from Japanese exps

close all;

%% basic parameters

% for OSC %
% ip = '192.168.0.107'; %ip adress for iPad
ip = '169.254.120.172'; %LAB(Sungyoung)'s iPad

%% new or continue
ExpSt = ["New Experiment" "Continuation"]; %experiment status
prompt = 'New or Continued?'; %prompt message
[ExpSt,tf] = listdlg('PromptString',prompt,'SelectionMode','single','ListSize',[120 100],'ListString',ExpSt); % option selection window

if ExpSt == 1
    clearvars;
    ExpSt = 1;
    startpoint = 1;
    disp('NEW Expeiriment')
else
    % subject number %
    prompt = {'Enter subjects number:'}; 
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'00000'};
    answerNum = inputdlg(prompt,dlgtitle,dims,definput);
    sNum = answerNum{1};
    
    % experiment name %
    datadir = 'subject/';
    folders = struct2table(dir([datadir, 's', sNum, '*']));
    prompt = 'Choose folder name:';  % prompt message
    [foldInd,tf] = listdlg('PromptString',prompt,'SelectionMode','single','ListSize',[250 200],'ListString',folders.name); % option selection window
    experiment_name = folders.name(foldInd,:); %subject (experiment) name
    
    if iscell(experiment_name)
        experiment_name = experiment_name{:};
    end

    load(strcat(datadir, experiment_name, "/backup.mat"))

    startpoint  = trialcount;
    prompt = {'Restart point?:'}; 
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {num2str(startpoint)};
    startpoint = str2double(cell2mat(inputdlg(prompt,dlgtitle,dims,definput)));

    ExpSt = 2; %overwrite
    MsgCont = sprintf('CONTINUED Expeiriment from %d', startpoint);
    disp(MsgCont)
end

%% variables

answerfile_path = 'test/answer.csv';
opts = detectImportOptions(answerfile_path); %answer sheet
opts.Delimiter = {','}; %separation optoion
corTable = readtable(answerfile_path,opts); %load answer reference file
corTable = table2array(corTable(:,1:2)); %reference of responce and answer

outgoing = 7001; % for dsp.UDPSender -- port(incoming) on iOS app side
incoming = 7000; % for dsp.UDPReceiver -- port(outgoing) on iOS app side

indicator = '/label/main';
condition = '/label/condition';
trial_indicator = '/label/trial';
total_indicator = '/label/total';
first_indicator = '/label/1st';
second_indicator = '/label/2nd';
led = '/led';
led2 = '/led2';

%%% for EEG (only for Biosemi and DSI-24 from v6) %%%
devOpt = ["Biosemi" "DSI-24"]; % EEG device option
dev = 2; %only DSI-24 for Japanese version
devicename = devOpt(dev); % set device name
durTrigger = .03; %trigger duration for DSI-24
durInterval = .05; %trigger interval duration for DSI-24
baudrate = [115200 9600]; %baud rate for trigger (Biosemi: 115200, DSI-24: 9600)

% starttime = 6; %entire sound starttime (in case fixed)
% use 'ls /dev/tty.*' to specify the port ID
comport = ls('/dev/tty.usb*'); %automatically get the port (only for Mac OS)
comport = comport(1:end-1);
% comport = '/dev/cu.usbserial-DN36PGTH';
% comport = 'COM4';
targetdur = 2.8; %target time duration

%% audio info
out = PsychPortAudio('GetDevices'); %get sound device information for Psychtool box
prompt = 'Choose Audio device'; % prompt message
[DevID_indx,tf] = listdlg('PromptString',prompt,'SelectionMode','single','ListSize',[200 150],'ListString',{out.DeviceName}); % option selection window
DevID = DevID_indx - 1; %the ID of Psychtoolbox starts with 0
numSpk = 3; % Number of loudspeakers
fs = 48000; % sample rate for audio
buffer = 100; %playback buffer size
volume = 1; % stimuli volume
restintvl = 20; % interval between each test block

InitializePsychSound; %PsychTool Box
pahandle = PsychPortAudio('Open', DevID, [], 2, fs, numSpk, buffer); % must be the same parameters with the current AUDIO Hardware such as FS, etc.

%% get parsonal data
if ExpSt == 1
    prompt = {'Enter subjects number:'}; %subject number
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'00000'};
    answerNum = inputdlg(prompt,dlgtitle,dims,definput);
    sNum = answerNum{1};
    
    prompt = {'Enter subjects name:'}; %subject name (excluding date)
    dlgtitle = 'Input';
    dims = [1 35];
    definput = {'rit2024_MMDDHH'};
    answerName = inputdlg(prompt,dlgtitle,dims,definput);
    subj = cell2mat(answerName(1));
    
    timestamp = datestr(now,'yyyymmddTHHMMSS'); %time stamp (additional information)
    filename = strcat('s', sNum, '_', subj, '_', timestamp, '_', devicename);
    mkdir(sprintf('subject/%s',filename));
end

%% make stimulus table
if ExpSt == 1 %whwther new or continued
    disp('making stimuli list')
    table = data.makestimuluslist(filename);
    
    table2 = table;
    save('restemp.mat','table2');
    
    soundlist = sortrows(table2array(table(:,1:2)),2);
    numTrial = size(soundlist,1);
    targets = table2array(table(:,3)); % target names
    Spats = table2array(table(:,4)); % 0-1-2  
    starttimes = table2array(table(:,8)); % start time in 48k Hz 
    SNRs = table2array(table(:,9)); % signal to noise ratio
    Triggers = zeros(numTrial,5); % save the amount of triggers
    
    restposition = restintvl:restintvl:numTrial;
    
    responce = cell(numTrial,4); %answer responces
    disp('finish making soundlist')
else
    disp('SKIP making soundlist')
end

%% OSC preparing - clear all message
Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
commentReset = utils.oscwrite(indicator, {''});
step(Hs, commentReset);

conditionReset = utils.oscwrite(condition, {''});
step(Hs, conditionReset);

trialReset = utils.oscwrite(trial_indicator, {''});
step(Hs, trialReset);

totalReset = utils.oscwrite(total_indicator, {''});
step(Hs, totalReset);

totalReset = utils.oscwrite(first_indicator, {''});
step(Hs, totalReset);

totalReset = utils.oscwrite(second_indicator, {''});
step(Hs, totalReset);

ledstatus = {0}; % turn off the LED
ledOn = utils.oscwrite(led, ledstatus);
step(Hs, ledOn);

ledOn = utils.oscwrite(led2, ledstatus);
step(Hs, ledOn);

release(Hs)

%% instantiate LSL %for EEG
%resolve a trigger stream...
disp(fprintf('Resolving an Trigger stream; %s', devicename));
result = {};

obj.sp = serialport(comport,baudrate(dev),'DataBits',8,'StopBits',1);
fopen(obj.sp); %open trigger port

disp('Connected');
fwrite(obj.sp,0); WaitSecs(durInterval); %[trigger] initialization
disp('Port opened');

disp('finish trigger preparation. ')

%% experiment

% check recording
rec = ""; %recording confirmation message
while rec ~= "Yes, start the experimnet"
    rec = questdlg("EEG Recording Started?", 'Recording Check', "Yes, start the experimnet", "Not Yet", "Not Yet");
end

Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
commentSet = utils.oscwrite(indicator, {'Press any key to start'});
step(Hs, commentSet);
release(Hs)

Hr=dsp.UDPReceiver('LocalIPPort',incoming); %make a port
dR=[];

outRest = 0;
disp('finish OSC preparation.')

% excute until coming some message from iPad
while outRest == 0
    dR=step(Hr); %signal from iPad
    if isempty(dR)==0
        [tag, data]=utils.oscread(dR);
        % disp([tag num2str(data')]);
        break
    end
end
release(Hr);

% WaitSecs(2)
fwrite(obj.sp,250); WaitSecs(durTrigger); %[trigger] grand start
fwrite(obj.sp,0); WaitSecs(durInterval)
responce = cell(numTrial,4); %answer responces


disp('START.')
try
    for i = startpoint:numTrial
        trialcount = i; %for backup
        MesST = sprintf('trial %d/%d begins', i, numTrial);
        disp(MesST)
        
        Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
        trialnumber = {i};
        trialSet = utils.oscwrite(trial_indicator, trialnumber);
        step(Hs, trialSet);
        
        total = {sprintf('/ %d',numTrial)};
        totalSet = utils.oscwrite(total_indicator, total);
        step(Hs, totalSet);
        
        % indicate current task
        commentSet = utils.oscwrite(indicator, {'Pay attention to the voice from "Ready"'});
        step(Hs, commentSet);
    
        conditionSet = utils.oscwrite(condition, {'Single'});
        step(Hs, conditionSet);            
        
        release(Hs);
        
        WaitSecs(1) %time of baseline
        
        % Prepare sound
        restime = tic;
        [stimulus, duration] = data.makestimulus(targets(i), fs, Spats(i), starttimes(i), SNRs(i), numSpk);
        
        PsychPortAudio('Volume', pahandle, volume); %adjust volume
        PsychPortAudio('FillBuffer', pahandle, stimulus');   % load stimulus
      
        
        % Play sound
        % EEG acquisition %
    
        % Biosemi with Actiview / DSI-24 %
        PsychPortAudio('Start',pahandle);               % playback          
        
        fwrite(obj.sp,240); WaitSecs(durTrigger); %[trigger] masker onset
        fwrite(obj.sp,0);
        
        WaitSecs(starttimes(i)/fs-durTrigger); %wait for target onset

        fwrite(obj.sp,230); WaitSecs(durTrigger); %[trigger] target onset
        fwrite(obj.sp,0);

        WaitSecs(targetdur - durTrigger); %wait for stream offset
       
        fwrite(obj.sp,220); WaitSecs(durTrigger); %[trigger] stream offset
        fwrite(obj.sp,0); 
        
        WaitSecs(.50); %blank after the target
%         WaitSecs(.25); %blank between the stream and answer session
        
        % Answer responce %
        MesAT = sprintf('trial %d/%d Answer time', i, numTrial);
        disp(MesAT)

        ledstatus = {1}; % turn on the LED
        Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
        ledOn = utils.oscwrite(led, ledstatus);
        step(Hs, ledOn);
        release(Hs);

        % indicater
        Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
        commentSet = utils.oscwrite(indicator, {'Answer "Color" and "Number"'});
        step(Hs, commentSet);
        
        release(Hs);
        
        stat=true;
        t = timer('TimerFcn','stat=false','StartDelay',10); %answer time: 10 sec
        start(t);
        % get responce
        Hr=dsp.UDPReceiver('LocalIPPort',incoming);
        dR=[];
        
        % excute until coming some message from iPad
        while (stat==true)
            dR=step(Hr);
            if isempty(dR)==0
                [tag, data]=utils.oscread(dR);
                %                 disp([tag num2str(data')]);
                break
            end
        end

        fwrite(obj.sp,210); WaitSecs(durTrigger); %[trigger] answer input (responded)
        fwrite(obj.sp,0); WaitSecs(durInterval);
            
        MesAE = sprintf('trial %d/%d Answer time finish \n', i, numTrial);
        disp(MesAE)

        if stat == false
            tag = 'NA';
            commentSet = utils.oscwrite(indicator, {'TIME UP'});
        else
            commentSet = utils.oscwrite(indicator, {'Sent'});            
        end
    
        step(Hs, commentSet);
        release(Hs);
            
        release(Hr);
        time = toc(restime);
        delete(t);
        res = tag;
        
        responce(i,1) = {res};
        responce(i,3) = {time};
        
        %%% answer info %%%    
        [TgCAns, TgIAns, TgAuth, TgSpt, TgSNR] = AnsConvert(i, res, corTable, targets, Spats, SNRs);
        
        fwrite(obj.sp,TgCAns); WaitSecs(durTrigger); %[trigger] correct answer
        fwrite(obj.sp,0); WaitSecs(durInterval); 
        fwrite(obj.sp,TgIAns); WaitSecs(durTrigger); %[trigger] input answer
        fwrite(obj.sp,0); WaitSecs(durInterval); 
        fwrite(obj.sp,TgAuth); WaitSecs(durTrigger); %[trigger] authenticity
        fwrite(obj.sp,0); WaitSecs(durInterval); 
        fwrite(obj.sp,TgSpt);  WaitSecs(durTrigger); %[trigger] spatial pattern
        fwrite(obj.sp,0); WaitSecs(durInterval); 
        fwrite(obj.sp,TgSNR);  WaitSecs(durTrigger); %[trigger] SNR
        fwrite(obj.sp,0); WaitSecs(durInterval); 
%         WaitSecs(durAdjust); %time adjustment
        Triggers(i,:) = [TgCAns, TgIAns, TgAuth, TgSpt, TgSNR]; % save the amount of triggers
        %%%%%%%%%

        ledstatus = {0}; % turn off the LED
        Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
        ledOn = utils.oscwrite(led, ledstatus);
        step(Hs, ledOn);
        release(Hs);
    
        % take a rest
        if logical(sum(find(i==restposition))) && (i ~= numTrial) %every rest position exclding the final trial
            MesBrk = sprintf('| taking a break... (%d/%d trials have been done) |', i, numTrial);
            disp(MesBrk) % status message

            Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
            commentSet = utils.oscread(indicator, {'Take a rest. Press any key to continue'});
            step(Hs, commentSet);
            release(Hs);
            
            WaitSecs(0.5)
            
            Hr=dsp.UDPReceiver('LocalIPPort',incoming);
            dR=[];
            
            outRest = 0;
            % excute until coming some message from iPad
            while outRest == 0
                dR=step(Hr);
                if isempty(dR)==0
                    [tag, data]=utils.oscread(dR);
                    % disp([tag num2str(data')]);
                    break
                end
            end
            release(Hr);
            
            Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
            commentSet = utils.oscread(indicator, {''});
            step(Hs, commentSet);
            release(Hs)
            
            WaitSecs(0.5)
        end
        
        WaitSecs(1)
    end
    
    fwrite(obj.sp,250); WaitSecs(durTrigger); %[trigger] grand end
    fwrite(obj.sp,0); WaitSecs(durInterval)
    
    fclose(obj.sp);
    delete(obj.sp);
    
    Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
    commentSet = utils.oscread(indicator, {'Finished. Thank you!'});
    step(Hs, commentSet);
    release(Hs)
    
catch
    Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
    commentSet = utils.oscread(indicator, {'ERROR'});
    step(Hs, commentSet);
    release(Hs)

fclose(obj.sp);
delete(obj.sp);

end

%% export results
for i = 1:size(responce,2)-2
    for j = 1:size(responce,1)
        target = cell2mat(responce(j,i));
        if ~isempty(target)
            responce(j,i) = {strtrim(target)};
        end
    end
end

dat = horzcat(array2table(soundlist), cell2table(responce));
dat = sortrows(dat,1);

res = horzcat(table,dat);
res = removevars(res, {'Responce' 'ResponceTime' 'soundlist1' 'soundlist2'});
res = movevars(res, 'responce2', 'After','SpatialPosition');
res = movevars(res, 'responce1', 'After','SpatialPosition');
res = movevars(res, 'responce4', 'After','Answer');
res = movevars(res, 'responce3', 'After','Answer');
res =  addvars(res, Triggers, 'After','SNR');

save(sprintf('subject/%s/res_%s.mat',filename, filename),'res')

%% functions %%%%%%%%%
function [TgCAns, TgIAns, TgAuth, TgSpt, TgSNR] = AnsConvert(i, res, corTable, targets, Spats, SNRs)

TgAuth = [200 201]; %authenticity (correct/incorrect)
% TgCAns = [160 198]; %correct answer (161 - 198)
% TgIAns = [010 149]; %input answer (111 - 148)
TgSNR  = [100 105]; %SNR pattern (-12/-18)
TgSpt  = [106 109]; %Spatial pattern (front/back)

    % correct answer
    CGen = extractBefore(targets(i),2); %correct gender (0-8)
    Ccolor = extractBetween(targets(i),4,5); %correct color (0-3)
    Cnumber = extractBetween(targets(i),6,7); %correct number

    TgCAns = str2double(CGen(1))/4*100+(str2double(Ccolor(1))+6)*10+str2double(Cnumber(1)); %trigger value of correct answer
    AnsCrt = extractBetween(targets(i),4,7);

    % input answer
    tempAns = strip(strcat(res,'n'),'right','n'); %delete blank        
    idx = strfind(corTable(:,1),tempAns,'ForceCellOutput',1); %find index of the answer
    for k = 1:length(idx)
        check(k) = ~isempty(idx{k}); %make index matrix 
    end
    if sum(check) %in case received the answer
        for k = 1:length(idx)
            if cell2mat(idx(k))
                row = k;
            end
        end
        AnsIpt = corTable(row,2); %inputted answer

        Icolor = extractBetween(AnsIpt,1,2); %input color (0-3)
        Inumber = extractBetween(AnsIpt,3,4); %input number (0-8)
        TgIAns = 100+(str2double(Icolor(1))+1)*10+str2double(Inumber(1)); %trigger value of correct answer
    else %in case not received the answer
        AnsIpt = {'9999'};
        TgIAns = 149; %trigger value of correct answer
    end
  
    %authenticity
    TgAuth = TgAuth((AnsCrt == AnsIpt{1,1})+1);

    % spatial pattern
    TgSpt = TgSpt(Spats(i)); %assign Trigger value of spatial pattern

    % SNRs
    TgSNR = TgSNR(mod(abs(SNRs(i)),12)/6+1); %assign Trigger value of spatial pattern
end