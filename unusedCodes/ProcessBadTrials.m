clear; close all;
projectName = 'CRFAttention'; gridType = 'EEG'; protocolType = 'Mapping'; folderSourceString = fullfile('E:\data\human',protocolType);
% subjectName = 'test'; gridType = 'EEG'; folderSourceString = 'E:';

[subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts] = eval(['allProtocols' upper(projectName(1)) projectName(2:end) gridType 'v1']);
% [subjectNames,expDates,protocolNames,stimTypes,deviceNames,capLayouts,protocolTypes] = eval(['allProtocols' upper(projectName(1)) projectName(2:end) gridType]);
% [expDates,protocolNames,stimTypes] = eval(['allProtocols' upper(subjectName(1)) subjectName(2:end) gridType]);% getAllProtocols(subjectName,gridType);

% stimType is a number that describes the duration of the signal around
% each stimulus onset that needs to be extracted (given by
% timeStartFromBaseLineList and deltaTList). For details, see stimTypeList
[timeStartFromBaseLineList,deltaTList] = stimTypeList;

% [sfList,oriList] = eval(['allProtocolDetails' upper(projectName(1)) projectName(2:end) gridType]);
% extractTheseIndices = unique([sfList(:);oriList(:)]);

extractTheseIndices =[101:104 113:116 127:130 141:144 153:156 167:170 181:184 195:198 209:212 223:226 237:240];
%Mapping:[101:104 113:116 127:130 141:144 153:156 167:170 181:184 195:198 209:212 223:226 237:240]
%SF-ORI: [139 151 221 207  99 165 179 235 125 193 284 291 297 303 310 321 328 338 345 353 359 380 111 406 412 420 442 457];
%SRCLong:[248 250 252 263 265 270 273 277 288 294 300 306 317 325 334 342 350 356 362 383 403 409 417 425 446 460];
if strcmp(protocolType,'SRCLong')
    SRCType = 2;
else
    SRCType = 0;
end

for i=1:length(extractTheseIndices)
    
    subjectName = subjectNames{extractTheseIndices(i)};
    expDate = expDates{extractTheseIndices(i)};
    protocolName = protocolNames{extractTheseIndices(i)};
    deviceName = deviceNames{extractTheseIndices(i)};
    capLayout = capLayouts{extractTheseIndices(i)};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Find Bad Trials %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% [badTrials,allBadTrials,badTrialsUnique,badElecs,totalTrials,slopeValsVsFreq] =...
% findBadTrialsWithEEG(subjectName,expDate,protocolName,folderSourceString,gridType,...
% badEEGElectrodes,nonEEGElectrodes,impedanceTag,capType,saveDataFlag,badTrialNameStr,...
% displayResultsFlag)
nonEEGElectrodes =  [65 66];
if SRCType == 0 || SRCType == 1 % GRF Protocols and SRC-Short Protocols (SRCType = 1)
    findBadTrialsWithEEG_v10(subjectName,expDate,protocolName,folderSourceString,gridType,[],...
        nonEEGElectrodes,'ImpedanceStart','actiCap64',1,'_v10_Check',0);
elseif SRCType == 2 % SRC-Long Protocols (SRCType = 2)
    findBadTrialsWithEEG_SRCLong_v10(subjectName,expDate,protocolName,folderSourceString,gridType,[],...
        nonEEGElectrodes,'ImpedanceStart','actiCap64',1,'_v10_Check',0);
end

end