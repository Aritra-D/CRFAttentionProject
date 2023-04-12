function [badTrialPercentage,badElecs,UnipolarbadElecPercentage,BipolarbadElecPercentage] = displayBadTrialsPercentage(protocolType,gridType,BadEyeTrialsFlag,badTrialStr)
if strcmp(protocolType,'SRC-Long')
    [subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationSRCProtocols_HumanEEG(gridType,protocolType);
elseif strcmp(protocolType,'Mapping-Diagonal')|| strcmp(protocolType,'Mapping-Horizntal')
    [subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationMappingProtocols_HumanEEG(gridType,protocolType);
elseif strcmp(protocolType,'SFOri-allGroups')
        [subjectNames,expDates,protocolNames,~,~,dataFolderSourceString] = dataInformationSFORIProtocols_HumanEEG(gridType,protocolType);
end

deviceName = 'BP'; %#ok<*NASGU>
capType = 'actiCap64';



for iSub = 1:size(subjectNames,1)
    for iRef = 1:2
        folderName = fullfile(dataFolderSourceString,'data',subjectNames{iSub},gridType,expDates{iSub},protocolNames{iSub});
        folderExtract= fullfile(folderName,'extractedData');
        folderSegment= fullfile(folderName,'segmentedData');
        folderLFP = fullfile(folderSegment,'LFP');
        
        % load GoodStimNums 
        load(fullfile(folderExtract,'goodStimNums.mat'));
        
        if strcmp(protocolType,'SRC-Long')
            goodStimNumbers = length(goodStimNums.targetOnset);
        else
            goodStimNumbers = length(goodStimNums);
        end
        
        % load LFP Info
        [analogChannelsStored,~,~,~] = loadlfpInfo(folderLFP);
        
        % Electrode and trial related Information
        photoDiodeChannels = [65 66];
        
        switch iRef
            case 1; refType = 'unipolar';
            case 2; refType = 'bipolar';
        end
        
        electrodeList = getElectrodeList(capType,refType,1);
        
        badTrialFile = fullfile(folderSegment,['badTrials_' badTrialStr '.mat']);
        if ~exist(badTrialFile,'file')
            disp('Bad trial file does not exist...');
            badElecs = []; badTrials=[];
        else
            [badTrials,badElectrodes,badEyeTrials] = loadBadTrials(badTrialFile);
            badElecsAll = unique([badElectrodes.badImpedanceElecs; badElectrodes.noisyElecs; badElectrodes.flatPSDElecs; badElectrodes.flatPSDElecs]);
            if BadEyeTrialsFlag
                badTrials = union(badTrials,badEyeTrials);
            end
            if iRef==1
                badTrialPercentage(iSub) = 100*(length(badTrials)/goodStimNumbers);
            disp(['Sub ' num2str(iSub) ':' num2str(length(badTrials)) '/ ' num2str(goodStimNumbers) ' = ' num2str(100*(length(badTrials))/goodStimNumbers) ' % bad trials']);
            end
        end
        
        highPriorityElectrodeNums = getHighPriorityElectrodes(capType);
        
        if strcmp(refType,'unipolar')
            badHighPriorityElecs{iSub}{iRef} = intersect(highPriorityElectrodeNums,badElecsAll); %#ok<*AGROW>
            badElecs{iSub}{iRef} = intersect(setdiff(analogChannelsStored,photoDiodeChannels),badElecsAll);
            disp(['Unipolar Ref. ' 'Sub ' num2str(iSub) '- all bad elecs: ' num2str(length(badElecsAll)) '; all high-priority bad elecs: ' num2str(length(intersect(highPriorityElectrodeNums,badElecsAll))) ]);
            UnipolarbadElecPercentage(iSub) = 100*(length(intersect(setdiff(analogChannelsStored,photoDiodeChannels),badElecsAll))/length(setdiff(analogChannelsStored,photoDiodeChannels)));
            
        elseif strcmp(refType,'bipolar')
            count =1; badBipolarElecs = [];
            for iBipolarElec = 1:length(electrodeList)
                if any(electrodeList{iBipolarElec}{1}(1) == badElecsAll) || any(electrodeList{iBipolarElec}{1}(2) == badElecsAll)
                    badBipolarElecs(count) = iBipolarElec;
                    count = count+1;
                end
            end
            
            if ~exist('badBipolarElecs','var')
                badBipolarElecs = [];
            end
            
            badElecs{iSub}{iRef} = badBipolarElecs;
            highPriorityBipolarElectrodeNums = [93 94 101 102 96 97 111 107 112];
            badHighPriorityElecs{iSub}{iRef} = intersect(highPriorityBipolarElectrodeNums,badBipolarElecs);
            disp(['Bipolar Ref. ' 'Sub ' num2str(iSub) '- all bad elecs: ' num2str(length(badBipolarElecs)) '; all high-priority bad elecs: ' num2str(length(intersect(highPriorityBipolarElectrodeNums,badBipolarElecs))) ]);
            BipolarbadElecPercentage(iSub) = 100*(length(badBipolarElecs)/112);

        end
        
    end
end
end

% Accessory Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%  Accessory Functions  %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Load LFP Info
function [analogChannelsStored,timeVals,goodStimPos,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
load(fullfile(folderLFP,'lfpInfo.mat')); %#ok<*LOAD>
analogChannelsStored=sort(analogChannelsStored); %#ok<NODEF>
if ~exist('analogInputNums','var')
    analogInputNums=[];
end
end
% Get Bad Trials
function [badTrials,badElecs,badEyeTrials] = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
badEyeTrials = badTrialsUnique.badEyeTrials;
end
