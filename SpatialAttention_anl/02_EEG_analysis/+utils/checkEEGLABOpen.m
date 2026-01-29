% isEEGLABOpen % 
% - judge whether EEGLAB is open or not
%
% required Add-ons
% - 
% required functions
% - 

% v1  
% 20240716 to skip reopen EEGLAB

function isEEGLABOpen = checkEEGLABOpen()
    eeglabFig = findall(0, 'Type', 'figure', 'Tag', 'EEGLAB');
    if isempty(eeglabFig)
        isEEGLABOpen = false;
    else
        isEEGLABOpen = true;
    end
end
