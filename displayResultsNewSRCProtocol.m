function displayResultsNewSRCProtocol(subjectName,expDate,protocolName,folderSourceString,gridType)

close all;
if ~exist('folderSourceString','var');   folderSourceString ='E:';      end
if ~exist('gridType','var');             gridType='EEG';                end

folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName);

% Get folders
folderExtract = fullfile(folderName,'extractedData');
folderSegment = fullfile(folderName,'segmentedData');
folderLFP = fullfile(folderSegment,'LFP');



% Get Combinations
[parameterCombinations,~,tValsUnique,eValsUnique,aValsUnique,~] = loadParameterCombinations(folderExtract);

% Get properties of the Stimulus
% stimResults = loadStimResults(folderExtract);


% Electrode Info

% UnipolarEEGChannelLabels =    [P3     P1      P2      P4      PO3     POz     PO4     O1      Oz      O2];
% bipolarEEGChannelLabels1 =    [PO3    PO3     POz     PO4     PO4     POz     Oz      Oz      Oz]
% bipolarEEGChannelLabels2 =    [P1     P3      PO3     P2      P4      PO4     POz     O1      O2]

EEGChannelsLeft = [24 29 57 61];
EEGChannelsStored_Left{1} = EEGChannelsLeft;

bipolarEEGChannelsStored(1,:) = [61 61 12];
bipolarEEGChannelsStored(2,:) = [57  24 61];
EEGChannelsStored_Left{2} = bipolarEEGChannelsStored;

EEGChannelsRight = [26 31 58 63];
EEGChannelsStored_Right{1} = EEGChannelsRight;

bipolarEEGChannelsStored(1,:) = [63 63 62 ];
bipolarEEGChannelsStored(2,:) = [58 26 63 ];
EEGChannelsStored_Right{2} = bipolarEEGChannelsStored;

% load LFP/TimeVals Information
[~,timeVals,~] = loadlfpInfo(folderLFP);


% Set up timeRanges and timePos
blRange = [-0.5 0];
stRange = [0.25 0.75];
Fs = round(1/(timeVals(2)-timeVals(1)));
range = blRange;
rangePos = round(diff(range)*Fs);
blPos = find(timeVals>=blRange(1),1)+ (1:rangePos);
stPos = find(timeVals>=stRange(1),1)+ (1:rangePos);

% freq Ranges for power estimation in freq Bands
freqRanges{1} = [8 12]; % alpha
freqRanges{2} = [30 80]; % gamma
% freqRanges{3} = [104 248]; % hi-gamma
freqRanges{3} = [24 24];  % SSVEP
freqRanges{4} = [32 32];  % SSVEP
numFreqs = length(freqRanges);


% Set up params for MT
tapers_MT = [1 1];
params.tapers   = tapers_MT;
params.pad      = -1;
params.Fs       = Fs;
params.fpass    = [0 250];
params.trialave = 1;

% Set up movingWindow parameters for time-frequency plot
winSize = 0.1;
winStep = 0.025;
movingwin = [winSize winStep];

% Get bad trials
badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
if ~exist(badTrialFile,'file')
    disp('Bad trial file does not exist...');
    badTrials=[];
else
    disp(['Loading' badTrialFile])
    badTrials = loadBadTrials(badTrialFile);
    disp([num2str(length(badTrials)) ' bad trials']);
end

c = 1; s = 1; % Contrast and StimType Index are set as 1

