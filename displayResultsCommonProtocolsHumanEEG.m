% This program displays PSDs of Eyes Open vs Eyes Closed, SSVEP PSD, and
% PSDs for each SF and Ori conditions set in a GRF protocol 
% for Unipolar (Figure 1) and Bipolar Referencing (Figure 2)
% It has an additional option to plot difference in PSDs.

function displayResultsCommonProtocolsHumanEEG(subjectName,expDate,protocolIDs,gridType,folderSourceString,noInterStimFlag,analysisType,tapers_MT,plotPSDFlag,plotdPSDFlag)

if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='Microelectrode';      end
% if ~exist('gridLayout','var');          gridLayout=6;                   end

close all; % close any open figure in MATLAB

[~,expDates_all,protocolNames_all,~,deviceNames,capLayouts] = allCommonProtocolsHumanEEG;

% protocolIDs are arranged as
% 1- Eyes Open,
% 2- Eyes Closed,
% 3- SF-Ori GRF Protocol
expDates = expDates_all(protocolIDs);
protocolNames = protocolNames_all(protocolIDs);
deviceName = deviceNames(protocolIDs(end));
capLayout = capLayouts(protocolIDs(end));

% freq Ranges for power estimation in freq Bands
freqRanges{1} = [8 12]; % alpha
freqRanges{2} = [20 34]; % slow gamma
freqRanges{3} = [36 66]; % fast gamma
freqRanges{4} = [20 66]; % slow+ fast gamma
freqRanges{5} = [104 248]; % hi-gamma
freqRanges{6} = [32 32];  % SSVEP
numFreqs = length(freqRanges);
freqLims = [0 100];

% SF-Ori GRF Protocol

