function [psdData,freqRanges_SubjectWise,badHighPriorityElecs,badElecs] = getData_HitsVsMisses_SRCLong(protocolType,gridType,badTrialStr,bootstrapTimes)

[subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationSRCProtocols_HumanEEG(gridType,protocolType);
capType = 'actiCap64';

tapers = [1 1];

timingParameters.blRange = [-1.000 0];
timingParameters.tgRange = [-1.000 0];


fileName = ['E:\allGoodStimNums_bootStrap_' num2str(bootstrapTimes) '.mat'];
if exist(fileName,'file')
    load(fileName)
else
    targetOnsetMatchingChoice = 1;
    targetTimeBinWidthMS = 250;
    allTargetOnsetTimes = getAllTargetOnsetTimes(gridType,protocolType,badTrialStr);
    allGoodStimNums = cell(1,bootstrapTimes);
    for i= 1: bootstrapTimes
        allGoodStimNums{i} = getGoodStimNums_SRCLong(allTargetOnsetTimes,targetOnsetMatchingChoice,targetTimeBinWidthMS);
    end
    save(fileName,'allGoodStimNums')
end

for iRef = 1:2
    switch iRef
        case 1; refType = 'unipolar';
        case 2; refType = 'bipolar';
    end
    disp(['Processing data RefScheme: ' refType])

    for iBootStrap =1:bootstrapTimes
        tic
        for iSub = 1:size(subjectNames,1)
            disp(['Processing data for Subject: ' num2str(iSub) ', Bootstrap: ' num2str(iBootStrap)])
            folderName = fullfile(dataFolderSourceString,'data',subjectNames{iSub},gridType,expDates{iSub},protocolNames{iSub});
            folderExtract= fullfile(folderName,'extractedData');
            folderSegment= fullfile(folderName,'segmentedData');
            folderLFP = fullfile(folderSegment,'LFP');
            
            if iSub<8 % First Set of Recording- Nov-Dec 2021
                freqRanges{1} = [8 12];    % alpha
                freqRanges{2} = [25 70];   % gamma
                freqRanges{3} = [23 23];   % SSVEP Left Stim; Flicker Freq moved by 0.5 Hz due one extra blank Frame
                freqRanges{4} = [31 31];   % SSVEP Right Stim; Flicker Freq moved by 0.5 Hz due one extra blank Frame
                freqRanges{5} = [26 34];   % Slow Gamma
                freqRanges{6} = [44 56];   % Fast Gamma
                freqRanges{7} = [102 250]; % High Gamma
            else % Second Set of Recording- Jan-Mar 2022
                freqRanges{1} = [8 12];    % alpha
                freqRanges{2} = [25 70];   % gamma
                freqRanges{3} = [24 24];   % SSVEP Left Stim; Flicker Freq bug Fixed
                freqRanges{4} = [32 32];   % SSVEP Right Stim; Flicker Freq bug Fixed
                freqRanges{5} = [26 34];   % Slow Gamma
                freqRanges{6} = [44 56];   % Fast Gamma
                freqRanges{7} = [102 250]; % High Gamma
            end
            freqRanges_SubjectWise{iSub} = freqRanges;
            
            % load LFP Info
            [analogChannelsStored,timeVals,~,~] = loadlfpInfo(folderLFP);
            
            % Get Parameter Combinations for SRC-Long Protocols
            [parameterCombinations,parameters]= ...
                loadParameterCombinations(folderExtract); %#ok<ASGLU>
            
            % timing related Information
            Fs = round(1/(timeVals(2)-timeVals(1)));
            if round(diff(timingParameters.blRange)*Fs) ~= round(diff(timingParameters.tgRange)*Fs)
                disp('baseline and stimulus ranges are not the same');
            else
                range = timingParameters.blRange;
                rangePos = round(diff(range)*Fs);
                blPos = find(timeVals>=timingParameters.blRange(1),1)+ (1:rangePos);
                tgPos = find(timeVals>=timingParameters.tgRange(1),1)+ (1:rangePos);
            end
            
            % Set up params for MT
            params.tapers   = tapers;
            params.pad      = -1;
            params.Fs       = Fs;
            params.fpass    = [0 250];
            params.trialave = 1;
            
            % Electrode and trial related Information
            photoDiodeChannels = [65 66];
            
            electrodeList = getElectrodeList(capType,refType,1);
            
            % Get bad trials
            badTrialFile = fullfile(folderSegment,['badTrials_' badTrialStr '.mat']);
            if ~exist(badTrialFile,'file')
                disp('Bad trial file does not exist...');
                badElecs = [];
            else
                [badTrials,badElectrodes] = loadBadTrials(badTrialFile);
                badElecsAll = unique([badElectrodes.badImpedanceElecs; badElectrodes.noisyElecs; badElectrodes.flatPSDElecs; badElectrodes.flatPSDElecs]);
            end
            
            highPriorityElectrodeNums = getHighPriorityElectrodes(capType);
            
            if strcmp(refType,'unipolar')
                badHighPriorityElecs{iRef}{iSub} = intersect(highPriorityElectrodeNums,badElecsAll);
                badElecs{iRef}{iSub} = intersect(setdiff(analogChannelsStored,photoDiodeChannels),badElecsAll);
                disp(['Unipolar, all bad elecs: ' num2str(length(badElecsAll)) '; all high-priority bad elecs: ' num2str(length(intersect(highPriorityElectrodeNums,badElecsAll))) ]);
                
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
                
                badElecs{iRef}{iSub} = badBipolarElecs; %#ok<*AGROW>
                highPriorityBipolarElectrodeNums = [93 94 101 102 96 97 111 107 112];
                badHighPriorityElecs{iRef}{iSub} = intersect(highPriorityBipolarElectrodeNums,badBipolarElecs);
                disp(['Bipolar, all bad elecs: ' num2str(length(badBipolarElecs)) '; all high-priority bad elecs: ' num2str(length(intersect(highPriorityBipolarElectrodeNums,badBipolarElecs))) ]);
            end
            
            for iCondition = 1:12
                for iElec = 1:length(electrodeList)
                    clear x
                    if iRef == 1
                        clear x
                        if iElec == length(electrodeList)
%                             disp('Processed unipolar electrodes')
                        end
                        x = load(fullfile(folderLFP,['elec' num2str(electrodeList{iElec}{1}) '.mat']));
                    elseif iRef == 2
                        clear x1 x2 x
                        if iElec == length(electrodeList)
%                             disp('Processed bipolar electrodes')
                        end
                        x1 = load(fullfile(folderLFP,['elec' num2str(electrodeList{iElec}{1}(1)) '.mat']));
                        x2 = load(fullfile(folderLFP,['elec' num2str(electrodeList{iElec}{1}(2)) '.mat']));
                        x.analogData.stimOnset = x1.analogData.stimOnset-x2.analogData.stimOnset;
                        x.analogData.targetOnset = x1.analogData.targetOnset-x2.analogData.targetOnset;
                    end
                    
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
                    
                    goodPos_TMP = setdiff(parameterCombinations.targetOnset{c,tf,eotCode,attLoc,s},badTrials);
                    goodPosTMP = goodPos_TMP(allGoodStimNums{1,iBootStrap}{1,iSub}{1,iCondition});
                    goodPos_all(iBootStrap,iSub,iElec,iCondition,:) = goodPosTMP;
                    goodStimNums(iBootStrap,iSub,iElec,iCondition,:) = length(goodPosTMP); 
                    
                    % Segmenting data according to timePos
                    dataBL = x.analogData.stimOnset(goodPosTMP,blPos)';
                    dataTG = x.analogData.targetOnset(goodPosTMP,tgPos)';
                    
                    % power spectral density estimation
                    [tmpEBL,freqValsBL] = mtspectrumc(dataBL,params);
                    [tmpETG,freqValsTG] = mtspectrumc(dataTG,params);
                    
                    if isequal(freqValsBL,freqValsBL) && isequal(freqValsBL,freqValsTG)
                        freqVals = freqValsTG;
                    end
                   
                    if iCondition == 1 || iCondition == 2 || iCondition == 7 || iCondition == 8
                        tf1 = 0; tf2 = 0;
                    elseif  iCondition == 3 || iCondition == 4 || iCondition == 9 || iCondition == 10
                        tf1 = 12; tf2= 16;                        
                    elseif  iCondition == 5 || iCondition == 6 || iCondition == 11 || iCondition == 12
                        tf1 = 12; tf2 = 16;                        
                    end
                    
                    psdBL(iBootStrap,iSub,iElec,iCondition,:) = tmpEBL;
                    psdTG(iBootStrap,iSub,iElec,iCondition,:) = tmpETG;
                    
                    for iFreqRange=1:length(freqRanges)
                        if iFreqRange == 3||iFreqRange == 4
                            remove_NthHarmonicOnwards = 3;
                        else
                            remove_NthHarmonicOnwards = 2;
                        end
                        deltaF_LineNoise = 2; deltaF_tfHarmonics = 0;
                        badFreqPos = getBadFreqPos(freqVals,deltaF_LineNoise,deltaF_tfHarmonics,remove_NthHarmonicOnwards,tf1,tf2);
                        powerValsBL{iFreqRange}(iBootStrap,iSub,iElec,iCondition) = getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{iFreqRange},badFreqPos);
                        powerValsTG{iFreqRange}(iBootStrap,iSub,iElec,iCondition) = getMeanEnergyForAnalysis(tmpETG,freqVals,freqRanges{iFreqRange},badFreqPos);
                    end
                    
                    % Segmenting data according to timePos
                    dataBL_avg = mean(x.analogData.stimOnset(goodPosTMP,blPos),1)';
                    dataTargetOnset_avg = mean(x.analogData.targetOnset(goodPosTMP,tgPos),1)';
                    
                    % power spectral density estimation
                    [tmpEBL_avg,~] = mtspectrumc(dataBL_avg,params);
                    [tmpETG_avg,~] = mtspectrumc(dataTargetOnset_avg,params);
                    
                    psdBL_trialAvg(iBootStrap,iSub,iElec,iCondition,:) = tmpEBL_avg;
                    psdTG_trialAvg(iBootStrap,iSub,iElec,iCondition,:) = tmpETG_avg;
                    
                    
                    for iFreqRange=1:length(freqRanges)
                        if iFreqRange == 3||iFreqRange == 4
                            remove_NthHarmonicOnwards = 3;
                        else
                            remove_NthHarmonicOnwards = 2;
                        end
                        deltaF_LineNoise = 2; deltaF_tfHarmonics = 0;
                        badFreqPos = getBadFreqPos(freqVals,deltaF_LineNoise,deltaF_tfHarmonics,remove_NthHarmonicOnwards,tf1,tf2);
                        
                        powerValsBL_trialAvg{iFreqRange}(iBootStrap,iSub,iElec,iCondition) = getMeanEnergyForAnalysis(tmpEBL_avg,freqVals,freqRanges{iFreqRange},badFreqPos);
                        powerValsTG_trialAvg{iFreqRange}(iBootStrap,iSub,iElec,iCondition) = getMeanEnergyForAnalysis(tmpETG_avg,freqVals,freqRanges{iFreqRange},badFreqPos);
                    end
                end
            end
        end
    end
    psdBL_all{iRef} = psdBL; psdBL_trialAvg_all{iRef} = psdBL_trialAvg;
    psdTG_all{iRef} = psdTG; psdTG_trialAvg_all{iRef} = psdTG_trialAvg;
    powerValsBL_all{iRef} = powerValsBL; powerValsBL_trialAvg_all{iRef} = powerValsBL_trialAvg;
    powerValsTG_all{iRef} = powerValsTG; powerValsTG_trialAvg_all{iRef} = powerValsTG_trialAvg;
    goodPos_allRef{iRef} = goodPos_all;
    goodStimNums_allRef{iRef} = goodStimNums;
    toc
