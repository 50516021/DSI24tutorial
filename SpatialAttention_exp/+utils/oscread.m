function [tag, data]=oscread(rdata)
% OSC Data Decoder
% [tag, data]=oscread(rdata);
%     tag   : tag information
%     data  : data array (cell)
%     rdata : receiving data (OSC format)
%
% (example)
% Hr=dsp.UDPReceiver('LocalIPPort',7000);
% dR=[];
%
% % excute until coming 'bang' signal
% while isempty(strfind(char(dR'),'bang'));
%     dR=step(Hr);
%     if isempty(dR)==0;
%         [tag, data]=oscread(dR);
%         disp([tag num2str(data')]);
%     end
% end
% release(Hr);

% Check Tag Information (8 bytes boundary)
if iscell(rdata)
    tmp=cell2mat(rdata);
else
    tmp=rdata;
end
tagLen=ceil(find(tmp==0,1,'first')/4)*4;
tag=char(tmp(1:tagLen)');

% Check Format (8 byte boundary)
tmp=tmp(tagLen+1:end);
formatLen=ceil(find(tmp==0,1,'first')/4)*4;
if tmp(1)~=','
    disp('Wrong OSC format')
    return;
end
format=char(tmp(2:formatLen)');

% Extract Data (32 bits each)
data=[];
dataLen=find(format>0,1,'last');
if isempty(dataLen)==0
    data=cell(dataLen,1);
    tmp=tmp(formatLen+1:end);
    for n=1:dataLen;
        switch format(n)
            case 'i'    % int32
                bData=flipud(tmp(1:4));
                data(n)=num2cell(typecast(bData,'int32'));
                if length(tmp)>4
                    tmp=tmp(5:end);
                end
            case 'f'    % float32
                bData=flipud(tmp(1:4));
                data(n)=num2cell(typecast(bData,'single'));
                if length(tmp)>4
                    tmp=tmp(5:end);
                end
            case 's'    % script
                sInd=find(tmp==0,1,'first');  % Search '0x00'
                bData=tmp(1:sInd);
                data(n)={char(bData')};
                sInd=ceil((sInd+1)/4)*4;
                if length(tmp)>sInd
                    tmp=tmp(sInd+1:end);
                end
            otherwise   % invalid format
                disp(['Invalid Format: ' format(n)])
                return;
        end
    end
end
