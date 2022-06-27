function [subjectNames,expDates,protocolNames,maxGamma_SFIndex,...
            maxGamma_OriIndex,dataFolderSourceString]...
    = dataInformationSFORIProtocols_HumanEEG(gridType,protocolType)

if ~exist('gridType','var');                            gridType = 'EEG'; end

% FolderSourceString for extracted dataset
if strcmp(getenv('computername'),'RAYLABPC-ARITRA') || strcmp(getenv('username'),'RayLabPC-Aritra')
    dataFolderSourceString = 'E:\data\human\SFOri';
else
    dataFolderSourceString = 'M:\';
end

[allSubjectNames,allExpDates,allProtocolNames,~,~,~] = eval(['allProtocolsCRFAttention' gridType 'v1']);

% stimList = cell(1,4);

if strcmp(protocolType, 'SFOri-MappingGroup')
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
    
elseif strcmp(protocolType, 'SFOri-AttentionGroup')
    protocolList{1}  = 221; maxGamma_SFIndex{1} = 2;  maxGamma_OriIndex{1} = 4;  % AD
    protocolList{2}  = 207; maxGamma_SFIndex{2} = 2;  maxGamma_OriIndex{2} = 3;  % NN
    protocolList{3}  = 99;  maxGamma_SFIndex{3} = 2;  maxGamma_OriIndex{3} = 4;  % NM
    protocolList{4}  = 165; maxGamma_SFIndex{4} = 1;  maxGamma_OriIndex{4} = 2;  % SSP
    protocolList{5}  = 179; maxGamma_SFIndex{5} = 1;  maxGamma_OriIndex{5} = 2;  % SK
    protocolList{6}  = 235; maxGamma_SFIndex{6} = 1;  maxGamma_OriIndex{6} = 2;  % AB
    protocolList{7}  = 125; maxGamma_SFIndex{7} = 1;  maxGamma_OriIndex{7} = 4;  % LK
    protocolList{8}  = 193; maxGamma_SFIndex{8} = 1;  maxGamma_OriIndex{8} = 4;  % DG
    protocolList{9}  = 284; maxGamma_SFIndex{9} = 2;  maxGamma_OriIndex{9} = 4;  % SW
    protocolList{10} = 291; maxGamma_SFIndex{10} = 1; maxGamma_OriIndex{10} = 2; % AR
    protocolList{11} = 297; maxGamma_SFIndex{11} = 2; maxGamma_OriIndex{11} = 2; % SN
    protocolList{12} = 303; maxGamma_SFIndex{12} = 1; maxGamma_OriIndex{12} = 2; % AM
    protocolList{13} = 310; maxGamma_SFIndex{13} = 2; maxGamma_OriIndex{13} = 1; % SU
    protocolList{14} = 321; maxGamma_SFIndex{14} = 2; maxGamma_OriIndex{14} = 1; % ArD
    protocolList{15} = 328; maxGamma_SFIndex{15} = 2; maxGamma_OriIndex{15} = 2; % UG
    protocolList{16} = 338; maxGamma_SFIndex{16} = 2; maxGamma_OriIndex{16} = 4; % SS
    protocolList{17} = 345; maxGamma_SFIndex{17} = 1; maxGamma_OriIndex{17} = 4; % SNS
    protocolList{18} = 353; maxGamma_SFIndex{18} = 1; maxGamma_OriIndex{18} = 4; % SG
    protocolList{19} = 359; maxGamma_SFIndex{19} = 2; maxGamma_OriIndex{19} = 2; % MK
    protocolList{20} = 380; maxGamma_SFIndex{20} = 2; maxGamma_OriIndex{20} = 1; % SR
    protocolList{21} = 111; maxGamma_SFIndex{21} = 2; maxGamma_OriIndex{21} = 2; % SP
    protocolList{22} = 406; maxGamma_SFIndex{22} = 1; maxGamma_OriIndex{22} = 2; % RG
    protocolList{23} = 412; maxGamma_SFIndex{23} = 1; maxGamma_OriIndex{23} = 3; % IJ
    protocolList{24} = 420; maxGamma_SFIndex{24} = 2; maxGamma_OriIndex{24} = 4; % SM
    protocolList{25} = 442; maxGamma_SFIndex{25} = 2; maxGamma_OriIndex{25} = 4; % SJP
    protocolList{26} = 457; maxGamma_SFIndex{26} = 2; maxGamma_OriIndex{26} = 4; % SC
    
