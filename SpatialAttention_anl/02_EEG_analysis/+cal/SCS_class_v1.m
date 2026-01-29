% SCS grouping classification with single threshold % 
% - for strong/weak SCS, used only SCS is non-binary
% 
% required Add-ons
% - 
% required functions
% - 
% required setting files
% - 

% v1  
% 20250825 SCS threshold (strong - weak SCS)


function SCS = SCS_class_v1(SCS_score, SCS_thr, varGrp_thr)

if length(varGrp_thr) == 4
    if SCS_score < 0 %independent
        if abs(SCS_score) >= SCS_thr
            SCS_ind = 1;
        else
            SCS_ind = 2;
        end
    elseif SCS_score > 0 %interdependent
        if abs(SCS_score) >= SCS_thr
            SCS_ind = 3;
        else
            SCS_ind = 4;
        end
    end
elseif length(varGrp_thr) == 3
    if SCS_score < 0 %independent
        if abs(SCS_score) >= SCS_thr
            SCS_ind = 1;
        else
            SCS_ind = 2; % weak
        end
    elseif SCS_score > 0 %interdependent
        if abs(SCS_score) >= SCS_thr
            SCS_ind = 3;
        else
            SCS_ind = 2; % weak
        end
    end
end

SCS = varGrp_thr(SCS_ind);
       

