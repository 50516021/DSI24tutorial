%%% makeTriggertest_BDF.m %%% 
%%% - test for trigger communication for Actiview/DSI Streamer
%%%
%%% required Add-ons
%%% - 
%%% required functions
%%% - 
%%% required setting files
%%% - 

%%% v1

%%
clearvars; close all;


%%% use 'ls /dev/tty.*' to detrmin the port ID
comport = ls('/dev/tty.usb*');
comport = comport(1:end-1);


%% determin the device
devOpt = ["Biosemi" "DSI-24"]; % EEG device option
prompt = 'Choose EEG device'; % prompt message
[dev,tf] = listdlg('PromptString',prompt,'SelectionMode','single','ListSize',[150 100],'ListString',devOpt); % option selection window

%% instantiate LSL %%%for EEG
%resolve a trigger stream...
fprintf('Resolving an Trigger stream...%s\n', devOpt(dev))
result = {};

baudrate = [115200 9600]; %baud rate for trigger (Biosemi: 115200, DSI-24: 9600)

obj.sp = serialport(comport,baudrate(dev),'DataBits',8,'StopBits',1);
fopen(obj.sp);   

disp('finish trigger preparation. ')

%% experiment
        % Play sound
        %%% EEG acquisition %%%
        %%% OpenBCI %%%
        %%% Biolssemi with Actiview %%%

waittime = .03;
fwrite(obj.sp,0);

fwrite(obj.sp,250);
pause(waittime);
fwrite(obj.sp,0);
pause(waittime);

for i=1:80
    sprintf('trigger %d', i)
    fwrite(obj.sp,i);
    pause(waittime);
    fwrite(obj.sp,0);
    pause(waittime*3);
    triggers(i)=i;
end

fwrite(obj.sp,250);
pause(waittime);
fwrite(obj.sp,0);
pause(waittime);


fclose(obj.sp);
delete(obj.sp);