elseif strcmp(protocolType, 'SFOri-allGroups')
    
    protocolList{1}  = 99;  maxGamma_SFIndex{1}  = 2; maxGamma_OriIndex{1} = 4;  % NM
    protocolList{2}  = 111; maxGamma_SFIndex{2}  = 2; maxGamma_OriIndex{2} = 2;  % SP
    protocolList{3}  = 125; maxGamma_SFIndex{3}  = 1; maxGamma_OriIndex{3} = 4;  % LK
    protocolList{4}  = 139; maxGamma_SFIndex{4}  = 1; maxGamma_OriIndex{4} = 4;  % SA
    protocolList{5}  = 151; maxGamma_SFIndex{5}  = 2; maxGamma_OriIndex{5} = 3;  % SB
    protocolList{6}  = 165; maxGamma_SFIndex{6}  = 1; maxGamma_OriIndex{6} = 2;  % SSP
    protocolList{7}  = 179; maxGamma_SFIndex{7}  = 1; maxGamma_OriIndex{7} = 2;  % SK
    protocolList{8}  = 193; maxGamma_SFIndex{8}  = 1; maxGamma_OriIndex{8} = 4;  % DG
    protocolList{9}  = 207; maxGamma_SFIndex{9}  = 2; maxGamma_OriIndex{9} = 3;  % NN
    protocolList{10} = 221; maxGamma_SFIndex{10} = 2; maxGamma_OriIndex{10} = 4; % AD
    protocolList{11} = 235; maxGamma_SFIndex{11} = 1; maxGamma_OriIndex{11} = 2; % AB
    protocolList{12} = 284; maxGamma_SFIndex{12} = 2; maxGamma_OriIndex{12} = 4; % SW
    protocolList{13} = 291; maxGamma_SFIndex{13} = 1; maxGamma_OriIndex{13} = 2; % AR
    protocolList{14} = 297; maxGamma_SFIndex{14} = 2; maxGamma_OriIndex{14} = 2; % SN
    protocolList{15} = 303; maxGamma_SFIndex{15} = 1; maxGamma_OriIndex{15} = 2; % AM
    protocolList{16} = 310; maxGamma_SFIndex{16} = 2; maxGamma_OriIndex{16} = 1; % SU
    protocolList{17} = 321; maxGamma_SFIndex{17} = 2; maxGamma_OriIndex{17} = 1; % ArD
    protocolList{18} = 328; maxGamma_SFIndex{18} = 2; maxGamma_OriIndex{18} = 2; % UG
    protocolList{19} = 338; maxGamma_SFIndex{19} = 2; maxGamma_OriIndex{19} = 4; % SS
    protocolList{20} = 345; maxGamma_SFIndex{20} = 1; maxGamma_OriIndex{20} = 4; % SNS
    protocolList{21} = 353; maxGamma_SFIndex{21} = 1; maxGamma_OriIndex{21} = 4; % SG
    protocolList{22} = 359; maxGamma_SFIndex{22} = 2; maxGamma_OriIndex{22} = 2; % MK
    protocolList{23} = 380; maxGamma_SFIndex{23} = 2; maxGamma_OriIndex{23} = 1; % SR
    protocolList{24} = 406; maxGamma_SFIndex{24} = 1; maxGamma_OriIndex{24} = 2; % RG
    protocolList{25} = 412; maxGamma_SFIndex{25} = 1; maxGamma_OriIndex{25} = 3; % IJ
    protocolList{26} = 420; maxGamma_SFIndex{26} = 2; maxGamma_OriIndex{26} = 4; % SM
    protocolList{27} = 442; maxGamma_SFIndex{27} = 2; maxGamma_OriIndex{27} = 4; % SJP
    protocolList{28} = 457; maxGamma_SFIndex{28} = 2; maxGamma_OriIndex{28} = 4; % SC


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


