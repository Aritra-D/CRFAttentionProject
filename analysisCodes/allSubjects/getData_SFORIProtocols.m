function [fftData,energyData,energyDataTF,badHighPriorityElecs,badElecs] = getData_SFORIProtocols(protocolType,gridType,timingParameters,tapers,freqRanges,badTrialStr,removeBadEyeTrialsFlag)

[subjectNames,expDates,protocolNames,maxGamma_SFIndex,...
    maxGamma_OriIndex,dataFolderSourceString]...
    = dataInformationSFORIProtocols_HumanEEG(gridType,protocolType);

deviceName = 'BP'; %#ok<*NASGU>
capType = 'actiCap64';
numFreqs = length(freqRanges);

for iRef = 1:2
    clear powerValsBL powerValsST electrodeList
    for iSub = 1:size(subjectNames,1)
        disp(['SUBJECT: ' num2str(iSub)])
        clear badTrials badElectrodes
        folderName = fullfile(dataFolderSourceString,'data',...
            subjectNames{iSub},gridType,expDates{iSub},protocolNames{iSub});
        folderExtract= fullfile(folderName,'extractedData');
        folderSegment= fullfile(folderName,'segmentedData');
        folderLFP = fullfile(folderSegment,'LFP');
        
        % load LFP Info
        [analogChannelsStored,timeVals,~,~] = loadlfpInfo(folderLFP);
        
        % load Parameter Combinations for SF-Ori Protocols
        [parameterCombinations,~,~,~,fValsUnique,oValsUnique,~,tValsUnique] = loadParameterCombinations(folderExtract,[]);
        
        Fs = round(1/(timeVals(2)-timeVals(1)));
        if round(diff(timingParameters.blRange)*Fs) ~= round(diff(timingParameters.stRange)*Fs)
            disp('baseline and stimulus ranges are not the same');
        else
            range = timingParameters.blRange;
            rangePos = round(diff(range)*Fs);
            blPos = find(timeVals>=timingParameters.blRange(1),1)+ (1:rangePos);
            stPos = find(timeVals>=timingParameters.stRange(1),1)+ (1:rangePos);
            freqVals_fft = 0:1/diff(range):Fs-1/diff(range);
        end
        
        photoDiodeChannels = [65 66];
        
        switch iRef
            case 1; refType = 'unipolar';
            case 2; refType = 'bipolar';
        end
        
        electrodeList = getElectrodeList(capType,refType,1);
        
        % Get bad trials
        badTrialFile = fullfile(folderSegment,['badTrials_' badTrialStr '.mat']);
        if ~exist(badTrialFile,'file')
            disp('Bad trial file does not exist...');
            badElecs = []; badTrials=[];
        else
            [badTrials,badElectrodes,badTrialsUnique] = loadBadTrials(badTrialFile);
            badElecsAll = unique([badElectrodes.badImpedanceElecs; badElectrodes.noisyElecs; badElectrodes.flatPSDElecs; badElectrodes.flatPSDElecs]);
            disp([num2str(length(badTrials)) ' bad trials']);
        end
        
        highPriorityElectrodeNums = getHighPriorityElectrodes(capType);
        
        if strcmp(refType,'unipolar')
            badHighPriorityElecs{iRef}{iSub} = intersect(highPriorityElectrodeNums,badElecsAll); %#ok<*AGROW>
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
            
            badElecs{iRef}{iSub} = badBipolarElecs;
            highPriorityBipolarElectrodeNums = [93 94 101 102 96 97 111 107 112];
            badHighPriorityElecs{iRef}{iSub} = intersect(highPriorityBipolarElectrodeNums,badBipolarElecs);
            disp(['Bipolar, all bad elecs: ' num2str(length(badBipolarElecs)) '; all high-priority bad elecs: ' num2str(length(intersect(highPriorityBipolarElectrodeNums,badBipolarElecs))) ]);
        end
        
        a=1; e=1; s=1; c =1;
        tList= 1:length(tValsUnique);
        
        for iElec = 1:length(electrodeList)
            clear x
            if iRef == 1
                clear x
                %                     disp(['Processing electrode no: ' num2str(electrodeList{iElec}{1})])
                if iElec == length(electrodeList)
                    disp('Processing unipolar electrodes')
                end
                x = load(fullfile(folderLFP,['elec' num2str(electrodeList{iElec}{1}) '.mat']));
            elseif iRef == 2
                clear x1 x2 x
                %                     disp(['Processing bipolar electrode no. ' num2str(iElec) ': electrode ID: ' num2str(electrodeList{iElec}{1}(1)) ' - ' num2str(electrodeList{iElec}{1}(2))])
                if iElec == length(electrodeList)
                    disp('Processing bipolar electrodes')
                end
                x1 = load(fullfile(folderLFP,['elec' num2str(electrodeList{iElec}{1}(1)) '.mat']));
                x2 = load(fullfile(folderLFP,['elec' num2str(electrodeList{iElec}{1}(2)) '.mat']));
                x.analogData = x1.analogData-x2.analogData;
            end
            % loop for parameter combinations
            for iTF = 1:2
                clear goodPos1 goodPos2
                goodPos1 = parameterCombinations{a,e,s,length(fValsUnique)+1,length(oValsUnique)+1,c,iTF};
                goodPos2 = parameterCombinations{a,e,s,maxGamma_SFIndex{iSub},maxGamma_OriIndex{iSub},c,iTF};

                if removeBadEyeTrialsFlag
                    goodPos1 = setdiff(goodPos1,union(badTrials,badTrialsUnique.badEyeTrials));
                    goodPos2 = setdiff(goodPos2,union(badTrials,badTrialsUnique.badEyeTrials));
                else
                    goodPos1 = setdiff(goodPos1,badTrials);
                    goodPos2 = setdiff(goodPos2,badTrials);
                    
                end
                
                
                if isempty(goodPos1)
                    disp(['No entries for this combination.. iSub == ' num2str(iSub) ' iTF ==' num2str(iTF)]);
                elseif isempty(goodPos2)
                    disp(['No entries for this combination.. iSub == ' num2str(iSub) ' iTF ==' num2str(iTF)]);
                else
                    if iRef ==1
                        stimNum(iSub,iTF) = length(goodPos1);
                        stimNum_maxGamma(iSub,iTF) = length(goodPos2);
                    end
                    
                    % fft computation
                    fftBL(iSub,iElec,iTF,:) = squeeze(mean(abs(fft(x.analogData(goodPos1,blPos),[],2)))); %#ok<*NASGU,*AGROW>
                    fftST(iSub,iElec,iTF,:) = squeeze(mean(abs(fft(x.analogData(goodPos1,stPos),[],2))));
                    
                    fftBL_maxGamma(iSub,iElec,iTF,:) = squeeze(mean(abs(fft(x.analogData(goodPos2,blPos),[],2)))); %#ok<*NASGU,*AGROW>
                    fftST_maxGamma(iSub,iElec,iTF,:) = squeeze(mean(abs(fft(x.analogData(goodPos2,stPos),[],2))));
                   
                    
                    % Set up params for MT
                    params.tapers   = tapers;
                    params.pad      = -1;
                    params.Fs       = Fs;
                    params.fpass    = [0 250];
                    params.trialave = 1;
                    
                    % Set up movingWindow parameters for time-frequency plot
                    winSize = 0.1;
                    winStep = 0.025;
                    movingwin = [winSize winStep];
                    
                    % Trial Wise PSD computation and trial-averaging
                    [tmpEBL,freqValsBL] = mtspectrumc(x.analogData(goodPos1,blPos)',params);
                    [tmpEST,freqValsST] = mtspectrumc(x.analogData(goodPos1,stPos)',params);
                    
                    [tmpEBL_maxGamma,~] = mtspectrumc(x.analogData(goodPos1,blPos)',params);
                    [tmpEST_maxGamma,~] = mtspectrumc(x.analogData(goodPos2,stPos)',params);
                    
                    if isequal(freqValsBL,freqValsST)
                        freqVals = freqValsST;
                    end
                    
                    if iTF == 1
                        tfLeft = 0; tfRight = 0;
                    elseif iTF == 2
                        tfLeft = unique(freqRanges{4}/2); tfRight = unique(freqRanges{4}/2);
                    end
                    
                    
                    psdBL(iSub,iElec,iTF,:) = tmpEBL;
                    psdST(iSub,iElec,iTF,:) = tmpEST;
                    
                    psdBL_maxGamma(iSub,iElec,iTF,:) =  tmpEBL_maxGamma;
                    psdST_maxGamma(iSub,iElec,iTF,:) =  tmpEST_maxGamma;
                    
                    for iFreqRange=1:length(freqRanges)
                        if iFreqRange == 3||iFreqRange == 4
                            remove_NthHarmonicOnwards = 3;
                        else
                            remove_NthHarmonicOnwards = 2;
                        end
                        deltaF_LineNoise = 2; deltaF_tfHarmonics = 0;
                        badFreqPos = getBadFreqPos(freqVals,deltaF_LineNoise,deltaF_tfHarmonics,remove_NthHarmonicOnwards,tfLeft,tfRight);
                        
                        powerValsBL{iFreqRange}(iSub,iTF,iElec) = getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{iFreqRange},badFreqPos);
                        powerValsST{iFreqRange}(iSub,iTF,iElec) = getMeanEnergyForAnalysis(tmpEST,freqVals,freqRanges{iFreqRange},badFreqPos);
                        
                        powerValsBL_maxGamma{iFreqRange}(iSub,iTF,iElec) = getMeanEnergyForAnalysis(tmpEBL_maxGamma,freqVals,freqRanges{iFreqRange},badFreqPos);
                        powerValsST_maxGamma{iFreqRange}(iSub,iTF,iElec) = getMeanEnergyForAnalysis(tmpEST_maxGamma,freqVals,freqRanges{iFreqRange},badFreqPos);

                    end
                    
                    
                    % computing time-frequency spectrum by
                    % multi-taper method (computed for both static
                    % and counterphase stimuli)
                    [tmpE_tf,tmpT_tf,freqVals_tf] = mtspecgramc(x.analogData(goodPos1,:)',movingwin,params);
                    [tmpE_tf_maxGamma,~,~] = mtspecgramc(x.analogData(goodPos2,:)',movingwin,params);
                    
                    timeVals_tf= tmpT_tf + timeVals(1);
                    energy_tf = conv2Log(tmpE_tf)';
                    energyBL_tf = mean(energy_tf(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);
                    energy_tf_maxGamma = conv2Log(tmpE_tf_maxGamma)';
                    energyBL_tf_maxGamma = mean(energy_tf_maxGamma(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);

                    
                    mEnergy_tf(iSub,iElec,iTF,:,:) = energy_tf;
                    mEnergyBL_tf(iSub,iElec,iTF,:,:) = repmat(energyBL_tf,1,length(timeVals_tf));
                    mEnergy_tf_maxGamma(iSub,iElec,iTF,:,:) = energy_tf_maxGamma;
                    mEnergyBL_tf_maxGamma(iSub,iElec,iTF,:,:) = repmat(energyBL_tf_maxGamma,1,length(timeVals_tf));
                    
                    % Trial-averaged PSD computation
                    [tmpEBL_trialAvg,~] = mtspectrumc(mean(x.analogData(goodPos1,blPos),1)',params);
                    [tmpEST_trialAvg,~] = mtspectrumc(mean(x.analogData(goodPos1,stPos),1)',params);
                    
                    [tmpEBL_trialAvg_maxGamma,~] = mtspectrumc(mean(x.analogData(goodPos2,blPos),1)',params);
                    [tmpEST_trialAvg_maxGamma,~] = mtspectrumc(mean(x.analogData(goodPos2,stPos),1)',params);
                    
                    psdBL_trialAvg(iSub,iElec,iTF,:) = tmpEBL_trialAvg;
                    psdST_trialAvg(iSub,iElec,iTF,:) = tmpEST_trialAvg;
                    psdBL_trialAvg_maxGamma(iSub,iElec,iTF,:) = tmpEBL_trialAvg_maxGamma;
                    psdST_trialAvg_maxGamma(iSub,iElec,iTF,:) = tmpEST_trialAvg_maxGamma;
                    
                    for iFreqRange=1:length(freqRanges)
                        if iFreqRange == 3||iFreqRange == 4
                            remove_NthHarmonicOnwards = 3;
                        else
                            remove_NthHarmonicOnwards = 2;
                        end
                        deltaF_LineNoise = 2; deltaF_tfHarmonics = 0;
                        badFreqPos = getBadFreqPos(freqVals,deltaF_LineNoise,deltaF_tfHarmonics,remove_NthHarmonicOnwards,tfLeft,tfRight);
                        
                        powerValsBL_trialAvg{iFreqRange}(iSub,iTF,iElec) = getMeanEnergyForAnalysis(tmpEBL_trialAvg,freqVals,freqRanges{iFreqRange},badFreqPos);
                        powerValsST_trialAvg{iFreqRange}(iSub,iTF,iElec) = getMeanEnergyForAnalysis(tmpEST_trialAvg,freqVals,freqRanges{iFreqRange},badFreqPos);
                        powerValsBL_trialAvg_maxGamma{iFreqRange}(iSub,iTF,iElec) = getMeanEnergyForAnalysis(tmpEBL_trialAvg_maxGamma,freqVals,freqRanges{iFreqRange},badFreqPos);
                        powerValsST_trialAvg_maxGamma{iFreqRange}(iSub,iTF,iElec) = getMeanEnergyForAnalysis(tmpEST_trialAvg_maxGamma,freqVals,freqRanges{iFreqRange},badFreqPos);

                    end
                    
                    % TF
                    % computing time-frequency spectrum by
                    % multi-taper method (computed for both static
                    % and counterphase stimuli)
                    [tmpE_tf,~,~] = mtspecgramc(mean(x.analogData(goodPos1,:),1)',movingwin,params);
                    [tmpE_tf_maxGamma,~,~] = mtspecgramc(mean(x.analogData(goodPos2,:),1)',movingwin,params);

                    
                    timeVals_tf= tmpT_tf + timeVals(1);
                    energy_tf_trialAvg = conv2Log(tmpE_tf)';
                    energyBL_tf_trialAvg = mean(energy_tf_trialAvg(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);
                    energy_tf_trialAvg_maxGamma = conv2Log(tmpE_tf_maxGamma)';
                    energyBL_tf_trialAvg_maxGamma = mean(energy_tf_trialAvg_maxGamma(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);

                    
                    mEnergy_tf_trialAvg(iSub,iElec,iTF,:,:) = energy_tf_trialAvg;
                    mEnergyBL_tf_trialAvg(iSub,iElec,iTF,:,:) = repmat(energyBL_tf_trialAvg,1,length(timeVals_tf));
                    mEnergy_tf_trialAvg_maxGamma(iSub,iElec,iTF,:,:) = energy_tf_trialAvg_maxGamma;
                    mEnergyBL_tf_trialAvg_maxGamma(iSub,iElec,iTF,:,:) = repmat(energyBL_tf_trialAvg_maxGamma,1,length(timeVals_tf));

                end
            end
        end
    end
    
    fftBL_all{iRef} = fftBL;
    fftST_all{iRef} = fftST;
    fftBL_all_maxGamma{iRef} = fftBL_maxGamma;
    fftST_all_maxGamma{iRef} = fftST_maxGamma;
    
    psdBL_all{iRef} = psdBL;
    psdST_all{iRef} = psdST;
    powerValsBL_all{iRef} = powerValsBL;
    powerValsST_all{iRef} = powerValsST;
    
    psdBL_all_maxGamma{iRef} = psdBL_maxGamma;
    psdST_all_maxGamma{iRef} = psdST_maxGamma;
    powerValsBL_all_maxGamma{iRef} = powerValsBL_maxGamma;
    powerValsST_all_maxGamma{iRef} = powerValsST_maxGamma;
    
    
    tfData_all{iRef} = mEnergy_tf;
    tfDataBL_all{iRef} = mEnergyBL_tf;
    tfData_trialAvg_all{iRef} = mEnergy_tf_trialAvg;
    tfDataBL_trialAvg_all{iRef} = mEnergyBL_tf_trialAvg;
    
    tfData_all_maxGamma{iRef} = mEnergy_tf_maxGamma;
    tfDataBL_all_maxGamma{iRef} = mEnergyBL_tf_maxGamma;
    tfData_trialAvg_all_maxGamma{iRef} = mEnergy_tf_trialAvg_maxGamma;
    tfDataBL_trialAvg_all_maxGamma{iRef} = mEnergyBL_tf_trialAvg_maxGamma;
    
    tfData.timeVals = timeVals_tf;
    tfData.freqVals = freqVals_tf;
    
    psdBL_trialAvg_all{iRef} = psdBL_trialAvg;
    psdST_trialAvg_all{iRef} = psdST_trialAvg;
    powerValsBL_trialAvg_all{iRef} = powerValsBL_trialAvg;
    powerValsST_trialAvg_all{iRef} = powerValsST_trialAvg;
    
    psdBL_trialAvg_all_maxGamma{iRef} = psdBL_trialAvg_maxGamma;
    psdST_trialAvg_all_maxGamma{iRef} = psdST_trialAvg_maxGamma;
    powerValsBL_trialAvg_all_maxGamma{iRef} = powerValsBL_trialAvg_maxGamma;
    powerValsST_trialAvg_all_maxGamma{iRef} = powerValsST_trialAvg_maxGamma;

    
end

fftData.dataBL = fftBL_all;
fftData.dataST = fftST_all;
fftData.dataBL_maxGamma = fftBL_all_maxGamma;
fftData.dataST_maxGamma = fftST_all_maxGamma;
fftData.freqVals = freqVals_fft;
fftData.stimNum = stimNum;
fftData.stimNum_maxGamma = stimNum_maxGamma;

energyData.dataBL = psdBL_all;
energyData.dataST = psdST_all;
energyData.dataBL_trialAvg = psdBL_trialAvg_all;
energyData.dataST_trialAvg = psdST_trialAvg_all;
energyData.analysisDataBL = powerValsBL_all;
energyData.analysisDataST = powerValsST_all;
energyData.analysisDataBL_trialAvg = powerValsBL_trialAvg_all;
energyData.analysisDataST_trialAvg = powerValsST_trialAvg_all;
energyData.dataBL_maxGamma = psdBL_all_maxGamma;
energyData.dataST_maxGamma = psdST_all_maxGamma;
energyData.dataBL_trialAvg_maxGamma = psdBL_trialAvg_all_maxGamma;
energyData.dataST_trialAvg_maxGamma = psdST_trialAvg_all_maxGamma;
energyData.analysisDataBL_maxGamma = powerValsBL_all_maxGamma;
energyData.analysisDataST_maxGamma = powerValsST_all_maxGamma;
energyData.analysisDataBL_trialAvg_maxGamma = powerValsBL_trialAvg_all_maxGamma;
energyData.analysisDataST_trialAvg_maxGamma = powerValsST_trialAvg_all_maxGamma;
energyData.freqVals = freqVals;
energyData.stimNum = stimNum;
energyData.stimNum_maxGamma = stimNum_maxGamma;

% Time-Frequency data
energyDataTF.data = tfData_all;
energyDataTF.data_BL = tfDataBL_all;
energyDataTF.data_trialAvg = tfData_trialAvg_all;
energyDataTF.data_BL_trialAvg = tfDataBL_trialAvg_all;
energyDataTF.data_maxGamma = tfData_all_maxGamma;
energyDataTF.data_BL_maxGamma = tfDataBL_all_maxGamma;
energyDataTF.data_trialAvg_maxGamma = tfData_trialAvg_all_maxGamma;
energyDataTF.data_BL_trialAvg_maxGamma = tfDataBL_trialAvg_all_maxGamma;
energyDataTF.timeVals = timeVals_tf;
energyDataTF.freqVals = freqVals_tf;
energyDataTF.stimNum = stimNum;
energyDataTF.stimNum_maxGamma = stimNum_maxGamma;
end

% Accessory Functions

% Load LFP Info
function [analogChannelsStored,timeVals,goodStimPos,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
load(fullfile(folderLFP,'lfpInfo.mat')); %#ok<*LOAD>
analogChannelsStored=sort(analogChannelsStored); %#ok<NODEF>
if ~exist('analogInputNums','var')
    analogInputNums=[];
end
end

function [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
    fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract,sideChoice)

p = load(fullfile(folderExtract,'parameterCombinations.mat'));

if ~isfield(p,'parameterCombinations2') % Not a plaid stimulus
    load(fullfile(folderExtract,'parameterCombinations.mat'));
    
    if ~exist('sValsUnique','var');    sValsUnique=rValsUnique;             end
    if ~exist('cValsUnique','var');    cValsUnique=100;                     end
    if ~exist('tValsUnique','var');    tValsUnique=0;                       end
    
else
    [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
        fValsUnique,oValsUnique,cValsUnique,tValsUnique] = makeCombinedParameterCombinations(folderExtract,sideChoice);
end

end

function [badTrials,badElecs,badTrialsUnique] = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
end

function badFreqPos = getBadFreqPos(freqVals,deltaF_LineNoise,deltaF_TFHarmonics,remove_NthHarmonicOnwards,tfLeft,tfRight)
% During this Project, line Noise was at
% 51 Hz for 1 Hz Freq Resolution and
% 52 Hz for 2 Hz Freq Resolution

if nargin<2
    deltaF_LineNoise = 1; deltaF_TFHarmonics = 0; tfLeft = 0; tfRight = 0;
end

if tfLeft>0 && tfRight>0 % Flickering Stimuli
    badFreqs = 52:52:max(freqVals);
    tfHarmonics1 = remove_NthHarmonicOnwards*tfLeft:tfLeft:max(freqVals); % remove nth SSVEP harmonic and beyond
    tfHarmonics2 = remove_NthHarmonicOnwards*tfRight:tfRight:max(freqVals); % remove nth SSVEP harmonic and beyond
    tfHarmonics = unique([tfHarmonics1 tfHarmonics2]);
elseif tfLeft==0 && tfRight==0 % Static Stimuli
    badFreqs = 52:52:max(freqVals);
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


% Get MeanEnergy for different frequency bands
function eValue = getMeanEnergyForAnalysis(mEnergy,freq,freqRange,badFreqPos)

posToAverage = setdiff(intersect(find(freq>=freqRange(1)),find(freq<=freqRange(2))),badFreqPos);
eValue   = sum(mEnergy(posToAverage));
end

