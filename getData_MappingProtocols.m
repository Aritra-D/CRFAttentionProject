function [fftData,energyData,energyDataTF,badHighPriorityElecs,badElecs] = getData_MappingProtocols(protocolType,gridType,timingParameters,tapers,freqRanges)

[subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationMappingProtocols_HumanEEG(gridType,protocolType);

deviceName = 'BP';
capType = 'actiCap64';
numFreqs = length(freqRanges);

for iRef = 1:2
    clear powerValsBL powerValsST electrodeList 
    for iSub = 1:size(subjectNames,1)
        for iProt = 1:size(protocolNames,2)
            disp(['SUBJECT: ' num2str(iSub) ', Protocol: ' num2str(iProt)])
            clear badTrials badElectrodes
            folderName = fullfile(dataFolderSourceString,'data',subjectNames{iSub,iProt},gridType,expDates{iSub,iProt},protocolNames{iSub,iProt});
            folderExtract= fullfile(folderName,'extractedData');
            folderSegment= fullfile(folderName,'segmentedData');
            folderLFP = fullfile(folderSegment,'LFP');
            
            % load LFP Info
            [analogChannelsStored,timeVals,~,~] = loadlfpInfo(folderLFP);
            
            % Get Parameter Combinations for SF-Ori Protocols
            [parameterCombinations,parameterCombinations2,...
                aValsUnique,eValsUnique,sValsUnique,sfValsUnique,oValsUnique,cValsUnique,tValsUnique, ...
                aValsUnique2,eValsUnique2,sValsUnique2,sfValsUnique2,oValsUnique2,cValsUnique2,tValsUnique2] = ...
                loadParameterCombinations(folderExtract); %#ok<ASGLU>
            
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
            badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
            if ~exist(badTrialFile,'file')
                disp('Bad trial file does not exist...');
                badElecs = []; badTrials=[];
            else
                [badTrials,badElectrodes] = loadBadTrials(badTrialFile);
                badElecsAll = unique([badElectrodes.badImpedanceElecs; badElectrodes.noisyElecs; badElectrodes.flatPSDElecs; badElectrodes.flatPSDElecs]);
                disp([num2str(length(badTrials)) ' bad trials']);
            end
            
            highPriorityElectrodeNums = getHighPriorityElectrodes(capType);
            
            if strcmp(refType,'unipolar')
                badHighPriorityElecs{iRef}{iSub,iProt} = intersect(highPriorityElectrodeNums,badElecsAll);
                badElecs{iRef}{iSub,iProt} = intersect(setdiff(analogChannelsStored,photoDiodeChannels),badElecsAll);
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
                
                badElecs{iRef}{iSub,iProt} = badBipolarElecs;
                highPriorityBipolarElectrodeNums = [93 94 101 102 96 97 111 107 112];
                badHighPriorityElecs{iRef}{iSub,iProt} = intersect(highPriorityBipolarElectrodeNums,badBipolarElecs);
                disp(['Bipolar, all bad elecs: ' num2str(length(badBipolarElecs)) '; all high-priority bad elecs: ' num2str(length(intersect(highPriorityBipolarElectrodeNums,badBipolarElecs))) ]);
            end
            
            % indexing combinations
            a1=1;  e1=1; s1=1; sf1=1; o1=1; c1 =1;
            a2=1;  e2=1; s2=1; sf2=1; o2=1; c2=1;
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
                    clear goodPos
                    goodPos1 = parameterCombinations{a1,e1,s1,sf1,o1,c1,iTF};
                    goodPos2 = parameterCombinations2{a2,e2,s2,sf2,o2,c2,iTF};
                    goodPos = intersect(goodPos1,goodPos2);
                    goodPos = setdiff(goodPos,badTrials);
                    
                    if isempty(goodPos)
                        disp(['No entries for this combination.. iSub == ' num2str(iSub) ' iProt == ' num2str(iProt) ' iTF ==' num2str(iTF)]);
                    else
                        if iRef ==1
                            stimNum(iSub,iProt,iTF) = length(goodPos);
                        end
                        
                        %                             if strcmp(analysisType,'FFT')
                        fftBL(iSub,iProt,iElec,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,blPos),[],2))))); %#ok<*NASGU,*AGROW>
                        fftST(iSub,iProt,iElec,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,stPos),[],2)))));
                        %                             elseif strcmp(analysisType,'MT')
                        
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
                        [tmpEBL,freqValsBL] = mtspectrumc(x.analogData(goodPos,blPos)',params);
                        [tmpEST,freqValsST] = mtspectrumc(x.analogData(goodPos,stPos)',params);
                        
                        
                        if isequal(freqValsBL,freqValsST)
                            freqVals = freqValsST;
                        end
                        
                        psdBL(iSub,iProt,iElec,iTF,:) = conv2Log(tmpEBL);
                        psdST(iSub,iProt,iElec,iTF,:) = conv2Log(tmpEST);
                       
                        if iTF ==1
                            for i=1:2
                                powerValsBL{i}(iSub,iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{i}));
                                powerValsST{i}(iSub,iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEST,freqVals,freqRanges{i}));
                            end
                        elseif iTF ==2
                            for i=3:4
                            powerValsBL{i}(iSub,iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{i}));
                            powerValsST{i}(iSub,iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEST,freqVals,freqRanges{i}));
                            end
                        end
                        
                        % computing time-frequency spectrum by
                        % multi-taper method (computed for both static
                        % and counterphase stimuli)
                        [tmpE_tf,tmpT_tf,freqVals_tf] = mtspecgramc(x.analogData(goodPos,:)',movingwin,params);
                        
                        timeVals_tf= tmpT_tf + timeVals(1);
                        energy_tf = conv2Log(tmpE_tf)';
                        energyBL_tf = mean(energy_tf(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);
                        
                        mEnergy_tf(iSub,iProt,iElec,iTF,:,:) = energy_tf;
                        mEnergyBL_tf(iSub,iProt,iElec,iTF,:,:) = repmat(energyBL_tf,1,length(timeVals_tf));
                        
                        % Trial-averaged PSD computation
                        [tmpEBL_trialAvg,~] = mtspectrumc(mean(x.analogData(goodPos,blPos),1)',params);
                        [tmpEST_trialAvg,~] = mtspectrumc(mean(x.analogData(goodPos,stPos),1)',params);
                        
                        psdBL_trialAvg(iSub,iProt,iElec,iTF,:) = conv2Log(tmpEBL_trialAvg);
                        psdST_trialAvg(iSub,iProt,iElec,iTF,:) = conv2Log(tmpEST_trialAvg);

                        
                        if iTF ==1
                            for i=1:2
                                powerValsBL_trialAvg{i}(iSub,iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEBL_trialAvg,freqVals,freqRanges{i}));
                                powerValsST_trialAvg{i}(iSub,iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEST_trialAvg,freqVals,freqRanges{i}));
                            end
                        elseif iTF ==2
                            for i=3:4
                                powerValsBL_trialAvg{i}(iSub,iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEBL_trialAvg,freqVals,freqRanges{i}));
                                powerValsST_trialAvg{i}(iSub,iProt,iElec) = conv2Log(getMeanEnergyForAnalysis(tmpEST_trialAvg,freqVals,freqRanges{i}));
                            end
                        end
                        
                        % TF
                        % computing time-frequency spectrum by
                        % multi-taper method (computed for both static
                        % and counterphase stimuli)
                        [tmpE_tf,~,~] = mtspecgramc(mean(x.analogData(goodPos,:),1)',movingwin,params);
                        
                        timeVals_tf= tmpT_tf + timeVals(1);
                        energy_tf_trialAvg = conv2Log(tmpE_tf)';
                        energyBL_tf_trialAvg = mean(energy_tf(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);
                        
                        mEnergy_tf_trialAvg(iSub,iProt,iElec,iTF,:,:) = energy_tf_trialAvg;
                        mEnergyBL_tf_trialAvg(iSub,iProt,iElec,iTF,:,:) = repmat(energyBL_tf_trialAvg,1,length(timeVals_tf));
                        
                        
                        %                             end
                    end
                end
            end
        end
    end
    
    fftBL_all{iRef} = fftBL;
    fftST_all{iRef} = fftST;
    
    psdBL_all{iRef} = psdBL;
    psdST_all{iRef} = psdST;
    powerValsBL_all{iRef} = powerValsBL;
    powerValsST_all{iRef} = powerValsST;
    
    tfData_all{iRef} = mEnergy_tf;
    tfDataBL_all{iRef} = mEnergyBL_tf;
    tfData.timeVals = timeVals_tf;
    tfData.freqVals = freqVals_tf;
    
    psdBL_trialAvg_all{iRef} = psdBL_trialAvg;
    psdST_trialAvg_all{iRef} = psdST_trialAvg;
    powerValsBL_trialAvg_all{iRef} = powerValsBL_trialAvg;
    powerValsST_trialAvg_all{iRef} = powerValsST_trialAvg;
    
    tfData_trialAvg_all{iRef} = mEnergy_tf_trialAvg;
    tfDataBL_trialAvg_all{iRef} = mEnergyBL_tf_trialAvg;

end

fftData.dataBL = fftBL_all;
fftData.dataST = fftST_all;
fftData.freqVals = freqVals_fft;
fftData.stimNum = stimNum;

energyData.dataBL = psdBL_all;
energyData.dataST = psdST_all;
energyData.dataBL_trialAvg = psdBL_trialAvg_all;
energyData.dataST_trialAvg = psdST_trialAvg_all;
energyData.analysisDataBL = powerValsBL_all;
energyData.analysisDataST = powerValsST_all;
energyData.analysisDataBL_trialAvg = powerValsBL_trialAvg_all;
energyData.analysisDataST_trialAvg = powerValsST_trialAvg_all;
energyData.freqVals = freqVals;
energyData.stimNum = stimNum;

% Time-Frequency data
energyDataTF.data = tfData_all;
energyDataTF.data_BL = tfDataBL_all;
energyDataTF.data_trialAvg = tfData_trialAvg_all;
energyDataTF.data_BL_trialAvg = tfDataBL_trialAvg_all;
energyDataTF.timeVals = timeVals_tf;
energyDataTF.freqVals = freqVals_tf;
energyDataTF.stimNum = stimNum;
end



% Accessory Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%  Accessory Functions  %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load LFP Info
function [analogChannelsStored,timeVals,goodStimPos,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
load(fullfile(folderLFP,'lfpInfo.mat'));
analogChannelsStored=sort(analogChannelsStored); %#ok<NODEF>
if ~exist('analogInputNums','var')
    analogInputNums=[];
end
end


% Get parameter combinations
function [parameterCombinations,parameterCombinations2,...
    aValsUnique,eValsUnique,sValsUnique,fValsUnique,oValsUnique,...
    cValsUnique,tValsUnique,aValsUnique2,eValsUnique2,sValsUnique2,...
    fValsUnique2,oValsUnique2,cValsUnique2,tValsUnique2] = ...
    loadParameterCombinations(folderExtract)

load(fullfile(folderExtract,'parameterCombinations.mat')); %#ok<*LOAD>

if ~exist('sValsUnique','var');    sValsUnique=rValsUnique;            end

end

% Get Bad Trials
function [badTrials,badElecs] = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
end

% Get Induced LFP data by subtracting trialaveraged ERP data from trialwise LFP Data
% function Y = removeERP(X)
% Y = X-repmat(mean(X,1),size(X,1),1);
% end

% Get MeanEnergy for different frequency bands
function eValue = getMeanEnergyForAnalysis(mEnergy,freq,freqRange)

posToAverage = intersect(find(freq>=freqRange(1)),find(freq<=freqRange(2)));
eValue   = sum(mEnergy(posToAverage));
end