for iRefScheme = 1:2
  clear powerValsBL powerValsST  
    folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDates{3},protocolNames{3});
    folderExtract= fullfile(folderName,'extractedData');
    folderSegment= fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderName,'segmentedData','LFP');
    load(fullfile(folderLFP,'lfpInfo.mat')); %#ok<*LOAD>
    
    % load Parameter Combinations for SF-Ori Protocols
    [parameterCombinations,~,~,~,fValsUnique,oValsUnique,~,tValsUnique] = loadParameterCombinations(folderExtract,[]);
    
    % Display Properties
    hFig = figure(iRefScheme);
    set(hFig,'units','normalized','outerposition',[0 0 1 1])
    hPlotsFig.hPlot1 = getPlotHandles(2,1,[0.1 0.1 0.3 0.8],0.01,0.06,1);
    hPlotsFig.hPlot2 = getPlotHandles(length(fValsUnique)+1,length(oValsUnique)+1,[0.5 0.1 0.45 0.8],0.01,0.01,1); linkaxes(hPlotsFig.hPlot2)
    
    blRange = [-0.5 0];
    stRange = [0.25 0.75];
    Fs = round(1/(timeVals(2)-timeVals(1)));
    if round(diff(blRange)*Fs) ~= round(diff(stRange)*Fs)
        disp('baseline and stimulus ranges are not the same');
    else
        range = blRange;
        rangePos = round(diff(range)*Fs);
        blPos = find(timeVals>=blRange(1),1)+ (1:rangePos);
        stPos = find(timeVals>=stRange(1),1)+ (1:rangePos);
    end
    
    [parameterCombinations,~,~,~,...
        fValsUnique,oValsUnique,~,tValsUnique] = loadParameterCombinations(folderExtract,[]); %#ok<*ASGLU>
    a=1; e=1; s=1; c =1; t=1;
    
    % Get bad trials
    badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
    if ~exist(badTrialFile,'file')
        disp('Bad trial file does not exist...');
        badElecs = []; badTrials=[];
    else
        [badTrials,badElecs] = loadBadTrials(badTrialFile);
        badElecsAll = unique([badElecs.badImpedanceElecs; badElecs.noisyElecs; badElecs.flatPSDElecs]);
        disp([num2str(length(badTrials)) ' bad trials']);
        disp([num2str(length(badElecsAll)) ' bad elecs']);
    end
    
        % Get High-priority electrodes    
        photoDiodeIDs = [65 66];
        unipolarEEGChannelsStored = setdiff(analogChannelsStored,photoDiodeIDs);
        
        % 64-Channel Standard Acticap Layout
        % UnipolarEEGChannelLabels =    [P3     P1      P2      P4      PO3     POz     PO4     O1      Oz      O2];
        EEGChannelsStored{1} =          [24     57      58      26      61      62      63      29      30      31]; % Unipolar Electrodes
        % (This numbers can also be verified from  in CommonPrograms\ReadMontages\getHighPriorityElectrodes)
        
        % bipolarEEGChannelLabels1 =    [PO3    PO3     POz     PO4     PO4     POz     Oz      Oz      Oz]
        % bipolarEEGChannelLabels2 =    [P1     P3      PO3     P2      P4      PO4     POz     O1      O2]
        bipolarEEGChannelsStored(1,:) = [61     61      62      63      63      62      30      30      30];
        bipolarEEGChannelsStored(2,:) = [57     24      61      58      26      63      62      29      31];
        EEGChannelsStored{2} = bipolarEEGChannelsStored;% Bipolar Electrodes
        
    EEGChannelsStored{1} = setdiff(EEGChannelsStored{1},badElecsAll);% Unipolar Electrodes
    badIDs = [];
    for i= 1:length(badElecsAll)
        badIDs = unique(cat(2,badIDs,find(badElecsAll(i) == bipolarEEGChannelsStored(1,:) | badElecsAll(i) == bipolarEEGChannelsStored(2,:))));
    end
    bipolarEEGChannelsStored(:,badIDs) = [];
    EEGChannelsStored{2} = bipolarEEGChannelsStored;% Bipolar Electrodes
    
    clear fftBL fftST psdBL psdST dataBL dataST
    for iElec = 1:size(EEGChannelsStored{iRefScheme},2)
        clear x
        if iRefScheme == 1
            clear x
            disp(['Processing electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(iElec))])
            x = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(iElec)) '.mat']));
        elseif iRefScheme == 2
            clear x1 x2 x
            disp(['Processing bipolar electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) ' - ' num2str(EEGChannelsStored{iRefScheme}(2,iElec))])
            x1 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) '.mat']));
            x2 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(2,iElec)) '.mat']));
            x.analogData = x1.analogData-x2.analogData;
        end
        
        % loop for parameter combinations
        for iTF = 1:length(tValsUnique)
            for iSF = 1:length(fValsUnique)
                for iOri = 1:length(oValsUnique)
                    clear goodPos
                    goodPos = parameterCombinations{a,e,s,iSF,iOri,c,iTF};
                    goodPos = setdiff(goodPos,badTrials);
                    
                    if noInterStimFlag
                        goodPosBL = findGoodPosBL(subjectName,expDates{3},protocolNames{3},gridType,folderSourceString);
                        goodPosBL = setdiff(goodPosBL,badTrials);
                        disp(['Baseline trials = ' num2str(length(goodPosBL))]);

                    end
                    
                    
                    if isempty(goodPos)
                        disp(['No entries for this combination.. SF == ' num2str(iSF) ' TF==' num2str(iOri)]);
                    else
                        
                        if strcmp(analysisType,'FFT')
                            if noInterStimFlag
                            fftBL(iElec,iTF,iSF,iOri,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPosBL,blPos),[],2))))); %#ok<*NASGU,*AGROW>
                            else
                            fftBL(iElec,iTF,iSF,iOri,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,blPos),[],2))))); %#ok<*NASGU,*AGROW>
                            end
                            fftST(iElec,iTF,iSF,iOri,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,stPos),[],2)))));

                            freqVals = 0:1/diff(range):Fs-1/diff(range);
                            
                            
                        elseif strcmp(analysisType,'MT')
                            % Set up params for MT
                            params.tapers   = tapers_MT;
                            params.pad      = -1;
                            params.Fs       = Fs;
                            params.fpass    = [0 250];
                            params.trialave = 1;
                
                            % Set up movingWindow parameters for time-frequency plot
                            winSize = 0.1;
                            winStep = 0.025;
                            movingwin = [winSize winStep];
                            
                            % power spectral density estimation
                            if noInterStimFlag
                                [tmpEBL,freqValsBL] = mtspectrumc(x.analogData(goodPosBL,blPos)',params);
                            else
                                [tmpEBL,freqValsBL] = mtspectrumc(x.analogData(goodPos,blPos)',params);
                            end
                            
                            [tmpEST,freqValsST] = mtspectrumc(x.analogData(goodPos,stPos)',params);
                            if isequal(freqValsBL,freqValsST)
                                freqVals = freqValsST;
                            end
                            psdBL(iElec,iTF,iSF,iOri,:) = conv2Log(tmpEBL);
                            psdST(iElec,iTF,iSF,iOri,:) = conv2Log(tmpEST);
                            
                            % power estimation for different freq bands
                            for iFreqRange = 1:numFreqs
                                powerValsBL{iFreqRange}(iElec,iTF,iSF,iOri) = conv2Log(getMeanEnergyForAnalysis(tmpEBL(:),freqVals,freqRanges{iFreqRange}));
                                powerValsST{iFreqRange}(iElec,iTF,iSF,iOri) = conv2Log(getMeanEnergyForAnalysis(tmpEST(:),freqVals,freqRanges{iFreqRange}));
                            end
                            
                            % computing TF spectrum by MT method
                            [tmpE_tf,tmpT_tf,freqVals_tf] = mtspecgramc(x.analogData(goodPos,:)',movingwin,params);
                            timeVals_tf= tmpT_tf + timeVals(1);
                            energy_tf = conv2Log(tmpE_tf)';
                            
                            if noInterStimFlag
                                
                                [tmpEBL_tf,tmpTBL_tf,freqVals_tf] = mtspecgramc(x.analogData(goodPosBL,:)',movingwin,params);
                                timeValsBL_tf= tmpTBL_tf + timeVals(1);
                                energyGoodBLPos_tf = conv2Log(tmpEBL_tf)';
                                energyBL_tf = mean(energyGoodBLPos_tf(:,timeValsBL_tf>=blRange(1)& timeValsBL_tf<=blRange(2)),2);
                                
                            else
                                energyBL_tf = mean(energy_tf(:,timeVals_tf>=blRange(1)& timeVals_tf<=blRange(2)),2);
                            end
                            
                            mEnergy_tf(iElec,iTF,iSF,iOri,:,:) = energy_tf;
                            mEnergyBL_tf(iElec,iTF,iSF,iOri,:,:) = repmat(energyBL_tf,1,length(timeVals_tf));
                            
                        end
                    end
                end
            end
        end
    end
    
    if strcmp(analysisType,'FFT')
        fftBL_all{iRefScheme} = fftBL;
        fftST_all{iRefScheme} = fftST;
    elseif strcmp(analysisType,'MT')
        psdBL_all{iRefScheme} = psdBL;
        psdST_all{iRefScheme} = psdST;
    end
    
    % PSD plot for flickering stimuli
    if ~noInterStimFlag 
        if strcmp(analysisType,'FFT')
            dataBL_flicker = squeeze(mean(mean(mean(squeeze(fftBL(:,2,:,:,:)),3),2),1)); % common Baseline across all TFs
            dataST_flicker = squeeze(mean(mean(mean(squeeze(fftST(:,2,:,:,:)),3),2),1));
            
            plot(hPlotsFig.hPlot1(2),freqVals,dataBL_flicker,'-g','LineWidth',1.5); hold(hPlotsFig.hPlot1(2),'on');
            plot(hPlotsFig.hPlot1(2),freqVals,dataST_flicker,'-k','LineWidth',1.5);
            
        elseif strcmp(analysisType,'MT')
            dataBL_flicker = squeeze(mean(mean(mean(squeeze(psdBL(:,2,:,:,:)),3),2),1)); % common Baseline across all TFs
            dataST_flicker = squeeze(mean(mean(mean(squeeze(psdST(:,2,:,:,:)),3),2),1));
            
            if plotPSDFlag
                plot(hPlotsFig.hPlot1(2),freqVals,dataBL_flicker,'-g','LineWidth',1.5); hold(hPlotsFig.hPlot1(2),'on');
                plot(hPlotsFig.hPlot1(2),freqVals,dataST_flicker,'-k','LineWidth',1.5);
            end
            if plotdPSDFlag
                plot(hPlotsFig.hPlot1(2),freqVals,10*(dataBL_flicker-dataBL_flicker),'-k','LineWidth',1.5);hold(hPlotsFig.hPlot1(2),'on')
                plot(hPlotsFig.hPlot1(2),freqVals,10*(dataST_flicker-dataBL_flicker),'-b','LineWidth',1.5);
            end
        end
    end
    
    % PSD plots for static stimuli
    
    if strcmp(analysisType,'FFT')
        dataBL = squeeze(mean(mean(mean(squeeze(fftBL(:,1,:,:,:)),3),2),1)); % common Baseline across all TFs
        dataST = squeeze(mean(squeeze(fftST(:,1,:,:,:)),1));
    elseif strcmp(analysisType,'MT')
        dataBL = squeeze(mean(mean(mean(squeeze(psdBL(:,1,:,:,:)),3),2),1)); % common Baseline across all TFs
        dataST = squeeze(mean(squeeze(psdST(:,1,:,:,:)),1));
    end
    
    colors = [0, 0.4470,0.7410;... % Dark Sky Blue
        0,  0.75, 0.75;...    %  Teal
        0.9290, 0.6940, 0.1250;... % Yellow Ochre
        0.6350 0.0780, 0.1840]; % Burgandy %jet(length(oValsUnique));
    
    % PSDs for different SF and Oris
    for iSF =1:length(fValsUnique)
        for iOri=1:length(oValsUnique)
            if plotPSDFlag
                plot(hPlotsFig.hPlot2(iSF,iOri),freqVals,dataBL,'-k','LineWidth',1.5); hold(hPlotsFig.hPlot2(iSF,iOri),'on');
                plot(hPlotsFig.hPlot2(iSF,iOri),freqVals,squeeze(dataST(iSF,iOri,:)),'color',colors(iOri,:,:),'LineWidth',1.5);
            end
            if strcmp(analysisType,'MT') && plotdPSDFlag
                plot(hPlotsFig.hPlot2(iSF,iOri),freqVals,10*(squeeze(dataBL-dataBL)),'-k','LineWidth',1.5);hold(hPlotsFig.hPlot2(iSF,iOri),'on');
                plot(hPlotsFig.hPlot2(iSF,iOri),freqVals,10*(squeeze(dataST(iSF,iOri,:))-dataBL),'-b','LineWidth',1.5);
                for i=1:numFreqs-2
                    textString = {'\alpha','SG','FG','\gamma'};
                    powerValsCommonBL = mean(mean(mean(squeeze(powerValsBL{i}(:,1,:,:)),3),2),1);
                    deltapowerValsTMP = 10*(squeeze(mean(powerValsST{i}(:,1,iSF,iOri),1)) - powerValsCommonBL);
                    text(0.5,0.4-0.07*i,[textString{i} ' = ' num2str(round(deltapowerValsTMP,2))],'unit','normalized','fontsize',10,'fontweight','bold','parent',hPlotsFig.hPlot2(iSF,iOri));
                end
            end
            xlim(hPlotsFig.hPlot2(iSF,iOri),freqLims);
        end
    end
    
    % PSDs for different Oris averaged across SFs (Bottom row)
    mSF_dataST = squeeze(mean(dataST,1));
    for iOri=1:length(oValsUnique)
        if plotPSDFlag
            plot(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),freqVals,dataBL,'-k','LineWidth',1.5); hold(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),'on');
            plot(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),freqVals,mSF_dataST(iOri,:),'color',[0.5 0 0.5],'LineWidth',1.5);
        end
        if strcmp(analysisType,'MT') && plotdPSDFlag
            plot(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),freqVals,10*(dataBL-dataBL),'-k','LineWidth',1.5);hold(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),'on');
            plot(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),freqVals,10*(squeeze(mSF_dataST(iOri,:))'-dataBL),'-b','LineWidth',1.5);
        end
        xlim(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),freqLims);
    end
    
    % PSDs for different SFs averaged across Oris (Rightmost column)
    mOri_dataST = squeeze(mean(dataST,2));
    for iSF=1:length(fValsUnique)
        if plotPSDFlag
            plot(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),freqVals,dataBL,'-k','LineWidth',1.5); hold(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),'on');
            plot(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),freqVals,mOri_dataST(iSF,:),'color','m','LineWidth',1.5);
        end
        if strcmp(analysisType,'MT') && plotdPSDFlag
            plot(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),freqVals,10*(dataBL-dataBL),'color','b','LineWidth',1.5);hold(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),'on');
            plot(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),freqVals,10*(squeeze(mOri_dataST(iSF,:))'-dataBL),'color','b','LineWidth',1.5);
        end
        xlim(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),freqLims);
    end
    
    % PSDs averaged across SFs and Oris (bottom row, rightmost panel)
    mSF_Ori_dataST = squeeze(mean(mean(dataST,2),1));
    if plotPSDFlag
        plot(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),freqVals,dataBL,'-k','LineWidth',1.5); hold(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),'on');
        plot(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),freqVals,mSF_Ori_dataST,'color',[ 0.9100 0.4100 0.1700],'LineWidth',1.5);
    end
    if strcmp(analysisType,'MT') && plotdPSDFlag
        plot(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),freqVals,10*(dataBL-dataBL),'b','LineWidth',1.5);hold(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),'on');
        plot(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),freqVals,10*(mSF_Ori_dataST-dataBL),'b','LineWidth',1.5);
    end
    xlim(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),freqLims);
    ylim(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),[-3 3]);
    
    % Load and Plot Reference data from Murty et al. 2020, NeuroImage, Figure 1
