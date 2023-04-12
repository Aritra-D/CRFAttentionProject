function allTargetOnsetTimes = getAllTargetOnsetTimes(gridType,protocolType,badTrialStr)

[subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationSRCProtocols_HumanEEG(gridType,protocolType);
allTargetOnsetTimes = cell(1,length(subjectNames));

for iSub=1:length(subjectNames)
    % Load Target Onset Distribution of a single subject
    folderName = fullfile(dataFolderSourceString,'data',subjectNames{iSub},gridType,expDates{iSub},protocolNames{iSub});
    folderExtract= fullfile(folderName,'extractedData');
    folderSegment= fullfile(folderName,'segmentedData');
    
    % load GoodStimTimes from goodStimNums.mat to compute target Onset time
    % with respect to the first stiulus onset for all good SRC-Long trials
    load(fullfile(folderExtract,'goodStimNums.mat')); %#ok<*LOAD>
    allTargetOnsetTimesTMP = 1000*(round(goodStimTimes.targetOnset-goodStimTimes.stimOnset,2));
    
    % Load Parameter Combinations to get GoodStimNums
    [parameterCombinations,parameters] = loadParameterCombinations(folderExtract); %#ok<*ASGLU>
    
    % Get bad trials
    badTrialFile = fullfile(folderSegment,['badTrials_' badTrialStr '.mat']);
    if ~exist(badTrialFile,'file')
        disp('Bad trial file does not exist...');
        badTrials=[];
    else
        [badTrials,~,badEyeTrials] = loadBadTrials(badTrialFile);
        disp([num2str(length(union(badTrials,badEyeTrials))) ' bad trials']);
    end
    
    for iCondition = 1:12
        switch iCondition
            case 1;  c = 1; tf = 1; eotCode = 1; attLoc = 2;  s=1;
            case 2;  c = 1; tf = 1; eotCode = 1; attLoc = 1;  s=1;
            case 3;  c = 1; tf = 2; eotCode = 1; attLoc = 2;  s=1;
            case 4;  c = 1; tf = 2; eotCode = 1; attLoc = 1;  s=1;
            case 5;  c = 1; tf = 3; eotCode = 1; attLoc = 2;  s=1;
            case 6;  c = 1; tf = 3; eotCode = 1; attLoc = 1;  s=1;
            case 7;  c = 1; tf = 1; eotCode = 2; attLoc = 2;  s=1;
            case 8;  c = 1; tf = 1; eotCode = 2; attLoc = 1;  s=1;
            case 9;  c = 1; tf = 2; eotCode = 2; attLoc = 2;  s=1;
            case 10; c = 1; tf = 2; eotCode = 2; attLoc = 1;  s=1;
            case 11; c = 1; tf = 3; eotCode = 2; attLoc = 2;  s=1;
            case 12; c = 1; tf = 3; eotCode = 2; attLoc = 1;  s=1;
        end
        goodPos_targetOnsetTMP = setdiff(parameterCombinations.targetOnset{c,tf,eotCode,attLoc,s},union(badTrials,badEyeTrials));
        allTargetOnsetTimes{iSub}{iCondition} = allTargetOnsetTimesTMP(goodPos_targetOnsetTMP);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%  Accessory Functions  %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get parameter combinations
function [parameterCombinations,parameters] = loadParameterCombinations(folderExtract)

load(fullfile(folderExtract,'parameterCombinations.mat')); %#ok<*LOAD>
end

% Get Bad Trials
function [badTrials,badElecs,badEyeTrials] = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
badEyeTrials = badTrialsUnique.badEyeTrials;
end
