function msg=oscwrite(tag,cdata)
% OSC Data Coder
% msg=oscread(tag,cdata);
%     tag   : tag information (char)
%     cdata : data array (cell)
%     msg   : osc message
%
% (ex.1)
% % Sending floating and integer number data
% tag='/test/';
% ddata=[{1};{-1};{int32(1)};{int32(-1)}]; % float,float,int,int
% Hs=dsp.UDPSender('RemoteIPPort',7000);
% msg=oscwrite(tag,ddata);
% step(Hs, msg);
% release(Hs);
%
% (ex.2)
% % Sending 'bang' message
% Hs=dsp.UDPSender('RemoteIPPort',7000);
% msg=oscwrite('bang',[]);
% step(Hs, msg);
% release(Hs);

% tag 
if isempty(tag)
    TAG='data';
else
    TAG=char(tag);
    zI=find(TAG==0,1,'first');
    if ~isempty(zI)
        TAG=TAG(1:find(TAG==0,1,'first')-1);
    end
end

tlen=(floor(length(TAG)/4)+1)*4;
TAG=[TAG zeros(1, tlen-length(TAG))];

% format and data
if isempty(cdata)
    FRM=zeros(1,4);
    FRM(1)=',';
    DATA=zeros(1,4);
else
    if ~iscell(cdata)
        error('cdata must be a cell array.')
    end

    % data format
    FRM(1)=',';
    % data
    DATA=[];
    cdata=reshape(cdata,1,numel(cdata));
    for id=1:length(cdata)
        tmp=cell2mat(cdata(id));
        FRM(end+1)=ischar(tmp)*'s'+isinteger(tmp)*'i'+isfloat(tmp)*'f';
        tmp=reshape(tmp,1,numel(tmp));
        switch FRM(end)
            case 's'    % char
                zI=find(tmp==0,1,'first');
                if ~isempty(zI)
                    tmp=tmp(1:find(tmp==0,1,'first')-1);
                end
                tmplen=(floor(length(tmp)/4)+1)*4;
                tmpData=[tmp zeros(1,tmplen-length(tmp))];
            case 'i'    % integer (32bits)
                FRM(end+(0:numel(tmp)-1))='i';
                tmpData=fliplr(typecast(int32(tmp),'uint8'));
            case 'f'    % floating (32bits)
                FRM(end+(0:numel(tmp)-1))='f';
                tmpData=fliplr(typecast(single(tmp),'uint8'));
            otherwise
        end
        DATA=[DATA tmpData];
    end
    frmlen=(floor(length(FRM)/4)+1)*4;
    FRM=[FRM zeros(1,frmlen-length(FRM))];
end

msg=uint8([TAG FRM DATA]);