% Main Loop (stores data in Elec x TF x EotCode (0- Correct,
% 2-Missed/Failed) x attend Loc (0-Right, 1-Left)



for iRefScheme = 1:2 % 1- Unipolar, 2- Bipolar
    for iSide = 1:2 % 1- Left Hemispheric EEG elecs, 2- Right Hemispheric EEG elecs
        clear electrodeList
        if iSide ==1
            electrodeList = EEGChannelsStored_Left;
        elseif iSide ==2
            electrodeList = EEGChannelsStored_Right;
        end
        for iElec = 1: size(electrodeList{iRefScheme},2)
            % Load analog Data according to Ref Scheme
            clear x
            if iRefScheme == 1
                clear x
                disp(['Processing Side no. ' num2str(iSide) ', unipolar electrode no. ' num2str(iElec) ': electrode ID: ' num2str(electrodeList{iRefScheme}(iElec))])
                x = load(fullfile(folderLFP,['elec' num2str(electrodeList{iRefScheme}(iElec)) '.mat']));
            elseif iRefScheme == 2
                clear x1 x2 x
                disp(['Processing Side no. ' num2str(iSide) ', bipolar electrode no. ' num2str(iElec) ': electrode ID: ' num2str(electrodeList{iRefScheme}(1,iElec)) ' - ' num2str(electrodeList{iRefScheme}(2,iElec))])
                x1 = load(fullfile(folderLFP,['elec' num2str(electrodeList{iRefScheme}(1,iElec)) '.mat']));
                x2 = load(fullfile(folderLFP,['elec' num2str(electrodeList{iRefScheme}(2,iElec)) '.mat']));
                x.analogData.stimOnset = x1.analogData.stimOnset-x2.analogData.stimOnset;
                x.analogData.targetOnset = x1.analogData.targetOnset-x2.analogData.targetOnset;
            end
            
            for iEOTCode = 1: length(eValsUnique)
                for iTF = 1: length(tValsUnique)
                    for iAttendLoc = 1: length(aValsUnique)
                        clear goodPos_stimOnset goodPos_targetOnset
                        goodPos_stimOnset = setdiff(parameterCombinations.stimOnset{c,iTF,iEOTCode,iAttendLoc,s},badTrials);
                        goodPos_targetOnset = setdiff(parameterCombinations.targetOnset{c,iTF,iEOTCode,iAttendLoc,s},badTrials);
                        
                        
                        if isempty(goodPos_stimOnset)
                            disp('No entries for this combination..')
                        else
                            disp([iEOTCode iTF iAttendLoc length(goodPos_stimOnset)])
                            if iRefScheme==1 && iElec ==1
                                trialNums(iEOTCode,iTF,iAttendLoc) = length(goodPos_stimOnset); 
                            end
                            
                            % Segmenting data according to timePos
                            dataBL = x.analogData.stimOnset(goodPos_stimOnset,blPos)';
                            dataStimOnset = x.analogData.stimOnset(goodPos_stimOnset,stPos)';
                            dataTargetOnset = x.analogData.targetOnset(goodPos_targetOnset,blPos)';
                            
                            % power spectral density estimation
                            [tmpEBL,freqValsBL] = mtspectrumc(dataBL,params);
                            [tmpEST,freqValsST] = mtspectrumc(dataStimOnset,params);
                            [tmpETG,freqValsTG] = mtspectrumc(dataTargetOnset,params);
                            
                            if isequal(freqValsBL,freqValsST) && isequal(freqValsBL,freqValsTG)
                                freqVals = freqValsBL;
                            end
                            
                            psdBL{iRefScheme}(iSide,iElec,iEOTCode,iTF,iAttendLoc,:) = conv2Log(tmpEBL);
                            psdST{iRefScheme}(iSide,iElec,iEOTCode,iTF,iAttendLoc,:) = conv2Log(tmpEST);
                            psdTG{iRefScheme}(iSide,iElec,iEOTCode,iTF,iAttendLoc,:) = conv2Log(tmpETG);
                            
                            % power estimation for different freq bands
                            if iTF ==1
                                for iFreqRange = 1:numFreqs-2
                                    energyValsBL{iRefScheme,iFreqRange}(iSide,iElec,iEOTCode,iTF,iAttendLoc) = conv2Log(getMeanEnergyForAnalysis(tmpEBL(:),freqVals,freqRanges{iFreqRange}));
                                    energyValsST{iRefScheme,iFreqRange}(iSide,iElec,iEOTCode,iTF,iAttendLoc) = conv2Log(getMeanEnergyForAnalysis(tmpEST(:),freqVals,freqRanges{iFreqRange}));
                                    energyValsTG{iRefScheme,iFreqRange}(iSide,iElec,iEOTCode,iTF,iAttendLoc) = conv2Log(getMeanEnergyForAnalysis(tmpETG(:),freqVals,freqRanges{iFreqRange}));
                                end
                            elseif iTF ==2
                                for iFreqRange = 3:4
                                    energyValsBL{iRefScheme,iFreqRange}(iSide,iElec,iEOTCode,iTF,iAttendLoc) = conv2Log(getMeanEnergyForAnalysis(tmpEBL(:),freqVals,freqRanges{iFreqRange}));
                                    energyValsST{iRefScheme,iFreqRange}(iSide,iElec,iEOTCode,iTF,iAttendLoc) = conv2Log(getMeanEnergyForAnalysis(tmpEST(:),freqVals,freqRanges{iFreqRange}));
                                    energyValsTG{iRefScheme,iFreqRange}(iSide,iElec,iEOTCode,iTF,iAttendLoc) = conv2Log(getMeanEnergyForAnalysis(tmpETG(:),freqVals,freqRanges{iFreqRange}));
                                end
                            end
                            
                            % computing TF spectrum by MT method
                            [tmpE_tfStim,tmpT_tfStim,freqVals_tfStim] = mtspecgramc(x.analogData.stimOnset(goodPos_stimOnset,:)',movingwin,params);
                            [tmpE_tfTarget,tmpT_tfTarget,freqVals_tfTarget] = mtspecgramc(x.analogData.targetOnset(goodPos_targetOnset,:)',movingwin,params);
                            
                            timeVals_tf= tmpT_tfStim + timeVals(1);
                            energy_tfStim = conv2Log(tmpE_tfStim)';
                            energy_tfTarget = conv2Log(tmpE_tfTarget)';
                            energyBL_tf = mean(energy_tfStim(:,timeVals_tf>=blRange(1)& timeVals_tf<=blRange(2)),2);
                            
                            mEnergy_tfStim{iRefScheme}(iSide,iElec,iEOTCode,iTF,iAttendLoc,:,:) = energy_tfStim;
                            mEnergy_tfTarget{iRefScheme}(iSide,iElec,iEOTCode,iTF,iAttendLoc,:,:) = energy_tfTarget;
                            mEnergyBL_tf{iRefScheme}(iSide,iElec,iEOTCode,iTF,iAttendLoc,:,:) = repmat(energyBL_tf,1,length(timeVals_tf));
                        end
                    end
                end
            end
        end
    end
end

% % Display Properties
% hFig = figure();
% set(hFig,'units','normalized','outerposition',[0 0 1 1])

% Plotting
attendColors = {'r', 'b'}; % r = Attend contralateral; b = Attend ipsilateral

% for iSide = 1:2
%     hFig = figure(iSide);
%     set(hFig,'units','normalized','outerposition',[0 0 1 1])
%     hPlotsFig.hPlot1 = getPlotHandles(2,3,[0.08 0.1 0.4 0.8],0.01,0.08,1);
%     hPlotsFig.hPlot2 = getPlotHandles(2,3,[0.55 0.1 0.4 0.8],0.01,0.08,1);
%
%
%     for iRefScheme = 1:2
%         for iTF = 1:length(tValsUnique)
%             for iAttendLoc = 1:length(aValsUnique)
%                 if iRefScheme ==1
%
% %                     figure(iSide)
%                     plot(hPlotsFig.hPlot1(1,iTF),freqVals,squeeze(mean(mean(psdBL{iRefScheme}(iSide,:,1,iTF,:,:),5),2)),'k','LineWidth',1.5);
%                     hold(hPlotsFig.hPlot1(1,iTF),'on')
%                     plot(hPlotsFig.hPlot1(1,iTF),freqVals,squeeze(mean(psdST{iRefScheme}(iSide,:,1,iTF,iAttendLoc,:),2)),attendColors{iAttendLoc},'LineWidth',1.5);
%
%                     plot(hPlotsFig.hPlot1(2,iTF),freqVals,squeeze(mean(mean(psdBL{iRefScheme}(iSide,:,1,iTF,:,:),5),2)),'k','LineWidth',1.5);
%                     hold(hPlotsFig.hPlot1(2,iTF),'on')
%                     plot(hPlotsFig.hPlot1(2,iTF),freqVals,squeeze(mean(psdTG{iRefScheme}(iSide,:,1,iTF,iAttendLoc,:),2)),attendColors{iAttendLoc},'LineWidth',1.5);
%
%                     xlim(hPlotsFig.hPlot1(1,iTF),[0 100]);
%                     xlim(hPlotsFig.hPlot1(2,iTF),[0 100]);
%                 elseif iRefScheme ==2
%
% %                     figure(iSide)
%                     plot(hPlotsFig.hPlot2(1,iTF),freqVals,squeeze(mean(mean(psdBL{iRefScheme}(iSide,:,1,iTF,:,:),5),2)),'k','LineWidth',1.5);
%                     hold(hPlotsFig.hPlot2(1,iTF),'on')
%
%                     plot(hPlotsFig.hPlot2(1,iTF),freqVals,squeeze(mean(psdST{iRefScheme}(iSide,:,1,iTF,iAttendLoc,:),2)),attendColors{iAttendLoc},'LineWidth',1.5);
%                     xlim(hPlotsFig.hPlot2(1,iTF),[0 100]);
%
%                     plot(hPlotsFig.hPlot2(2,iTF),freqVals,squeeze(mean(mean(psdBL{iRefScheme}(iSide,:,1,iTF,:,:),5),2)),'k','LineWidth',1.5);
%                     hold(hPlotsFig.hPlot2(2,iTF),'on')
%                     plot(hPlotsFig.hPlot2(2,iTF),freqVals,squeeze(mean(psdTG{iRefScheme}(iSide,:,1,iTF,iAttendLoc,:),2)),attendColors{iAttendLoc},'LineWidth',1.5);
%
%                     xlim(hPlotsFig.hPlot2(1,iTF),[0 100]);
%                     xlim(hPlotsFig.hPlot2(2,iTF),[0 100]);
%
%                 end
%             end
%         end
%     end
% end

% combine Sides
contralateralPSDBL = cell(1,2);
ipsilateralPSDBL = cell(1,2);
commonPSDBL = cell(1,2);
contralateralPSDST= cell(1,2);
ipsilateralPSDST= cell(1,2);
contralateralPSDTG= cell(1,2);
ipsilateralPSDTG= cell(1,2);

for i= 1:2
    contralateralPSDBL{i} = squeeze(cat(2,psdBL{i}(1,:,:,:,1,:),psdBL{i}(2,:,:,:,2,:)));
    ipsilateralPSDBL{i} = squeeze(cat(2,psdBL{i}(1,:,:,:,2,:),psdBL{i}(2,:,:,:,1,:)));
    commonPSDBL{i} = (contralateralPSDBL{i}+ ipsilateralPSDBL{i})/2;
    contralateralPSDST{i} = squeeze(cat(2,psdST{i}(1,:,:,:,1,:),psdST{i}(2,:,:,:,2,:)));
    ipsilateralPSDST{i} = squeeze(cat(2,psdST{i}(1,:,:,:,2,:),psdST{i}(2,:,:,:,1,:)));
    contralateralPSDTG{i} = squeeze(cat(2,psdTG{i}(1,:,:,:,1,:),psdTG{i}(2,:,:,:,2,:)));
    ipsilateralPSDTG{i} = squeeze(cat(2,psdTG{i}(1,:,:,:,2,:),psdTG{i}(2,:,:,:,1,:)));
end

fontSize = 14;




for iEOTCode = 1:2
    hFig = figure(iEOTCode);
    set(hFig,'units','normalized','outerposition',[0 0 1 1])
    hPlotsFig.hPlot1 = getPlotHandles(2,3,[0.08 0.1 0.4 0.8],0.01,0.01,1); % Hit
    hPlotsFig.hPlot2 = getPlotHandles(2,3,[0.55 0.1 0.4 0.8],0.01,0.01,1); % Miss
    if iEOTCode ==1
        tickLengthPlot = 2*get(hPlotsFig.hPlot1(1,1),'TickLength');
    end
    for iStimType = 1:2
        for iRefScheme = 1:2
            for iTF = 1:length(tValsUnique)
                
                if iStimType ==1
                    plot(hPlotsFig.hPlot1(iRefScheme,iTF),freqVals,squeeze(mean(commonPSDBL{iRefScheme}(:,iEOTCode,iTF,:),1)),'k','LineWidth',1.5);
                    hold(hPlotsFig.hPlot1(iRefScheme,iTF),'on')
                    plot(hPlotsFig.hPlot1(iRefScheme,iTF),freqVals,squeeze(mean(ipsilateralPSDST{iRefScheme}(:,iEOTCode,iTF,:),1)),attendColors{2},'LineWidth',1.5);
                    plot(hPlotsFig.hPlot1(iRefScheme,iTF),freqVals,squeeze(mean(contralateralPSDST{iRefScheme}(:,iEOTCode,iTF,:),1)),attendColors{1},'LineWidth',1.5);
                    
                    if iRefScheme == 1
                    text(0.6,0.7,['n_t = ' num2str(sum(trialNums(iEOTCode,iTF,:)))],'color',attendColors{2},'fontWeight','bold','fontSize',fontSize-2,'unit','normalized','parent',hPlotsFig.hPlot1(iRefScheme,iTF))
                    text(0.6,0.75,['n_t = ' num2str(sum(trialNums(iEOTCode,iTF,:)))],'color',attendColors{1},'fontWeight','bold','fontSize',fontSize-2,'unit','normalized','parent',hPlotsFig.hPlot1(iRefScheme,iTF))
                    text(0.6,0.8,['n_t = ' num2str(2*sum(trialNums(iEOTCode,iTF,:)))],'color','k','fontWeight','bold','fontSize',fontSize-2,'unit','normalized','parent',hPlotsFig.hPlot1(iRefScheme,iTF))
                    end
                    
                    text(0.6,0.9,['N = ' num2str(size(ipsilateralPSDST{iRefScheme},1))],'color','k','fontWeight','bold','fontSize',fontSize-2,'unit','normalized','parent',hPlotsFig.hPlot1(iRefScheme,iTF))

                    
                    set(hPlotsFig.hPlot1(iRefScheme,iTF),'fontSize',fontSize,'TickDir','out','Ticklength',tickLengthPlot,'box','off')
                    
                    xlim(hPlotsFig.hPlot1(1,iTF),[0 48]); ylim(hPlotsFig.hPlot1(1,iTF),[-3 3]);
                    xlim(hPlotsFig.hPlot1(2,iTF),[0 48]); ylim(hPlotsFig.hPlot1(2,iTF),[-3 3]);
                    
                    
                    
                elseif iStimType ==2
                    plot(hPlotsFig.hPlot2(iRefScheme,iTF),freqVals,squeeze(mean(commonPSDBL{iRefScheme}(:,iEOTCode,iTF,:),1)),'k','LineWidth',1.5);
                    hold(hPlotsFig.hPlot2(iRefScheme,iTF),'on')
                    plot(hPlotsFig.hPlot2(iRefScheme,iTF),freqVals,squeeze(mean(ipsilateralPSDTG{iRefScheme}(:,iEOTCode,iTF,:),1)),attendColors{2},'LineWidth',1.5);
                    plot(hPlotsFig.hPlot2(iRefScheme,iTF),freqVals,squeeze(mean(contralateralPSDTG{iRefScheme}(:,iEOTCode,iTF,:),1)),attendColors{1},'LineWidth',1.5);
                    
                    set(hPlotsFig.hPlot2(iRefScheme,iTF),'fontSize',fontSize,'TickDir','out','Ticklength',tickLengthPlot,'box','off')
                    
                    xlim(hPlotsFig.hPlot2(1,iTF),[0 48]); ylim(hPlotsFig.hPlot2(1,iTF),[-3 3]);
                    xlim(hPlotsFig.hPlot2(2,iTF),[0 48]); ylim(hPlotsFig.hPlot2(2,iTF),[-3 3]);
                    
                end
                
                if iRefScheme == 1
                    if iTF == 1
                        title(hPlotsFig.hPlot1(iRefScheme,iTF),'TF: 0 Hz')
                        title(hPlotsFig.hPlot2(iRefScheme,iTF),'TF: 0 Hz')
                        
                        
                    elseif iTF == 2
                        title(hPlotsFig.hPlot1(iRefScheme,iTF),'TF: 12 Hz')
                        title(hPlotsFig.hPlot2(iRefScheme,iTF),'TF: 12 Hz')
                        
                    elseif iTF == 3
                        title(hPlotsFig.hPlot1(iRefScheme,iTF),'TF: 16 Hz')
                        title(hPlotsFig.hPlot2(iRefScheme,iTF),'TF: 16 Hz')
                        
                    end
                end
                
            end
        end
    end
    xlabel(hPlotsFig.hPlot1(2,1),'Frequency (Hz)'); ylabel(hPlotsFig.hPlot1(2,1),'[log_1_0 (Power (\muV^2)]');
    xlabel(hPlotsFig.hPlot2(2,1),'Frequency (Hz)'); ylabel(hPlotsFig.hPlot2(2,1),'[log_1_0 (Power (\muV^2)]');
    rescaleData(hPlotsFig.hPlot1,0,48,getYLims(hPlotsFig.hPlot1),fontSize);
    rescaleData(hPlotsFig.hPlot2,0,48,getYLims(hPlotsFig.hPlot2),fontSize);
    
    textH{1} = getPlotHandles(1,1,[0.015 0.6 0.01 0.01]);
    textH{2} = getPlotHandles(1,1,[0.015 0.25 0.01 0.01]);
    textH{3} = getPlotHandles(1,1,[0.22 0.95 0.01 0.01]);
    textH{4} = getPlotHandles(1,1,[0.7 0.95 0.01 0.01]);
    textString = {'Unipolar','Bipolar','Stimulus Onset','Target Onset'};
    for i = 1:4
        set(textH{i},'Visible','Off')
        if i==1 || i==2
            text(0.35,1.15,textString{i},'unit','normalized','fontsize',20,'fontweight','bold','Rotation',90,'parent',textH{i});
        else
            text(0.35,1.15,textString{i},'unit','normalized','fontsize',20,'fontweight','bold','parent',textH{i});
        end
    end
    
    textH2 = getPlotHandles(1,1,[0.015 0.95 0.01 0.01]);
    if iEOTCode ==1
        textString2 = 'Correct Trials';
        
    elseif iEOTCode ==2
        textString2 = 'Missed Trials';
    end
    set(textH2,'Visible','Off')
    text(0.35,1.15,textString2,'unit','normalized','fontsize',20,'fontweight','bold','parent',textH2);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        attendLocString = '0 (outside)';
    elseif aValsUnique == 1
        attendLocString = '1 (inside)';
    else
        disp('Unknown attended location');
    end
else
    attendLocString = '';
    for i=1:length(aValsUnique)
        if aValsUnique(i) == 0
            attendLocString = cat(2,attendLocString,['0 (outside)|']);
        elseif aValsUnique(i) == 1
            attendLocString = cat(2,attendLocString,['1 (inside)|']);
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%c%%%%%%%%%
function [analogChannelsStored,timeVals,goodStimPos] = loadlfpInfo(folderLFP) %#ok<*STOUT>
load(fullfile(folderLFP,'lfpInfo'));
end
function [parameterCombinations,cValsUnique,tValsUnique,eValsUnique,...
    aValsUnique,sValsUnique] = loadParameterCombinations(folderExtract)

load(fullfile(folderExtract,'parameterCombinations.mat'));
end
function stimResults = loadStimResults(folderExtract)
load (fullfile(folderExtract,'stimResults'));
end
function goodStimNums =loadGoodStimNums(folderExtract)
load(fullfile(folderExtract,'goodStimNums'));
end

% Get MeanEnergy for different frequency bands
function eValue = getMeanEnergyForAnalysis(mEnergy,freq,freqRange)

posToAverage = intersect(find(freq>=freqRange(1)),find(freq<=freqRange(2)));
eValue   = mean(mEnergy(posToAverage));
end

% Get Bad Trials
function badTrials = loadBadTrials(badTrialFile)
load(badTrialFile);
end

% Draw lines for timeTange or FreqRange
function displayRange(plotHandles,range,yLims,colorName,lineStyle)
[nX,nY] = size(plotHandles);
%yLims = getYLims(plotHandles);
if ~exist('lineStyle','var')
    lineStyle = 'solid-solid';
end
yVals = yLims(1):(yLims(2)-yLims(1))/100:yLims(2);
xVals1 = range(1) + zeros(1,length(yVals));
xVals2 = range(2) + zeros(1,length(yVals));

for i=1:nX
    for j=1:nY
        hold(plotHandles(i,j),'on');
        if strcmp(lineStyle,'solid-solid')
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineWidth',1.5);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineWidth',1.5);
        elseif strcmp(lineStyle,'solid-dash')
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineWidth',1.5);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineStyle','--','LineWidth',1.5);
        end
    end
end
end

% get Y limits for an axis
function yLims = getYLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
yMin = inf;
yMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        axis(plotHandles(row,column),'tight');
        tmpAxisVals = axis(plotHandles(row,column));
        if tmpAxisVals(3) < yMin
            yMin = tmpAxisVals(3);
        end
        if tmpAxisVals(4) > yMax
            yMax = tmpAxisVals(4);
        end
    end
end

yLims=[yMin yMax];
end

% Rescale data
function rescaleData(plotHandles,xMin,xMax,yLims,labelSize)

[numRows,numCols] = size(plotHandles);
% labelSize=14;
for i=1:numRows
    for j=1:numCols
        hold(plotHandles(i,j),'on');
        axis(plotHandles(i,j),[xMin xMax yLims]);
        if (i==numRows && rem(j,2)==1)
            if j==1
                set(plotHandles(i,j),'fontSize',labelSize);
            elseif j~=1
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            end
        elseif (rem(i,2)==0 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==0 && j~=1)
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==1 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==1 && j~=1)
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        else
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        end
    end
end

% Remove Labels on the four corners
%set(plotHandles(1,1),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(1,numCols),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(numRows,1),'XTickLabel',[],'YTickLabel',[]);
%set(plotHandles(numRows,numCols),'XTickLabel',[],'YTickLabel',[]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

