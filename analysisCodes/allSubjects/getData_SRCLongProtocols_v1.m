function [erpData,fftData,energyData,freqRanges_SubjectWise,badHighPriorityElecs,badElecs] = getData_SRCLongProtocols_v1(protocolType,gridType,timingParameters,tapers,badTrialStr)

[subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationSRCProtocols_HumanEEG(gridType,protocolType);

deviceName = 'BP';
capType = 'actiCap64';

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
        numFreqs = length(freqRanges);
        
        freqRanges_SubjectWise{iSub} = freqRanges;
        
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
        badTrialFile = fullfile(folderSegment,['badTrials_' badTrialStr '.mat']);
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
                            if iElec ==1
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
                            fftBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(mean(abs(fft(x.analogData.stimOnset(goodPos_stimOnset,blPos),[],2)))); %#ok<*NASGU,*AGROW>
                            fftST(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(mean(abs(fft(x.analogData.stimOnset(goodPos_stimOnset,stPos),[],2))));
                            fftTG(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(mean(abs(fft(x.analogData.targetOnset(goodPos_targetOnset,tgPos),[],2))));
                            
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
                            
                            if iTF == 1
                                tfLeft = 0; tfRight = 0;
                            else
                                if iAttendLoc == 1 % Right
                                    if iTF == 2
                                        tfLeft = unique(freqRanges{4}/2); tfRight = unique(freqRanges{3}/2);
                                    elseif iTF ==3
                                        tfLeft = unique(freqRanges{3}/2); tfRight = unique(freqRanges{4}/2);
                                    end
                                elseif iAttendLoc == 2
                                    if iTF == 2
                                        tfLeft = unique(freqRanges{3}/2); tfRight = unique(freqRanges{4}/2);
                                    elseif iTF ==3
                                        tfLeft = unique(freqRanges{4}/2); tfRight = unique(freqRanges{3}/2);
                                    end
                                end
                            end

                            psdBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = tmpEBL;
                            psdST(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = tmpEST;
                            psdTG(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = tmpETG;
                            
                            for iFreqRange=1:length(freqRanges)
                                if iFreqRange == 3||iFreqRange == 4
                                    remove_NthHarmonicOnwards = 3;
                                else 
                                    remove_NthHarmonicOnwards = 2;
                                end
                                deltaF_LineNoise = 2; deltaF_tfHarmonics = 0;
                                badFreqPos = getBadFreqPos(freqVals,deltaF_LineNoise,deltaF_tfHarmonics,remove_NthHarmonicOnwards,tfLeft,tfRight);
                                powerValsBL{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{iFreqRange},badFreqPos);
                                powerValsST{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = getMeanEnergyForAnalysis(tmpEST,freqVals,freqRanges{iFreqRange},badFreqPos);
                                powerValsTG{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = getMeanEnergyForAnalysis(tmpETG,freqVals,freqRanges{iFreqRange},badFreqPos);
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
                           
                            psdBL_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = tmpEBL_avg;
                            psdST_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = tmpEST_avg;
                            psdTG_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = tmpETG_avg;
                            
                            for iFreqRange=1:length(freqRanges)
                                if iFreqRange == 3||iFreqRange == 4
                                    remove_NthHarmonicOnwards = 3;
                                else 
                                    remove_NthHarmonicOnwards = 2;
                                end
                                deltaF_LineNoise = 2; deltaF_tfHarmonics = 0;
                                badFreqPos = getBadFreqPos(freqVals,deltaF_LineNoise,deltaF_tfHarmonics,remove_NthHarmonicOnwards,tfLeft,tfRight);

                                powerValsBL_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = getMeanEnergyForAnalysis(tmpEBL_avg,freqVals,freqRanges{iFreqRange},badFreqPos);
                                powerValsST_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = getMeanEnergyForAnalysis(tmpEST_avg,freqVals,freqRanges{iFreqRange},badFreqPos);
                                powerValsTG_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = getMeanEnergyForAnalysis(tmpETG_avg,freqVals,freqRanges{iFreqRange},badFreqPos);
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
    badFreqs = [51:51:max(freqVals)];
    tfHarmonics1 = [remove_NthHarmonicOnwards*tfLeft:tfLeft:max(freqVals)]; % remove nth SSVEP harmonic and beyond
    tfHarmonics2 = [remove_NthHarmonicOnwards*tfRight:tfRight:max(freqVals)]; % remove nth SSVEP harmonic and beyond
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

function [contrastString,contrastCellArray] = getContrastString(cIndexValsUnique,stimResults) %#ok<*DEFNU>

contrastCellArray = [];
if isfield(stimResults,'contrast0PC')
    [cVals0Unique,cVals1Unique] = getValsFromIndex(cIndexValsUnique,stimResults,'contrast');
    if length(cVals0Unique)==1
        contrastCellArray{1} = [num2str(cVals0Unique) ',' num2str(cVals1Unique)];
        contrastString = contrastCellArray{1};
    else
        contrastString = '';
        for i=1:length(cVals0Unique)
            contrastCellArray{i} = [num2str(cVals0Unique(i)) ',' num2str(cVals1Unique(i))];
            contrastString = cat(2,contrastString,[contrastCellArray{i} '|']);
        end
        contrastString = [contrastString 'all'];
    end
    
else % Work with indices
    if length(cIndexValsUnique)==1
        if cIndexValsUnique ==0
            contrastString = '0';
        else
            contrastString = num2str(100/2^(7-cIndexValsUnique));
        end
        
    else
        contrastString = '';
        for i=1:length(cIndexValsUnique)
            if cIndexValsUnique(i) == 0
                contrastString = cat(2,contrastString,[ '0|']); %#ok<*NBRAK>
            else
                contrastString = cat(2,contrastString,[num2str(100/2^(7-cIndexValsUnique(i))) '|']);
            end
        end
        contrastString = [contrastString 'all'];
    end
end
end
function [temporalFreqString,temporalFreqCellArray] = getTemporalFreqString(tIndexValsUnique,stimResults)

temporalFreqCellArray = [];
if isfield(stimResults,'temporalFreq0Hz')
    [tVals0Unique,tVals1Unique] = getValsFromIndex(tIndexValsUnique,stimResults,'temporalFreq');
    if length(tIndexValsUnique)==1
        temporalFreqCellArray{1} = [num2str(tVals0Unique) ',' num2str(tVals1Unique)];
        temporalFreqString = temporalFreqCellArray{1};
    else
        temporalFreqString = '';
        for i=1:length(tIndexValsUnique)
            temporalFreqCellArray{i} = [num2str(tVals0Unique(i)) ',' num2str(tVals1Unique(i))]; %#ok<*AGROW>
            temporalFreqString = cat(2,temporalFreqString,[temporalFreqCellArray{i} '|']);
        end
        temporalFreqString = [temporalFreqString 'all'];
    end
else
    if length(tIndexValsUnique)==1
        if tIndexValsUnique ==0
            temporalFreqString = '0';
        else
            temporalFreqString = num2str(min(50,80/2^(7-tIndexValsUnique)));
        end
        
    else
        temporalFreqString = '';
        for i=1:length(tIndexValsUnique)
            if tIndexValsUnique(i) == 0
                temporalFreqString = cat(2,temporalFreqString,[ '0|']);
            else
                temporalFreqString = cat(2,temporalFreqString,[num2str(min(50,80/2^(7-tIndexValsUnique(i)))) '|']);
            end
        end
        temporalFreqString = [temporalFreqString 'all'];
    end
end
end


function outString = getStringFromValues(valsUnique,decimationFactor)

if length(valsUnique)==1
    outString = convertNumToStr(valsUnique(1),decimationFactor);
else
    outString='';
    for i=1:length(valsUnique)
        outString = cat(2,outString,[convertNumToStr(valsUnique(i),decimationFactor) '|']);
    end
    outString = [outString 'all'];
end

    function str = convertNumToStr(num,f)
        if num > 16384
            num=num-32768;
        end
        str = num2str(num/f);
    end
end

function EOTCodeString = getEOTCodeString(eValsUnique)

if length(eValsUnique)==1
    if eValsUnique == 0
        EOTCodeString = 'Correct';
    elseif eValsUnique == 1
        EOTCodeString = 'Wrong';
    elseif eValsUnique == 2
        EOTCodeString = 'Failed';
    elseif eValsUnique == 3
        EOTCodeString = 'Broke';
    elseif eValsUnique == 4
        EOTCodeString = 'Ignored';
    elseif eValsUnique == 5
        EOTCodeString = 'False Alarm';
    elseif eValsUnique == 6
        EOTCodeString = 'Distracted';
    elseif eValsUnique == 7
        EOTCodeString = 'Force Quit';
    else
        disp('Unknown EOT Code');
    end
else
    EOTCodeString = '';
    for i=1:length(eValsUnique)
        if eValsUnique(i) == 0
            EOTCodeString = cat(2,EOTCodeString,['Correct|']);
        elseif eValsUnique(i) == 1
            EOTCodeString = cat(2,EOTCodeString,['Wrong|']);
        elseif eValsUnique(i) == 2
            EOTCodeString = cat(2,EOTCodeString,['Failed|']);
        elseif eValsUnique(i) == 3
            EOTCodeString = cat(2,EOTCodeString,['Broke|']);
        elseif eValsUnique(i) == 4
            EOTCodeString = cat(2,EOTCodeString,['Ignored|']);
        elseif eValsUnique(i) == 5
            EOTCodeString = cat(2,EOTCodeString,['False Alarm|']);
        elseif eValsUnique(i) == 6
            EOTCodeString = cat(2,EOTCodeString,['Distracted|']);
        elseif eValsUnique(i) == 7
            EOTCodeString = cat(2,EOTCodeString,['Force Quit|']);
        else
            disp('Unknown EOT Code');
        end
    end
    EOTCodeString = [EOTCodeString 'all'];
end
end
function attendLocString = getAttendLocString(aValsUnique)

if length(aValsUnique)==1
    if aValsUnique == 0
        attendLocString = '0 (Right)';
    elseif aValsUnique == 1
        attendLocString = '1 (Left)';
    else
        disp('Unknown attended location');
    end
else
    attendLocString = '';
    for i=1:length(aValsUnique)
        if aValsUnique(i) == 0
            attendLocString = cat(2,attendLocString,['0 (Right)|']);
        elseif aValsUnique(i) == 1
            attendLocString = cat(2,attendLocString,['1 (Left)|']);
        else
            disp('Unknown attended location');
        end
    end
    attendLocString = [attendLocString 'Both'];
end
end
function stimTypeString = getStimTypeString(sValsUnique)

if length(sValsUnique)==1
    if sValsUnique == 0
        stimTypeString = 'Null';
    elseif sValsUnique == 1
        stimTypeString = 'Correct';
    elseif sValsUnique == 2
        stimTypeString = 'Target';
    elseif sValsUnique == 3
        stimTypeString = 'FrontPad';
    elseif sValsUnique == 4
        stimTypeString = 'BackPad';
    else
        disp('Unknown Stimulus Type');
    end
else
    stimTypeString = '';
    for i=1:length(sValsUnique)
        if sValsUnique(i) == 0
            stimTypeString = cat(2,stimTypeString,['Null|']);
        elseif sValsUnique(i) == 1
            stimTypeString = cat(2,stimTypeString,['Correct|']);
        elseif sValsUnique(i) == 2
            stimTypeString = cat(2,stimTypeString,['Target|']);
        elseif sValsUnique(i) == 3
            stimTypeString = cat(2,stimTypeString,['FrontPad|']);
        elseif sValsUnique(i) == 4
            stimTypeString = cat(2,stimTypeString,['BackPad|']);
        else
            disp('Unknown Stimulus Type');
        end
    end
    stimTypeString = [stimTypeString 'all'];
end

end
function [colorString, colorNames] = getColorString
colorNames = 'brkgcmy';
colorString = 'blue|red|black|green|cyan|magenta|yellow';
end
function [valList0Unique,valList1Unique] = getValsFromIndex(indexListUnique,stimResults,fieldName)
if isfield(stimResults,[fieldName 'Index'])
    
    indexList = getfield(stimResults,[fieldName 'Index']); %#ok<*GFLD>
    if strcmpi(fieldName,'contrast')
        valList0 = getfield(stimResults,[fieldName '0PC']);
        valList1 = getfield(stimResults,[fieldName '1PC']);
    else
        valList0 = getfield(stimResults,[fieldName '0Hz']);
        valList1 = getfield(stimResults,[fieldName '1Hz']);
    end
    
    numList = length(indexListUnique);
    valList0Unique = zeros(1,numList);
    valList1Unique = zeros(1,numList);
    for i=1:numList
        valList0Unique(i) = unique(valList0(indexListUnique(i)==indexList));
        valList1Unique(i) = unique(valList1(indexListUnique(i)==indexList));
    end
else
    valList0Unique = indexListUnique;
    valList1Unique = indexListUnique;
end
end

