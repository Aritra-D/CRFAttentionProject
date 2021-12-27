function [erpData,fftData,energyData,badHighPriorityElecs,badElecs] = getData_SRCLongProtocols(protocolType,gridType,timingParameters,tapers,freqRanges)

[subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationSRCProtocols_HumanEEG(gridType,protocolType);

deviceName = 'BP';
capType = 'actiCap64';
numFreqs = length(freqRanges);

% Fixed indexing combinations
c = 1; s = 1; % Contrast and StimType Index are set as 1 for SRC-Long Protocols

for iRef = 1:2
    clear powerValsBL powerValsST powerValsTG electrodeList
    clear powerValsBL_trialAvg powerValsST_trialAvg powerValsTG_trialAvg
    for iSub = 1:size(subjectNames,1)
        disp(['SUBJECT: ' num2str(iSub) ', EXPDATE:' num2str(expDates{iSub}) ', PROTOCOL:' num2str(protocolNames{iSub})])
        clear badTrials badElectrodes
        folderName = fullfile(dataFolderSourceString,'data',subjectNames{iSub},gridType,expDates{iSub},protocolNames{iSub});
        folderExtract= fullfile(folderName,'extractedData');
        folderSegment= fullfile(folderName,'segmentedData');
        folderLFP = fullfile(folderSegment,'LFP');
        
        % load LFP Info
        [analogChannelsStored,timeVals,~,~] = loadlfpInfo(folderLFP);
        
        % Get Parameter Combinations for SRC-Long Protocols
        [parameterCombinations,cValsUnique,tValsUnique,eValsUnique,aValsUnique,sValsUnique]= ...
            loadParameterCombinations(folderExtract); %#ok<ASGLU>
        
        % timing related Information
        Fs = round(1/(timeVals(2)-timeVals(1)));
        if round(diff(timingParameters.blRange)*Fs) ~= round(diff(timingParameters.stRange)*Fs)
            disp('baseline and stimulus ranges are not the same');
        else
            range = timingParameters.blRange;
            erpRange = timingParameters.erpRange;
            rangePos = round(diff(range)*Fs);
            erpRangePos = round(diff(erpRange)*Fs);
            blPos = find(timeVals>=timingParameters.blRange(1),1)+ (1:rangePos);
            stPos = find(timeVals>=timingParameters.stRange(1),1)+ (1:rangePos);
            tgPos = find(timeVals>=timingParameters.tgRange(1),1)+ (1:rangePos);
            erpPos = find(timeVals>=timingParameters.erpRange(1),1)+ (1:erpRangePos);
            freqVals_fft = 0:1/diff(range):Fs-1/diff(range);
        end
        
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
        
        % Electrode and trial related Information
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
            
            badElecs{iRef}{iSub} = badBipolarElecs;
            highPriorityBipolarElectrodeNums = [93 94 101 102 96 97 111 107 112];
            badHighPriorityElecs{iRef}{iSub} = intersect(highPriorityBipolarElectrodeNums,badBipolarElecs);
            disp(['Bipolar, all bad elecs: ' num2str(length(badBipolarElecs)) '; all high-priority bad elecs: ' num2str(length(intersect(highPriorityBipolarElectrodeNums,badBipolarElecs))) ]);
        end
        
        % main Loop
        for iElec = 1:length(electrodeList)
            clear x
            if iRef == 1
                clear x
                %                     disp(['Processing electrode no: ' num2str(electrodeList{iElec}{1})])
                if iElec == length(electrodeList)
                    disp('Processed unipolar electrodes')
                end
                x = load(fullfile(folderLFP,['elec' num2str(electrodeList{iElec}{1}) '.mat']));
            elseif iRef == 2
                clear x1 x2 x
                %                     disp(['Processing bipolar electrode no. ' num2str(iElec) ': electrode ID: ' num2str(electrodeList{iElec}{1}(1)) ' - ' num2str(electrodeList{iElec}{1}(2))])
                if iElec == length(electrodeList)
                    disp('Processed bipolar electrodes')
                end
                x1 = load(fullfile(folderLFP,['elec' num2str(electrodeList{iElec}{1}(1)) '.mat']));
                x2 = load(fullfile(folderLFP,['elec' num2str(electrodeList{iElec}{1}(2)) '.mat']));
                x.analogData.stimOnset = x1.analogData.stimOnset-x2.analogData.stimOnset;
                x.analogData.targetOnset = x1.analogData.targetOnset-x2.analogData.targetOnset;
            end
            
            for iEOTCode = 1: length(eValsUnique)
                for iAttendLoc = 1: length(aValsUnique)
                    for iTF = 1: length(tValsUnique)
                        clear goodPos_stimOnset goodPos_targetOnset
                        goodPos_stimOnset = setdiff(parameterCombinations.stimOnset{c,iTF,iEOTCode,iAttendLoc,s},badTrials);
                        goodPos_targetOnset = setdiff(parameterCombinations.targetOnset{c,iTF,iEOTCode,iAttendLoc,s},badTrials);
                        
                        
                        if isempty(goodPos_stimOnset)
                            disp('No entries for this combination..')
                        else
                            if iRef==1 && iElec ==1
                                disp([iEOTCode iAttendLoc iTF length(goodPos_stimOnset)])
                                trialNums(iSub,iEOTCode,iAttendLoc,iTF) = length(goodPos_stimOnset);
                            end
                            
                            % erp
                            erp_stimOnset = mean(x.analogData.stimOnset(goodPos_stimOnset,:),1);
                            erp_targetOnset = mean(x.analogData.targetOnset(goodPos_targetOnset,:),1);
                            % Baseline Correction
                            erp_stimOnset = erp_stimOnset - repmat(mean(erp_stimOnset(:,blPos),2),1,size(erp_stimOnset,2));
                            erp_targetOnset = erp_targetOnset - repmat(mean(erp_targetOnset(:,blPos),2),1,size(erp_targetOnset,2));
                            
                            erpStim(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = erp_stimOnset;
                            erpTarget(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = erp_targetOnset;
                            RMSValsBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = rms(erp_stimOnset(blPos));
                            RMSValsERP_Stim(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = rms(erp_stimOnset(erpPos));
                            RMSValsERP_Target(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = rms(erp_targetOnset(erpPos));
                            
                            % fft
                            fftBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData.stimOnset(goodPos_stimOnset,blPos),[],2))))); %#ok<*NASGU,*AGROW>
                            fftST(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData.stimOnset(goodPos_stimOnset,stPos),[],2)))));
                            fftTG(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData.targetOnset(goodPos_targetOnset,tgPos),[],2)))));
                            
                            % Segmenting data according to timePos
                            dataBL = x.analogData.stimOnset(goodPos_stimOnset,blPos)';
                            dataStimOnset = x.analogData.stimOnset(goodPos_stimOnset,stPos)';
                            dataTargetOnset = x.analogData.targetOnset(goodPos_targetOnset,tgPos)';
                            
                            % power spectral density estimation
                            [tmpEBL,freqValsBL] = mtspectrumc(dataBL,params);
                            [tmpEST,freqValsST] = mtspectrumc(dataStimOnset,params);
                            [tmpETG,freqValsTG] = mtspectrumc(dataTargetOnset,params);
                            
                            if isequal(freqValsBL,freqValsST) && isequal(freqValsBL,freqValsTG)
                                freqVals = freqValsBL;
                            end
                            
                            psdBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEBL);
                            psdST(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEST);
                            psdTG(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpETG);
                            
                            for iFreqRange=1:4
                                powerValsBL{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{iFreqRange}));
                                powerValsST{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEST,freqVals,freqRanges{iFreqRange}));
                                powerValsTG{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpETG,freqVals,freqRanges{iFreqRange}));
                            end
                            
                            % computing time-frequency spectrum by
                            % multi-taper method (computed for both static
                            % and counterphase stimuli)
