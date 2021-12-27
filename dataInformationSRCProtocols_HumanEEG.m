function [subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationSRCProtocols_HumanEEG(gridType,protocolType)

if ~exist('gridType','var');                            gridType = 'EEG'; end

% FolderSourceString for extracted dataset
if strcmp(getenv('computername'),'RAYLABPC-ARITRA') || strcmp(getenv('username'),'RayLabPC-Aritra')
    dataFolderSourceString = 'E:\';
else
    dataFolderSourceString = 'M:\';
end

[allSubjectNames,allExpDates,allProtocolNames,~,~,~] = eval(['allProtocolsCRFAttention' gridType]);

% stimList = cell(1,4);

if strcmp(protocolType, 'SRC-Long')
    protocolList{1} = 248;  % Aritra AD
    protocolList{2} = 250;  % Nilanjana NN
    protocolList{3} = 252;  % Niloy NM
    protocolList{4} = 263;  % Surya SP
    protocolList{5} = 265;  % Saurabh SK
    protocolList{6} = 270;  % Ankan  AB
    protocolList{7} = 273;  % Liza  LK

 
elseif strcmp(protocolType, 'SRC-Short')
    protocolList{1} = [];
    protocolList{2} = [];
    protocolList{3} = [];
    protocolList{4} = [];
    protocolList{5} = [];
    protocolList{6} = [];
    protocolList{7} = [];

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


