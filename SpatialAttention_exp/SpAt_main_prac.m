
%  SpAt_main_prac % 
% - practice version of the CRM test
%
% #required Add-ons
% - 
%
% #required Add-ons
% - Psychportaudio
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
% 

%% variables

% for OSC
% ip = '192.168.0.107';
ip = '169.254.120.172'; %LAB(Sungyoung)'s iPad
% ip = '169.254.153.246'; %Akira's iPad
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


%% audio info
out = PsychPortAudio('GetDevices'); %get sound device information for Psychtool box
prompt = 'Choose Audio device'; % prompt message
[DevID_indx,tf] = listdlg('PromptString',prompt,'SelectionMode','single','ListSize',[200 150],'ListString',{out.DeviceName}); % option selection window
DevID = DevID_indx - 1; %the ID of Psychtoolbox starts with 0
numSpk = 3; % Number of loudspeakers
buffer = 100; %playback buffer size
fs = 48000; % sample rate for audio
volume = 1; % stimuli volume
restintvl = 2; % interval between each test block

InitializePsychSound %PsychTool Box
pahandle = PsychPortAudio('Open', DevID, [], 2, fs, numSpk, buffer); % must be the same parameters with the current AUDIO Hardware such as FS, etc.

%% get parsonal data
prompt = {'Enter your name:'};
dlgtitle = 'Input';
dims = [1 35];
definput = {'name'};
answer = inputdlg(prompt,dlgtitle,dims,definput);

subj = cell2mat(answer(1));

timestamp = datestr(now,'yyyymmddTHHMMSS');
filename = ['Subj_' subj '_' timestamp];
% mkdir(sprintf('subject/%s',filename));

%% make stimulus table
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

restposition = restintvl:restintvl:numTrial;

disp('finish making soundlist')

%% OSC preparing - clear all message
Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
commentReset = utils.oscread(indicator, {''});
step(Hs, commentReset);

conditionReset = utils.oscread(condition, {''});
step(Hs, conditionReset);

trialReset = utils.oscread(trial_indicator, {''});
step(Hs, trialReset);

totalReset = utils.oscread(total_indicator, {''});
step(Hs, totalReset);

totalReset = utils.oscread(first_indicator, {''});
step(Hs, totalReset);

totalReset = utils.oscread(second_indicator, {''});
step(Hs, totalReset);

ledstatus = {0}; % turn off the LED
ledOn = utils.oscread(led, ledstatus);
step(Hs, ledOn);

ledOn = utils.oscread(led2, ledstatus);
step(Hs, ledOn);

release(Hs)

%% experiment
Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
commentSet = utils.oscread(indicator, {'Press any key to start'});
step(Hs, commentSet);
release(Hs)

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

% WaitSecs(2)

responce = cell(numTrial,4);

% try
    for i = 1:numTrial
        MesST = sprintf('trial %d begins', i);
        disp(MesST)

        Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
        trialnumber = {i};
        trialSet = utils.oscread(trial_indicator, trialnumber);
        step(Hs, trialSet);
        
        total = {sprintf('/ %d',numTrial)};
        totalSet = utils.oscread(total_indicator, total);
        step(Hs, totalSet);
        
        % indicate current task
        commentSet = utils.oscread(indicator, {'Pay attention to the voice from "Ready"'});
        step(Hs, commentSet);

        conditionSet = utils.oscread(condition, {'Single'});
        step(Hs, conditionSet);            
        
        release(Hs);
        
        WaitSecs(1)
        
        % Prepare sound
        restime = tic;
        [stimulus, duration] = data.makestimulus(targets(i), fs, Spats(i), starttimes(i), SNRs(i), numSpk);
        
        PsychPortAudio('Volume', pahandle, volume); %adjust volume
        PsychPortAudio('FillBuffer', pahandle, stimulus');   % load stimulus
%         starttime = streamlength+table.StartTime(i);
        
        % Play sound   
        PsychPortAudio('Start',pahandle);               % playback
        WaitSecs(duration/fs);

        % Answer responce %
        % answer responce
        MesAT = sprintf('trial %d Answer time', i);
        disp(MesAT)

        ledstatus = {1}; % turn on the LED
        Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
        ledOn = utils.oscread(led, ledstatus);
        step(Hs, ledOn);
        release(Hs);
        
        % indicater
        Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
        commentSet = utils.oscread(indicator, {'Answer "Color" and "Number"'});
        step(Hs, commentSet);
        release(Hs);
        
        stat=true;
        t = timer('TimerFcn','stat=false','StartDelay',10); %answer time: 10 sec
        start(t);

        % get responce
        Hr=dsp.UDPReceiver('LocalIPPort',incoming);
        dR=[];
        
        % excute until coming some message from iPadk
        while (stat==true)
            dR=step(Hr);
            if isempty(dR)==0
                [tag, data]=utils.oscread(dR);
                %                 disp([tag num2str(data')]);
                break
            end
        end

        MesAE = sprintf('trial %d Answer time ends \n', i);
        disp(MesAE)

        if stat == false
            tag = 'NA';
            commentSet = utils.oscread(indicator, {'TIME UP'});
        else
            commentSet = utils.oscread(indicator, {'Sent'});            
        end
        
        step(Hs, commentSet);
        release(Hs);
        
        release(Hr);
        time = toc(restime);
        delete(t);
        res = tag;
        
        responce(i,1) = {res};
        responce(i,3) = {time};
        
        ledstatus = {0}; % turn off the LED
        Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
        ledOn = utils.oscread(led, ledstatus);
        step(Hs, ledOn);
        release(Hs);
        
        % take a rest
        if find(i==restposition)
            disp('taking a break...')

            Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
            commentSet = utils.oscread(indicator, {'Take a rest. Press any key to continue'});
            step(Hs, commentSet);
            release(Hs);
            
            WaitSecs(1)
            
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
            
            WaitSecs(1)
        end
        
        WaitSecs(1)
    end
    
    Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
    commentSet = utils.oscread(indicator, {'Finish'});
    step(Hs, commentSet);
    release(Hs)
%     
% catch
%     Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
%     commentSet = utils.oscread(indicator, {'ERROR'});
%     step(Hs, commentSet);
%     release(Hs)
%     
%     save(sprintf('subject/%s/backup.mat',filename))
%     delete(sprintf('data/%s/',filename))
%     
% end


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