%     clear refData
%     if iRefScheme == 1
%         refData = load('C:\Users\RayLabPC-Aritra\Dropbox\Lab Workbench\Projects\Aritra_AttentionEEGProject\001MS_F1\rawAnalysis_unipolar.mat');
%     elseif iRefScheme == 2
%         refData = load('C:\Users\RayLabPC-Aritra\Dropbox\Lab Workbench\Projects\Aritra_AttentionEEGProject\001MS_F1\rawAnalysis_bipolar.mat');
%     end
%     
%     % Take mean across all electrodes
%     stPowerVsFreqSF_Ori = mean(refData.stPowerVsFreqSF_Ori,1);
%     blPowerVsFreqSF_Ori = mean(refData.blPowerVsFreqSF_Ori,1);
%     
%     % Plot raw PSDs
%     stPvsF = log10(stPowerVsFreqSF_Ori);
%     blPvsF = log10(blPowerVsFreqSF_Ori);
%     diffPvsF = 10*(stPvsF-blPvsF);
%     ax1 = subplot(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1)); hold on;
%     
%     if plotPSDFlag
%         plot(refData.freqValsSF_Ori,stPvsF,'k','LineWidth',1.5); hold on;
%         plot(refData.freqValsSF_Ori,blPvsF,'--k','LineWidth',1.5);
%     end
%     
%     if plotdPSDFlag
%         ax2 = axes('position',ax1.Position,'YAxisLocation','right','Color','none','nextplot','add');
%         subplot(ax2); hold on;
%         plot(refData.freqValsSF_Ori,diffPvsF,'b','LineWidth',1.5);
%         xlim(ax2,freqLims);
%         ax2.XTick = []; ax2.XTickLabel = []; ax2.FontSize = 14;
%     end
    
    
    % display PSDs for Eyes-open and Eyes-Closed Protocol
    for iProt = 1:2
        clear unipolarEEGChannelsStored bipolarEEGChannelsStored
        folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDates{iProt},protocolNames{iProt});
        folderLFP = fullfile(folderName,'segmentedData','LFP');
        load(fullfile(folderLFP,'lfpInfo.mat')); %#ok<*LOAD>

        
        for iElec = 1:size(EEGChannelsStored{iRefScheme},2)
            clear x
            if iRefScheme == 1
                clear x
                disp(['Processing electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(iElec))])
                x = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(iElec)) '.mat']));
            elseif iRefScheme == 2
                clear x1 x2 x
                disp(['Processing bipolar electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) ' - ' num2str(EEGChannelsStored{iRefScheme}(2,iElec))])
                x1 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) '.mat']));
                x2 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(2,iElec)) '.mat']));
                x.analogData = x1.analogData-x2.analogData;
            end
            T = 1.000;
            Fs = round(1/(timeVals(2)-timeVals(1)));
            freqLims = [0 100];
            
            if strcmp(analysisType,'FFT')
                freqVals = 0:1/T:Fs-1/T;
                fftSignal(iElec,:) = mean(log10(abs(fft(x.analogData,[],2)))); % mean across trials
                
            elseif strcmp(analysisType,'MT')
                % Set up params for MT
                params.tapers   = tapers_MT;
                params.pad      = -1;
                params.Fs       = Fs;
                params.fpass    = [0 250];
                params.trialave = 1;
                
                % Set up movingWindow parameters for time-frequency plot
                winSize = 0.1;
                winStep = 0.025;
                movingwin = [winSize winStep];
                
                [tmpESignal,freqVals] = mtspectrumc(x.analogData',params);
                psdSignal(iElec,:) = conv2Log(tmpESignal);
            end
        end
        
        
        % plotting
        if strcmp(analysisType,'FFT')
            if iProt ==1 % Eyes Open
                plot(hPlotsFig.hPlot1(1),freqVals,squeeze(mean(fftSignal,1)),'-k','LineWidth',1.5); hold(hPlotsFig.hPlot1(1),'on');
            elseif iProt ==2 % Eyes Closed
                plot(hPlotsFig.hPlot1(1),freqVals,squeeze(mean(fftSignal,1)),'-g','LineWidth',1.5);
            end
        elseif strcmp(analysisType,'MT')
            psdVals(iProt,:) = squeeze(mean(psdSignal,1));
            if iProt ==1 % Eyes Open
                if plotPSDFlag
                    plot(hPlotsFig.hPlot1(1),freqVals,squeeze(mean(psdSignal,1)),'-k','LineWidth',1.5); hold(hPlotsFig.hPlot1(1),'on');
                end
            elseif iProt ==2 % Eyes Closed
                if plotPSDFlag
                    plot(hPlotsFig.hPlot1(1),freqVals,squeeze(mean(psdSignal,1)),'-g','LineWidth',1.5);
                end
                if plotdPSDFlag
                    plot(hPlotsFig.hPlot1(1),freqVals,10*(psdVals(1,:)-psdVals(1,:)),'-k','LineWidth',1.5); hold(hPlotsFig.hPlot1(1),'on')
                    plot(hPlotsFig.hPlot1(1),freqVals,10*(psdVals(1,:)-psdVals(2,:)),'-b','LineWidth',1.5);
                end
            end
        end
    end
    
    xlim(hPlotsFig.hPlot1(1),freqLims);
    
    
    % Setting Plot Labels, titles and Legends
    title(hPlotsFig.hPlot1(1),'Eyes Open vs. Eyes Closed')
    title(hPlotsFig.hPlot1(2),'PSD for SSVEP Signal')
    xlabel(hPlotsFig.hPlot1(2),'Frequency (Hz)')
    xlabel(hPlotsFig.hPlot2(end,1),'Frequency (Hz)')
    if strcmp(analysisType,'FFT')
        ylabel(hPlotsFig.hPlot1(2),'log_1_0 (FFT Amplitude (\muV))')
    elseif strcmp(analysisType,'MT')
        ylabel(hPlotsFig.hPlot1(2),'log_1_0 (Power(\muV^2))')
    end
    
    
    tickLength = 2*get(hPlotsFig.hPlot1(1,1),'TickLength');
    set(hPlotsFig.hPlot1,'box','off','TickDir','out','TickLength',tickLength)
    set(hPlotsFig.hPlot2,'box','off','TickDir','out','TickLength',2*tickLength)
    
    
    for iOri = 1:length(oValsUnique)+1
        if iOri ~= length(oValsUnique)+1
            oVals{iOri} = [num2str(oValsUnique(iOri)) char(176)];
        else
            oVals{iOri} = 'all Ori';
        end
    end
    
    for iSF = 1:length(fValsUnique)+1
        if iSF ~= length(fValsUnique)+1
            sfVals{iSF} = [num2str(fValsUnique(iSF)) ' cpd'];
        else
            sfVals{iSF} = 'all SF';
        end
    end
    
    for i= 1:length(oVals)
        title(hPlotsFig.hPlot2(1,i),oVals{i})
    end
    
    for i= 1:length(sfVals)
        ylabel(hPlotsFig.hPlot2(i,1),sfVals{i},'fontWeight','bold')
    end
    
    textH = getPlotHandles(1,1,[0.35 0.97 0.01 0.01]);
    if iRefScheme == 1
        textString = [subjectName expDate ' : Unipolar Referencing Scheme'];
    elseif iRefScheme == 2
        textString = [subjectName expDate ' : Bipolar Referencing Scheme'];
    end
    set(textH,'Visible','Off')
    text(0.35,1.15,textString,'unit','normalized','fontsize',20,'fontweight','bold','parent',textH);
    
    displayRange(hPlotsFig.hPlot1,[8 12],getYLims(hPlotsFig.hPlot1),[0.25 0.25 0.25],'solid-solid')
    displayRange(hPlotsFig.hPlot1(1),[20 34],getYLims(hPlotsFig.hPlot1),[0.75 0 0.75],'solid-solid')
    displayRange(hPlotsFig.hPlot1(1),[36 66],getYLims(hPlotsFig.hPlot1),[0.9290 0.6940 0.1250],'dash-dash')
    displayRange(hPlotsFig.hPlot1(2),[32 32],getYLims(hPlotsFig.hPlot1),[0 0 0],'solid-solid')
    displayRange(hPlotsFig.hPlot1(2),[32 32],getYLims(hPlotsFig.hPlot1),[0 0 0],'dash-dash')
    
    displayRange(hPlotsFig.hPlot2,[8 12],getYLims(hPlotsFig.hPlot2),[0.25 0.25 0.25],'solid-solid')
    displayRange(hPlotsFig.hPlot2,[20 34],getYLims(hPlotsFig.hPlot2),[0.75 0 0.75],'solid-solid')
    displayRange(hPlotsFig.hPlot2,[36 66],getYLims(hPlotsFig.hPlot2),[0.9290 0.6940 0.1250],'dash-dash')
    
    rescaleData(hPlotsFig.hPlot1,0,100,getYLims(hPlotsFig.hPlot1),14);
    rescaleData(hPlotsFig.hPlot2,0,100,getYLims(hPlotsFig.hPlot2),14);
    if iRefScheme == 1
        if strcmp(analysisType,'MT')
            figName = fullfile(folderSourceString,[subjectName, expDate, '_noInterStimFlag_', num2str(noInterStimFlag) '_Unipolar_Ref_tapers', num2str(tapers_MT(2)) '_plotPSDFlag' num2str(plotPSDFlag) '_displayDeltaPSDs' num2str(plotdPSDFlag)]);
        else
            figName = fullfile(folderSourceString,[subjectName, expDate, '_noInterStimFlag_', num2str(noInterStimFlag) '_Unipolar_Ref_tapers', 'FFT plots']);
        end
        
    elseif iRefScheme == 2
        if strcmp(analysisType,'MT')
            figName = fullfile(folderSourceString,[subjectName, expDate, '_noInterStimFlag_', num2str(noInterStimFlag) '_Bipolar_Ref_tapers', num2str(tapers_MT(2)) '_plotPSDFlag' num2str(plotPSDFlag) '_displayDeltaPSDs' num2str(plotdPSDFlag)]);
        else
            figName = fullfile(folderSourceString,[subjectName, expDate, '_noInterStimFlag_', num2str(noInterStimFlag) '_Bipolar_Ref_', 'FFT plots']);
        end
    end
    
    legend(hPlotsFig.hPlot1(1),'Eyes Open','Eyes Closed','Location','best')
    legend(hPlotsFig.hPlot1(2),'Baseline Period [-0.5s to 0s]','Stimulus Period [0.25s to 0.75s]','Location','best')
    
    saveas(hFig,[figName '.fig'])
    print(hFig,[figName '.tif'],'-dtiff','-r600')
%     
%     % plotTopoplots
%     refType = 'bipolar'; projectName = 'CRFAttentionProject';
%     cleanDataFolder = fullfile('D:','cleanData',projectName,'SF_ORI');
%     
%     % For topoplots
%     cLimsTopo = [-1 3];
%     showMode = 'dots'; showElecs = [93 94 101 102 96 97 111 107 112];
%     
%     Get the electrode list
%     clear cL bL chanlocs iElec electrodeList
%     switch iRefScheme
%         case 1 % unipolar
%             cL = load(fullfile(pwd,'\Programs\ProgramsMAP\Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
%             chanlocs = cL.chanlocs;
%             for iElec = 1:length(chanlocs)
%                 electrodeList{iElec}{1} = iElec;
%             end
%         case 2 % bipolar
%             cL = load(fullfile(pwd,'\Programs\ProgramsMAP\Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
%             bL = load(fullfile(pwd,'\Programs\ProgramsMAP\Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat']));
%             chanlocs = cL.eloc;
%             for iElec = 1:length(chanlocs)
%                 electrodeList{iElec}{1} = bL.bipolarLocs(iElec,:);
%             end
%     end
end

end % end of main function

% Accessory Functions
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

function [badTrials,badElecs] = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
end

% Draw lines for timeTange or FreqRange
function displayRange(plotHandles,range,yLims,colorName,lineStyle)
[nX,nY] = size(plotHandles);
% yLims = getYLims(plotHandles);
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
        elseif strcmp(lineStyle,'dash-dash')
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineStyle','--','LineWidth',1.5);
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


% Get MeanEnergy for different frequency bands
function eValue = getMeanEnergyForAnalysis(mEnergy,freq,freqRange)

posToAverage = intersect(find(freq>=freqRange(1)),find(freq<=freqRange(2)));
eValue   = sum(mEnergy(posToAverage));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
