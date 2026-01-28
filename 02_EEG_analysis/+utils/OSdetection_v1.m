%%% OSdetection  %%% 
%%% - Operation Software detection that returns Os flag and its name
%%%
%%% required Add-ons
%%% - 
%%% - 
%%% required functions
%%% - 
%%% required setting files
%%% - 

%%% v1  
%%% 20230927 OS detection that returns Os flag and its name

function OSflag = OSdetection_v1()

if ismac
    OSflag = [1, "Mac"];
elseif ispc
    OSflag = [2, "Windows"];
elseif isunix
    OSflag = [3, "Unix"];
else
    disp('Platform not supported')
end
