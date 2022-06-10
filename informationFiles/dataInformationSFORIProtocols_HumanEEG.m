function [subjectNames,expDates,protocolNames,maxGamma_SFIndex,...
            maxGamma_OriIndex,dataFolderSourceString]...
    = dataInformationSFORIProtocols_HumanEEG(gridType,protocolType)

if ~exist('gridType','var');                            gridType = 'EEG'; end

% FolderSourceString for extracted dataset
if strcmp(getenv('computername'),'RAYLABPC-ARITRA') || strcmp(getenv('username'),'RayLabPC-Aritra')
    dataFolderSourceString = 'E:\data\human\SFOri-Mapping';
else
    dataFolderSourceString = 'M:\';
end

[allSubjectNames,allExpDates,allProtocolNames,~,~,~] = eval(['allProtocolsCRFAttention' gridType 'v1']);

% stimList = cell(1,4);

if strcmp(protocolType, 'SFOri-Mapping')
    protocolList{1} = 99;   maxGamma_SFIndex{1} = 2;  maxGamma_OriIndex{1} = 4;  % NM
    protocolList{2} = 111;  maxGamma_SFIndex{2} = 2;  maxGamma_OriIndex{2} = 2;  % SP
    protocolList{3} = 125;  maxGamma_SFIndex{3} = 1;  maxGamma_OriIndex{3} = 4;  % LK
    protocolList{4} = 139;  maxGamma_SFIndex{4} = 1;  maxGamma_OriIndex{4} = 4;  % SA
    protocolList{5} = 151;  maxGamma_SFIndex{5} = 2;  maxGamma_OriIndex{5} = 3;  % SB
    protocolList{6} = 165;  maxGamma_SFIndex{6} = 1;  maxGamma_OriIndex{6} = 2;  % SSP
    protocolList{7} = 179;  maxGamma_SFIndex{7} = 1;  maxGamma_OriIndex{7} = 2;  % SK
    protocolList{8} = 193;  maxGamma_SFIndex{8} = 1;  maxGamma_OriIndex{8} = 4;  % DG
    protocolList{9} = 207;  maxGamma_SFIndex{9} = 2;  maxGamma_OriIndex{9} = 3;  % NN
    protocolList{10} = 221; maxGamma_SFIndex{10} = 2; maxGamma_OriIndex{10} = 4; % AD
    protocolList{11} = 235; maxGamma_SFIndex{11} = 1; maxGamma_OriIndex{11} = 2; % AB
end

numSubjects = length(protocolList);
subjectNames = cell(numSubjects,length(protocolList{1}));
expDates = cell(numSubjects,length(protocolList{1}));
protocolNames = cell(numSubjects,length(protocolList{1}));

for i=1:numSubjects
    subjectNames{i} = allSubjectNames{protocolList{i}};
    expDates{i} = allExpDates{protocolList{i}};
    protocolNames{i} = allProtocolNames{protocolList{i}};
end