end

psdData.dataBL = psdBL_all;
psdData.dataTG = psdTG_all;
psdData.dataBL_trialAvg = psdBL_trialAvg_all;
psdData.dataTG_trialAvg = psdTG_trialAvg_all;
psdData.analysisDataBL = powerValsBL_all;
psdData.analysisDataTG = powerValsTG_all;
psdData.analysisDataBL_trialAvg = powerValsBL_trialAvg_all;
psdData.analysisDataTG_trialAvg = powerValsTG_trialAvg_all;
psdData.freqVals = freqVals;
psdData.goodPos = goodPos_allRef;
psdData.goodStimNums = goodStimNums_allRef;

fileSave = ['E:\HitsVsMissesData_bootstrap_' num2str(bootstrapTimes) '.mat']; 
save(fileSave,'psdData','freqRanges_SubjectWise','badHighPriorityElecs','badElecs')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%  Accessory Functions  %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get parameter combinations
function [parameterCombinations,parameters] = loadParameterCombinations(folderExtract)
load(fullfile(folderExtract,'parameterCombinations.mat')); %#ok<*LOAD>
end

% Get Bad Trials
function [badTrials,badElecs] = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
% badEyeTrials = badTrialsUnique.badEyeTrials;
end

% Load LFP Info
function [analogChannelsStored,timeVals,goodStimPos,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
load(fullfile(folderLFP,'lfpInfo.mat'));
analogChannelsStored=sort(analogChannelsStored); %#ok<NODEF>
if ~exist('analogInputNums','var')
    analogInputNums=[];
end
end

% Get MeanEnergy for different frequency bands
function eValue = getMeanEnergyForAnalysis(mEnergy,freq,freqRange,badFreqPos)
posToAverage = setdiff(intersect(find(freq>=freqRange(1)),find(freq<=freqRange(2))),badFreqPos);
eValue   = sum(mEnergy(posToAverage));
end

function badFreqPos = getBadFreqPos(freqVals,deltaF_LineNoise,deltaF_TFHarmonics,remove_NthHarmonicOnwards,tfLeft,tfRight)
% During this Project, line Noise was at
% 51 Hz for 1 Hz Freq Resolution and
% 52 Hz for 2 Hz Freq Resolution

if nargin<2
    deltaF_LineNoise = 1; deltaF_TFHarmonics = 0; tfLeft = 0; tfRight = 0;
end

if tfLeft>0 && tfRight>0 % Flickering Stimuli
    badFreqs = 51:51:max(freqVals);
    tfHarmonics1 = remove_NthHarmonicOnwards*tfLeft:tfLeft:max(freqVals); % remove nth SSVEP harmonic and beyond
    tfHarmonics2 = remove_NthHarmonicOnwards*tfRight:tfRight:max(freqVals); % remove nth SSVEP harmonic and beyond
    tfHarmonics = unique([tfHarmonics1 tfHarmonics2]);
elseif tfLeft==0 && tfRight==0 % Static Stimuli
    badFreqs = 51:51:max(freqVals);
end

badFreqPos = [];  
for i=1:length(badFreqs)
    badFreqPos = cat(2,badFreqPos,intersect(find(freqVals>=badFreqs(i)-deltaF_LineNoise),find(freqVals<=badFreqs(i)+deltaF_LineNoise)));
end

if exist('tfHarmonics','var')
    freqPosToRemove =  [];
    for i=1:length(badFreqs)
        freqPosToRemove = cat(2,freqPosToRemove,intersect(find(freqVals>=tfHarmonics(i)-deltaF_TFHarmonics),find(freqVals<=tfHarmonics(i)+deltaF_TFHarmonics)));
    end
    badFreqPos = unique([badFreqPos freqPosToRemove]);
end
end

