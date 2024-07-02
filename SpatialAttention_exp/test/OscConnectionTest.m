%%%  %%% 
%%% - 
%%%
%%% required Add-ons
%%% - 
%%% required functions
%%% - 
%%% required setting files
%%% - 

%%% v3
%%% 4/14/2022 replaced devicewrite to PsychToolbox
%%% v4
%%% 20220918 added SNR threshold program
%%% v5
%%% 20221109 made new hardware option 'Biosemi wih Actiview'
%%% v6 
%%% 20230111 specialized for BDF processing

%% variables

opts = detectImportOptions('answer.csv'); %answer sheet
opts.Delimiter = {','}; %separation optoion
corTable = readtable('answer.csv',opts); %load answer reference file
corTable = table2array(corTable(:,1:2)); %reference of responce and answer

%%% for OSC %%%
% ip = '192.168.0.107'; %ip adress for iPad
% ip = '169.254.59.188'; %ip adress for iPad
ip = '169.254.120.172'; %LAB(Sungyoung)'s iPad
% ip = '169.254.165.177'; %Akira's iPad with Macbook network
% ip = '192.168.10.100'; %Akira's iPad with Tohoku localnet

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



%% OSC preparing - clear all message
Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
commentReset = oscwrite(indicator, {''});
step(Hs, commentReset);

conditionReset = oscwrite(condition, {''});
step(Hs, conditionReset);

trialReset = oscwrite(trial_indicator, {''});
step(Hs, trialReset);

totalReset = oscwrite(total_indicator, {''});
step(Hs, totalReset);

totalReset = oscwrite(first_indicator, {''});
step(Hs, totalReset);

totalReset = oscwrite(second_indicator, {''});
step(Hs, totalReset);

ledstatus = {0}; % turn off the LED
ledOn = oscwrite(led, ledstatus);
step(Hs, ledOn);

ledOn = oscwrite(led2, ledstatus);
step(Hs, ledOn);

release(Hs)


%% experiment
Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
commentSet = oscwrite(indicator, {'1 sec'});
step(Hs, commentSet);
release(Hs)
pause(1);
commentSet = oscwrite(indicator, {'touch the panel'});
step(Hs, commentSet);
release(Hs)

Hr=dsp.UDPReceiver('LocalIPPort',incoming); %make a port
dR=[];

outRest = 0;
disp('touch the panel')

% excute until coming some message from iPad
while outRest == 0
    dR=step(Hr); %dignal from iPad
    if isempty(dR)==0
        [tag, data]=oscread(dR);
        % disp([tag num2str(data')]);
        break
    end
end
release(Hr);

commentSet = oscwrite(indicator, {'connected'});
step(Hs, commentSet);
release(Hs)

Hs = dsp.UDPSender('RemoteIPAddress',ip,'RemoteIPPort',outgoing);
commentSet = oscwrite(indicator, {'connected'});
step(Hs, commentSet);
release(Hs)