%                             [tmpEST_tf,tmpT_tf,freqVals_tf] = mtspecgramc(x.analogData.stimOnset(goodPos_stimOnset,:)',movingwin,params);
%                             [tmpETG_tf,~,~] = mtspecgramc(x.analogData.targetOnset(goodPos_targetOnset,:)',movingwin,params);
%                             
%                             
%                             timeVals_tf= tmpT_tf + timeVals(1);
%                             energyST_tf = conv2Log(tmpEST_tf)';
%                             energyTG_tf = conv2Log(tmpETG_tf)';
%                             energyBL_tf = mean(energyST_tf(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);
%                             
%                             mEnergyST_tf(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = energyST_tf;
%                             mEnergyTG_tf(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = energyTG_tf;
%                             mEnergyBL_tf(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = repmat(energyBL_tf,1,length(timeVals_tf));
%                             
                            % Segmenting data according to timePos
                            dataBL_avg = mean(x.analogData.stimOnset(goodPos_stimOnset,blPos),1)';
                            dataStimOnset_avg = mean(x.analogData.stimOnset(goodPos_stimOnset,stPos),1)';
                            dataTargetOnset_avg = mean(x.analogData.targetOnset(goodPos_targetOnset,tgPos),1)';
                            
                            % power spectral density estimation
                            [tmpEBL_avg,~] = mtspectrumc(dataBL_avg,params);
                            [tmpEST_avg,~] = mtspectrumc(dataStimOnset_avg,params);
                            [tmpETG_avg,~] = mtspectrumc(dataTargetOnset_avg,params);

                            
                            psdBL_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEBL_avg);
                            psdST_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEST_avg);
                            psdTG_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpETG_avg);
                            
                            for iFreqRange=1:4
                                powerValsBL_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEBL_avg,freqVals,freqRanges{iFreqRange}));
                                powerValsST_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEST_avg,freqVals,freqRanges{iFreqRange}));
                                powerValsTG_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpETG_avg,freqVals,freqRanges{iFreqRange}));
                            end
                            
                            % computing time-frequency spectrum by
                            % multi-taper method (computed for both static
%                             % and counterphase stimuli)
%                             [tmpEST_tf_trialAvg,~,~] = mtspecgramc(mean(x.analogData.stimOnset(goodPos_stimOnset,:),1)',movingwin,params);
%                             [tmpETG_tf_trialAvg,~,~] = mtspecgramc(mean(x.analogData.targetOnset(goodPos_targetOnset,:),1)',movingwin,params);
%                             
%                             
%                             timeVals_tf= tmpT_tf + timeVals(1);
%                             energyST_tf_trialAvg = conv2Log(tmpEST_tf_trialAvg)';
%                             energyTG_tf_trialAvg = conv2Log(tmpETG_tf_trialAvg)';
%                             energyBL_tf_trialAvg = mean(energyST_tf_trialAvg(:,timeVals_tf>=timingParameters.blRange(1)& timeVals_tf<=timingParameters.blRange(2)),2);
%                             
%                             mEnergyST_tf_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = energyST_tf_trialAvg;
%                             mEnergyTG_tf_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = energyTG_tf_trialAvg;
%                             mEnergyBL_tf_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:,:) = repmat(energyBL_tf_trialAvg,1,length(timeVals_tf));
                            
                        end
                    end
                end
            end
        end
    end
    
    % saving data for different Ref Schemes in cell elements
    erpST{iRef} = erpStim;
    erpTG{iRef} = erpTarget;
    rms_erpBL{iRef} = RMSValsBL;
    rms_erpST{iRef} = RMSValsERP_Stim;
    rms_erpTG{iRef} = RMSValsERP_Target;
    
    fftBL_all{iRef} = fftBL;
    fftST_all{iRef} = fftST;
    fftTG_all{iRef} = fftTG;

    psdBL_all{iRef} = psdBL; psdBL_trialAvg_all{iRef} = psdBL_trialAvg;
    psdST_all{iRef} = psdST; psdST_trialAvg_all{iRef} = psdST_trialAvg;
    psdTG_all{iRef} = psdTG; psdTG_trialAvg_all{iRef} = psdTG_trialAvg;
    powerValsBL_all{iRef} = powerValsBL; powerValsBL_trialAvg_all{iRef} = powerValsBL_trialAvg;
    powerValsST_all{iRef} = powerValsST; powerValsST_trialAvg_all{iRef} = powerValsST_trialAvg;
    powerValsTG_all{iRef} = powerValsTG; powerValsTG_trialAvg_all{iRef} = powerValsTG_trialAvg;

%     tfDataBL_all{iRef} = mEnergyBL_tf; tfDataBL_trialAvg_all{iRef} = mEnergyBL_tf_trialAvg;
%     tfDataST_all{iRef} = mEnergyST_tf; tfDataST_trialAvg_all{iRef} = mEnergyST_tf_trialAvg;
%     tfDataTG_all{iRef} = mEnergyTG_tf; tfDataTG_trialAvg_all{iRef} = mEnergyTG_tf_trialAvg;

end

% Structuring data for all data
erpData.dataST = erpST;
erpData.dataTG = erpTG;
erpData.analysisData_BL = rms_erpBL;
erpData.analysisData_ST = rms_erpST;
erpData.analysisData_TG = rms_erpTG;
erpData.timeVals = timeVals;
erpData.trialNum = trialNums;

fftData.dataBL = fftBL_all;
fftData.dataST = fftST_all;
fftData.dataTG = fftTG_all;
fftData.freqVals = freqVals_fft;
fftData.trialNum = trialNums;

energyData.dataBL = psdBL_all;
energyData.dataST = psdST_all;
energyData.dataTG = psdTG_all;
energyData.dataBL_trialAvg = psdBL_trialAvg_all;
energyData.dataST_trialAvg = psdST_trialAvg_all;
energyData.dataTG_trialAvg = psdTG_trialAvg_all;
energyData.analysisDataBL = powerValsBL_all;
energyData.analysisDataST = powerValsST_all;
energyData.analysisDataTG = powerValsTG_all;
energyData.analysisDataBL_trialAvg = powerValsBL_trialAvg_all;
energyData.analysisDataST_trialAvg = powerValsST_trialAvg_all;
energyData.analysisDataTG_trialAvg = powerValsTG_trialAvg_all;
energyData.freqVals = freqVals;
energyData.trialNum = trialNums;

% Time-Frequency data
% energyDataTF.dataST = tfDataST_all;
% energyDataTF.dataBL = tfDataBL_all;
% energyDataTF.dataTG = tfDataTG_all;
% energyDataTF.dataST_trialAvg = tfDataST_trialAvg_all;
% energyDataTF.dataBL_trialAvg = tfDataBL_trialAvg_all;
% energyDataTF.dataTG_trialAvg = tfDataTG_trialAvg_all;
% energyDataTF.timeVals = timeVals_tf;
% energyDataTF.freqVals = freqVals_tf;
% energyDataTF.trialNum = trialNums;

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
function [parameterCombinations,cValsUnique,tValsUnique,eValsUnique,...
    aValsUnique,sValsUnique] = ...
    loadParameterCombinations(folderExtract)

load(fullfile(folderExtract,'parameterCombinations.mat')); %#ok<*LOAD>
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
