function [subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationMappingProtocols_HumanEEG(gridType,protocolType)

if ~exist('gridType','var');                            gridType = 'EEG'; end

% FolderSourceString for extracted dataset
if strcmp(getenv('computername'),'RAYLABPC-ARITRA') || strcmp(getenv('username'),'RayLabPC-Aritra')
    dataFolderSourceString = 'E:\data\human\SFOri-Mapping';
else
    dataFolderSourceString = 'M:\';
end

[allSubjectNames,allExpDates,allProtocolNames,~,~,~] = eval(['allProtocolsCRFAttention' gridType 'v1']);

% stimList = cell(1,4);

if strcmp(protocolType, 'Mapping-Diagonal')
    protocolList{1} = 101:104; % Niloy NM
    protocolList{2} = 113:116; % Svee  SP
    protocolList{3} = 127:130; % Liza  LK
    protocolList{4} = 141:144; % Srishty SA
    protocolList{5} = 153:156; % Sunreeta SB
    protocolList{6} = 167:170; % Surya    SSP
    protocolList{7} = 181:184; % Saurabh  SK
    protocolList{8} = 195:198; % Divya   DG
    protocolList{9} = 209:212; % Nilanjana NN
    protocolList{10} = 223:226;% Aritra AD
    protocolList{11} = 237:240;% Ankan  AB
    
%     for iProt = 1:4
%         stimList{iProt} = 2*iProt + zeros(1,3);
%     end
%     
elseif strcmp(protocolType, 'Mapping-Horizontal')
    protocolList{1} = 105:108;
    protocolList{2} = 117:120;
    protocolList{3} = 131:134;
    protocolList{4} = 145:148;
    protocolList{5} = 157:160;
    protocolList{6} = 171:174;
    protocolList{7} = 185:188;
    protocolList{8} = 199:202;
    protocolList{9} = 213:216;
    protocolList{10} = 227:230;
    protocolList{11} = 241:244;
    
%     for iProt = 1:4
%         stimList{iProt} = [2*iProt 0 2*iProt];
%     end
end

numSubjects = length(protocolList);
subjectNames = cell(numSubjects,length(protocolList{1}));
expDates = cell(numSubjects,length(protocolList{1}));
protocolNames = cell(numSubjects,length(protocolList{1}));

for i=1:numSubjects
    for j = 1:length(protocolList{i})
        subjectNames{i,j} = allSubjectNames{protocolList{i}(j)};
        expDates{i,j} = allExpDates{protocolList{i}(j)};
        protocolNames{i,j} = allProtocolNames{protocolList{i}(j)};
    end
end


