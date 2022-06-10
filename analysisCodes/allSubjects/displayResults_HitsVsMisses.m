function displayResults_HitsVsMisses(protocolType,analysisMethodFlag,...
    subjectIdx,timeEpoch,removeBadElectrodeData,...
    plotBaselineSubtractedPowerFlag,topoplot_style,colorMap)

close all;
if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

tapers = [1 1];

timingParamters.blRange = [-1.000 0];
timingParamters.stRange = [0.250 1.250];
timingParamters.tgRange = [-1.000 0];
timingParamters.erpRange = [0 0.250];

if  all(subjectIdx<8) % First Set of Recording- Nov-Dec 2021
    freqRanges{1} = [8 12];    % alpha
    freqRanges{2} = [20 66];   % gamma
    freqRanges{3} = [23 23];   % SSVEP Left Stim; Flicker Freq moved by 0.5 Hz due one extra blank Frame
    freqRanges{4} = [31 31];   % SSVEP Right Stim; Flicker Freq moved by 0.5 Hz due one extra blank Frame
    freqRanges{5} = [20 34];   % Slow Gamma
    freqRanges{6} = [36 66];   % Fast Gamma
    freqRanges{7} = [102 250]; % High Gamma
else % Second Set of Recording- Jan-Mar 2022
    freqRanges{1} = [8 12];    % alpha
    freqRanges{2} = [20 66];   % gamma
    freqRanges{3} = [24 24];   % SSVEP Left Stim; Flicker Freq bug Fixed
    freqRanges{4} = [32 32];   % SSVEP Right Stim; Flicker Freq bug Fixed
    freqRanges{5} = [20 34];   % Slow Gamma
    freqRanges{6} = [36 66];   % Fast Gamma
    freqRanges{7} = [102 250]; % High Gamma
end
numFreqs = length(freqRanges);

fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',[protocolType '_tapers_' num2str(tapers(2)) '.mat']);
if exist(fileName, 'file')
    load(fileName,'erpData','energyData','badElecs','badHighPriorityElecs') %#ok<*LOAD>
else
    [erpData,fftData,energyData,badHighPriorityElecs,badElecs] = ...
        getData_SRCLongProtocols_v1(protocolType,gridType,timingParamters,tapers,freqRanges);
    save(fileName,'erpData','fftData','energyData','badHighPriorityElecs','badElecs')
end

if analysisMethodFlag % Replacing the PSD and power Values for Flickering conditions when MT is computed on mean signal!
    for iRef = 1:2
        energyData.dataBL{iRef}(:,:,:,:,1,:) = energyData.dataBL_trialAvg{iRef}(:,:,:,:,1,:);
        energyData.dataST{iRef}(:,:,:,:,1,:) = energyData.dataST_trialAvg{iRef}(:,:,:,:,1,:);
        energyData.dataTG{iRef}(:,:,:,:,1,:) = energyData.dataTG_trialAvg{iRef}(:,:,:,:,1,:);
        energyData.dataBL{iRef}(:,:,:,:,2,:) = energyData.dataBL_trialAvg{iRef}(:,:,:,:,2,:);
        energyData.dataST{iRef}(:,:,:,:,2,:) = energyData.dataST_trialAvg{iRef}(:,:,:,:,2,:);
        energyData.dataTG{iRef}(:,:,:,:,2,:) = energyData.dataTG_trialAvg{iRef}(:,:,:,:,2,:);
        energyData.dataBL{iRef}(:,:,:,:,3,:) = energyData.dataBL_trialAvg{iRef}(:,:,:,:,3,:);
        energyData.dataST{iRef}(:,:,:,:,3,:) = energyData.dataST_trialAvg{iRef}(:,:,:,:,3,:);
        energyData.dataTG{iRef}(:,:,:,:,3,:) = energyData.dataTG_trialAvg{iRef}(:,:,:,:,3,:);
        
        energyData.analysisDataBL{iRef}{1,1} = energyData.analysisDataBL_trialAvg{iRef}{1,1};
        energyData.analysisDataST{iRef}{1,1} = energyData.analysisDataST_trialAvg{iRef}{1,1};
        energyData.analysisDataTG{iRef}{1,1} = energyData.analysisDataTG_trialAvg{iRef}{1,1};
        energyData.analysisDataBL{iRef}{1,3} = energyData.analysisDataBL_trialAvg{iRef}{1,3};
        energyData.analysisDataST{iRef}{1,3} = energyData.analysisDataST_trialAvg{iRef}{1,3};
        energyData.analysisDataTG{iRef}{1,3} = energyData.analysisDataTG_trialAvg{iRef}{1,3};
        energyData.analysisDataBL{iRef}{1,4} = energyData.analysisDataBL_trialAvg{iRef}{1,4};
        energyData.analysisDataST{iRef}{1,4} = energyData.analysisDataST_trialAvg{iRef}{1,4};
        energyData.analysisDataTG{iRef}{1,4} = energyData.analysisDataTG_trialAvg{iRef}{1,4};
    end
end

% remove Bad Electrodes- converting the data for bad Elecs to NaN
if removeBadElectrodeData
    for iSub = 1:length(subjectIdx)
        for iRef = 1:2
            clear badElecsTMP
            badElecsTMP = badElecs{iRef}{subjectIdx(iSub)};
            
            if exist('erpData','var')
                % removing ERP data for Bad Electrodes
                erpData.dataST{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
                erpData.dataTG{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
                erpData.analysisData_BL{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
                erpData.analysisData_ST{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
                erpData.analysisData_TG{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
            end

            % removing Energy data (PSD & Power) for Bad Electrodes
            energyData.dataBL{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            energyData.dataST{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            energyData.dataTG{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            
            for iFreqRanges = 1: length(freqRanges)
                energyData.analysisDataBL{iRef}{iFreqRanges}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
                energyData.analysisDataST{iRef}{iFreqRanges}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
                energyData.analysisDataTG{iRef}{iFreqRanges}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
            end
        end
    end
end

nanFlag = 'omitnan';

% Plots
hFig1 = figure(1); colormap(colorMap)
set(hFig1,'units','normalized','outerPosition',[0 0 1 1]);
hPlot1 = getPlotHandles(5,3,[0.1 0.05, 0.5 0.85],0.02,0.04,0);
hPlot2 = getPlotHandles(3,1,[0.65 0.07, 0.3 0.88],0.02,0.1,0);

if plotBaselineSubtractedPowerFlag
    cLimsRaw1 = [-2 2];
    cLimsRaw2 = [-2 2];
    cLimsRaw3 = [-2 2];
    
    cLimsDiff1 = [-1 2];
    cLimsDiff2 = [-1 2];
    cLimsDiff3 = [-1 2];
else
    cLimsRaw1 = [-1 2];
    cLimsRaw2 = [-1 2];
    cLimsRaw3 = [-1 2];
    
    cLimsDiff1 = [-1 2];
    cLimsDiff2 = [-1 2];
    cLimsDiff3 = [-1 2];
end

% rhythmIDs = [1 5 6];
fontSizeLarge = 14; tickLengthMedium = [0.025 0];

showMode = 'dots';
showElecsUnipolarLeft = [24 29 57 61]; %[24 26 29 30 31 57 58 61 62 63];%[93 94 101 102 96 97 111 107 112];
showElecsUnipolarRight = [26 31 58 63];
showElecsBipolarLeft = [93 94 101];
showElecsBipolarRight = [96 97 102];

showElecsLeft{1} = showElecsUnipolarLeft;
showElecsLeft{2} = showElecsBipolarLeft;
showElecsRight{1} = showElecsUnipolarRight;
showElecsRight{2} = showElecsBipolarRight;


capLayout = {'actiCap64'};
% Get the electrode list
% clear cL bL chanlocs iElec electrodeList

cL_Unipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
chanlocs_Unipolar = cL_Unipolar.chanlocs;

cL_Bipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
bL = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat'])); %#ok<*NASGU>
chanlocs_Bipolar = cL_Bipolar.eloc;

if strcmp(timeEpoch,'StimOnset')
    powerData = energyData.analysisDataST;
    powerDataBL = energyData.analysisDataBL;
    ERPData = erpData.dataST;
    psdData = energyData.dataST;
    psdDataBL = energyData.dataBL;
    rmsERPData = erpData.analysisData_ST;
elseif strcmp(timeEpoch,'PreTarget')
    powerData = energyData.analysisDataTG;
    powerDataBL = energyData.analysisDataBL;
    ERPData = erpData.dataTG;
    psdData = energyData.dataTG;
    psdDataBL = energyData.dataBL;
    rmsERPData = erpData.analysisData_TG;
end

topoPlotType = 'LeftVsRight'; rhythmIDs = [1 5 6];
[HitsData_Topo,MissesData_Topo,diffData_Topo]= getHitsVsMisses_TopoPlotPowerData_StaticStimuli...
    (powerData,rhythmIDs,topoPlotType,subjectIdx,nanFlag); %#ok<*ASGLU>
[HitsDataBL_Topo,MissesDataBL_Topo,diffDataBL_Topo]= getHitsVsMisses_TopoPlotPowerData_StaticStimuli...
    (powerDataBL,rhythmIDs,topoPlotType,subjectIdx,nanFlag); %#ok<*ASGLU>

figure(1)
% TopoPlots for Static Stimuli
for iPlot = 1:5
    switch iPlot
        case 1
            chanlocs = chanlocs_Unipolar; showElecIDs = [showElecsUnipolarLeft showElecsUnipolarRight];
        case 2
            chanlocs = chanlocs_Unipolar; showElecIDs = [showElecsUnipolarLeft showElecsUnipolarRight];
        case 3
            chanlocs = chanlocs_Unipolar; showElecIDs = [showElecsUnipolarLeft showElecsUnipolarRight];
        case 4
            chanlocs = chanlocs_Bipolar; showElecIDs = [showElecsBipolarLeft showElecsBipolarRight];
        case 5
            chanlocs = chanlocs_Bipolar; showElecIDs = [showElecsBipolarLeft showElecsBipolarRight];
    end
    
    if plotBaselineSubtractedPowerFlag
        topoPlot_Hits =  10*(HitsData_Topo{iPlot}-HitsDataBL_Topo{iPlot});
        topoPlot_Misses = 10*(MissesData_Topo{iPlot}-MissesDataBL_Topo{iPlot});
        topoPlot_HitsMinusMisses = topoPlot_Hits-topoPlot_Misses;
    else
        topoPlot_Hits =  HitsData_Topo{iPlot};
        topoPlot_Misses = MissesData_Topo{iPlot};
        topoPlot_HitsMinusMisses = 10*(topoPlot_Hits-topoPlot_Misses);
    end
    
    subplot(hPlot1(iPlot,1)); cla; hold on;
    topoplot_murty(topoPlot_Hits,chanlocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Hits); caxis(cLimsRaw1);colorbar;
    topoplot_murty([],chanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
    
    subplot(hPlot1(iPlot,2)); cla; hold on;
    topoplot_murty(topoPlot_Misses,chanlocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Misses); caxis(cLimsRaw1);colorbar;
    topoplot_murty([],chanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
    
    subplot(hPlot1(iPlot,3)); cla; hold on;
    topoplot_murty(topoPlot_HitsMinusMisses,chanlocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_HitsMinusMisses); caxis(cLimsDiff1);colorbar;
    topoplot_murty([],chanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
    
end

lineWidth = 1.5;
refType = 1;
topoPlotType = 'BothSides';
[HitsData_erp,MissesData_erp,~]= getHitsVsMissesCombinedData_StaticStimuli...
    (ERPData,refType,topoPlotType,subjectIdx,nanFlag,showElecsLeft,showElecsRight);
[HitsData_psd,MissesData_psd,~]= getHitsVsMissesCombinedData_StaticStimuli...
    (psdData,refType,topoPlotType,subjectIdx,nanFlag,showElecsLeft,showElecsRight);

[HitsDataBL_psd,MissesDataBL_psd,~]= getHitsVsMissesCombinedData_StaticStimuli...
    (psdDataBL,refType,topoPlotType,subjectIdx,nanFlag,showElecsLeft,showElecsRight);

plot(hPlot2(1),erpData.timeVals,mean(HitsData_erp,1,nanFlag),'r'); hold(hPlot2(1),'on');
plot(hPlot2(1),erpData.timeVals,mean(MissesData_erp,1,nanFlag),'b');
xlim(hPlot2(1),[-1.5 1.5]);

deltaPSD = 10*(log10(HitsData_psd)-log10(MissesData_psd));
plot(hPlot2(2),energyData.freqVals,mean(log10(HitsData_psd),1,nanFlag),'r','LineWidth',lineWidth); hold(hPlot2(2),'on');
plot(hPlot2(2),energyData.freqVals,mean(log10(MissesData_psd),1,nanFlag),'b','LineWidth',lineWidth);
plot(hPlot2(2),energyData.freqVals,mean(log10(HitsDataBL_psd),1,nanFlag),'k','LineWidth',lineWidth); hold(hPlot2(2),'on');
plot(hPlot2(2),energyData.freqVals,mean(log10(MissesDataBL_psd),1,nanFlag),'--k','LineWidth',lineWidth);
plot(hPlot2(2),energyData.freqVals,mean(deltaPSD,1,nanFlag),'k','LineWidth',lineWidth);
xlim(hPlot2(2),[0 100]);

topoPlotType = 'BothSides';
rhythmIDs = [1 3 4 5 6];
[HitsAnalysisData,MissesAnalysisData]= getHitsVsMisses_BarPlotData_StaticStimuli...
    (rmsERPData,powerData,topoPlotType,rhythmIDs,subjectIdx,nanFlag,showElecsLeft,showElecsRight);
[HitsAnalysisDataBL,MissesAnalysisDataBL]= getHitsVsMisses_BarPlotData_StaticStimuli...
    (rmsERPData,powerDataBL,topoPlotType,rhythmIDs,subjectIdx,nanFlag,showElecsLeft,showElecsRight);

colors = {'y','k',[0.4940 0.1840 0.5560],'m',[0.4940 0.1840 0.5560],'m','g','c'};

% attAnalysisData{7} = [];
% attAnalysisData{8} = [];
for iBar = 1:length(HitsAnalysisData)-2
    
    if iBar ==1
        HitsData = HitsAnalysisData{iBar};
        MissesData = MissesAnalysisData{iBar};
        diffData = HitsData-MissesData;
        mBar = mean(diffData,1,nanFlag);
        errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
    else
        if plotBaselineSubtractedPowerFlag
            HitsData = log10(HitsAnalysisData{iBar})-log10(HitsAnalysisDataBL{iBar});
            MissesData = log10(MissesAnalysisData{iBar})-log10(MissesAnalysisDataBL{iBar});
        else
            HitsData = log10(HitsAnalysisData{iBar});
            MissesData = log10(MissesAnalysisData{iBar});
        end
        diffData = 10*(HitsData-MissesData); %dB
        mBar = mean(diffData,1,nanFlag);
        errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
    end
    
    mBars(iBar) = mBar; %#ok<*AGROW>
    eBars(iBar) = errorBar;
    subplot(hPlot2(3));hold(hPlot2(3),'on');
    barPlot = bar(iBar,mBar);
    barPlot.FaceColor = colors{iBar};
    ylim(hPlot2(3),[-1 1])
end

errorbar(hPlot2(3),1:length(mBars),mBars,eBars,'.','color','k');
xlim(hPlot2(3),[0 9]);

annotation('textbox',[0.13 0.97 0.1 0.0241],'EdgeColor','none','String','Hits','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.18+ 0.12 0.97 0.1 0.0241],'EdgeColor','none','String','Misses','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.34+ 0.12 0.97 0.3 0.0241],'EdgeColor','none','String','Hits - Misses','fontSize',14,'fontWeight','bold');

% Attend Left; Left: 0 Hz; Right: 0 Hz;
elpsL = annotation('ellipse',[0.1375 0.8983 0.0146 0.0136]); 
elpsR = annotation('ellipse',[0.1677 0.8983 0.0146 0.0136]);
elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
annotation('textbox',[0.1296 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);
annotation('textbox',[0.1614 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);

% Attend Right; Left: 0 Hz; Right: 0 Hz;
elpsL = annotation('ellipse',[0.1734+0.1375 0.8983 0.0146 0.0136]); 
elpsR = annotation('ellipse',[0.1734+0.1677 0.8983 0.0146 0.0136]);
elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
annotation('textbox',[0.1734+0.1296 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);
annotation('textbox',[0.1734+0.1614 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);

annotation('textbox',[0.03 0.85 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Alpha' '(8-12 Hz)'},'fontSize',14);
annotation('textbox',[0.03 0.85-0.18 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Slow Gamma' '(20-34 Hz)'},'fontSize',14);
annotation('textbox',[0.03 0.85-2*0.18 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Fast Gamma' '(36-66 Hz)'},'fontSize',14);
annotation('textbox',[0.03 0.85-3*0.18 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Bipolar Ref.' 'Slow Gamma' '(20-34 Hz)'},'fontSize',14);
annotation('textbox',[0.03 0.85-4*0.18 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Bipolar Ref.' 'Fast Gamma' '(36-66 Hz)'},'fontSize',14);

title(hPlot2(1),'ERP'); xlabel(hPlot2(1),'Time (s)'); ylabel(hPlot2(1),'\muV')
title(hPlot2(2),'PSD');xlabel(hPlot2(2),'Frequency (Hz)'); ylabel(hPlot2(2),'log_1_0 (Power)')
title(hPlot2(3),'\Delta Power (Misses vs. Hits)');  ylabel(hPlot2(3), '\Delta Power (dB)')
fontSize = 12;
tickPlotLength = get(hPlot2(1),'TickLength');
Datalabels = {'ERP','alpha','Slow-\gamma','Fast-\gamma','Bip-Slow-\gamma','Bip-Fast-\gamma'}; 

for i=1:3
set(hPlot2(i),'fontSize',fontSize,'box','off','tickLength',2*tickPlotLength,'TickDir','out')
end

set(hPlot2(3),'xTick',1:6,'xTickLabel',Datalabels,'XTickLabelRotation',30);

hFig2 = figure(2); colormap(colorMap)
set(hFig2,'units','normalized','outerPosition',[0 0 1 1]);
hPlot1 = getPlotHandles(2,3,[0.07 0.5, 0.45 0.42],0.02,0.02,0);
hPlot2 = getPlotHandles(2,3,[0.07 0.01, 0.45 0.42],0.02,0.02,0);
hPlot3 = getPlotHandles(1,3,[0.56 0.56, 0.42 0.3],0.04,0.02,0);
hPlot4 = getPlotHandles(1,3,[0.56 0.07, 0.42 0.3],0.04,0.02,0);


% SSVEP Topoplots (Figure 2)
rhythmIDs = [3 4]; % 3- SSVEP Response at 24 Hz; 4- SSVEP Response at 32 Hz
if analysisMethodFlag
   if plotBaselineSubtractedPowerFlag
    cLimsSSVEPRaw = [-1 10];
    cLimsSSVEPDiff = [-2 5];
   else
    cLimsSSVEPRaw = [-3 -1];
    cLimsSSVEPDiff = [-2 5];
   end
else
   if plotBaselineSubtractedPowerFlag
    cLimsSSVEPRaw = [-1 5];
    cLimsSSVEPDiff = [-2 5];
   else
    cLimsSSVEPRaw = [-2 1];
    cLimsSSVEPDiff = [-1 1];
   end
end
showAllElecs = 1:64;

topoPlotFlag = 1; 
refType = 1;
[attData_Topo,MissesData_Topo,diffData_Topo]= ...
    getHitsVsMisses_TopoPlotPowerData_FlickerStimuli...
    (powerData,rhythmIDs,refType,subjectIdx,nanFlag);

[HitsDataBL_Topo,MissesDataBL_Topo,diffDataBL_Topo]= ...
    getHitsVsMisses_TopoPlotPowerData_FlickerStimuli...
    (powerDataBL,rhythmIDs,refType,subjectIdx,nanFlag);

figure(2)
for iPlot = 1:4
    switch iPlot
        case 1
            if plotBaselineSubtractedPowerFlag
                topoPlot_Hits =  10*(attData_Topo{2,1}-HitsDataBL_Topo{2,1});
                topoPlot_Misses = 10*(MissesData_Topo{2,1}-MissesDataBL_Topo{2,1});
                topoPlot_HitsMinusMisses = topoPlot_Hits-topoPlot_Misses;% 10*(diffData_Topo{2,1}-diffDataBL_Topo{2,1});
            else
                topoPlot_Hits =  attData_Topo{2,1};
                topoPlot_Misses = MissesData_Topo{2,1};
                topoPlot_HitsMinusMisses = 10*(topoPlot_Hits-topoPlot_Misses); % 10*(diffData_Topo{2,1});
            end
            hTopo = hPlot1; plotID = 1; showElecIDs = showElecsUnipolarRight;
        case 2
            if plotBaselineSubtractedPowerFlag
                topoPlot_Hits =  10*(attData_Topo{1,1}-HitsDataBL_Topo{1,1});
                topoPlot_Misses = 10*(MissesData_Topo{1,1}-MissesDataBL_Topo{1,1});
                topoPlot_HitsMinusMisses = topoPlot_Hits-topoPlot_Misses; %10*(diffData_Topo{1,1}-diffDataBL_Topo{1,1});
            else
                topoPlot_Hits =  attData_Topo{1,1};
                topoPlot_Misses = MissesData_Topo{1,1};
                topoPlot_HitsMinusMisses = topoPlot_Hits-topoPlot_Misses; %10*(diffData_Topo{1,1});
            end
            hTopo = hPlot1; plotID = 2; showElecIDs = showElecsUnipolarLeft;
        case 3
            if plotBaselineSubtractedPowerFlag
                topoPlot_Hits = 10*(attData_Topo{2,2}-HitsDataBL_Topo{2,2});
                topoPlot_Misses = 10*(MissesData_Topo{2,2}-MissesDataBL_Topo{2,2});
                topoPlot_HitsMinusMisses = topoPlot_Hits-topoPlot_Misses; %10*(diffData_Topo{2,2}-diffDataBL_Topo{2,2});
            else
                topoPlot_Hits =  attData_Topo{2,2};
                topoPlot_Misses = MissesData_Topo{2,2};
                topoPlot_HitsMinusMisses = 10*(topoPlot_Hits-topoPlot_Misses); %10*(diffData_Topo{2,2});
            end
            hTopo = hPlot2; plotID = 1; showElecIDs = showElecsUnipolarRight;

        case 4
            if plotBaselineSubtractedPowerFlag
                topoPlot_Hits = 10*(attData_Topo{1,2}-HitsDataBL_Topo{1,2});
                topoPlot_Misses = 10*(MissesData_Topo{1,2}-MissesDataBL_Topo{1,2});
                topoPlot_HitsMinusMisses = topoPlot_Hits-topoPlot_Misses; %10*(diffData_Topo{1,2}-diffDataBL_Topo{1,2});
            else
                topoPlot_Hits =  attData_Topo{1,2};
                topoPlot_Misses = MissesData_Topo{1,2};
                topoPlot_HitsMinusMisses = 10*(topoPlot_Hits-topoPlot_Misses); %10*(diffData_Topo{1,2});
            end
            hTopo = hPlot2; plotID = 2; showElecIDs = showElecsUnipolarLeft;

    end

    subplot(hTopo(plotID,1)); cla; hold on;
    topoplot_murty(topoPlot_Hits,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Hits); caxis(cLimsSSVEPRaw);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
    
    subplot(hTopo(plotID,2)); cla; hold on;
    topoplot_murty(topoPlot_Misses,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Misses); caxis(cLimsSSVEPRaw);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);

    subplot(hTopo(plotID,3)); cla; hold on;
    topoplot_murty(topoPlot_HitsMinusMisses,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_HitsMinusMisses); caxis(cLimsSSVEPDiff);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);

end

% get ERP Data for Attended and Ignored Conditions for Flicker Stimuli
[HitsData_erp,MissesData_erp,~]= getHitsVsMissesCombinedData_FlickerStimuli...
    (ERPData,refType,subjectIdx,nanFlag,showElecsLeft,showElecsRight);
% get PSD Data for Attended and Ignored Conditions for Flicker Stimuli
[HitsData_psd,MissesData_psd,~]= getHitsVsMissesCombinedData_FlickerStimuli...
    (psdData,refType,subjectIdx,nanFlag,showElecsLeft,showElecsRight);

[HitsDataBL_psd,MissesDataBL_psd,~]= getHitsVsMissesCombinedData_FlickerStimuli...
    (psdDataBL,refType,subjectIdx,nanFlag,showElecsLeft,showElecsRight);

for iPlot = 1:2
    switch iPlot
        case 1; erp_Att = mean(HitsData_erp{1},1,nanFlag); 
                erp_Ign = mean(MissesData_erp{1},1,nanFlag); 
                psd_Att = mean(log10(HitsData_psd{1}),1,nanFlag); 
                psd_Ign = mean(log10(MissesData_psd{1}),1,nanFlag);
                psdBL_Att = mean(log10(HitsDataBL_psd{1}),1,nanFlag);
                psdBL_Ign = mean(log10(MissesDataBL_psd{1}),1,nanFlag);
                diffPSD = 10*(psd_Att-psd_Ign); hPlot = hPlot3;
        case 2; erp_Att = mean(HitsData_erp{2},1,nanFlag); 
                erp_Ign = mean(MissesData_erp{2},1,nanFlag); 
                psd_Att = mean(log10(HitsData_psd{2}),1,nanFlag); 
                psd_Ign = mean(log10(MissesData_psd{2}),1,nanFlag); 
                psdBL_Att = mean(log10(HitsDataBL_psd{2}),1,nanFlag);
                psdBL_Ign = mean(log10(MissesDataBL_psd{2}),1,nanFlag);
                diffPSD = 10*(psd_Att-psd_Ign); hPlot = hPlot4;
    end
    
   plot(hPlot(1,1),erpData.timeVals,erp_Att,'r'); hold(hPlot(1,1),'on');
   plot(hPlot(1,1),erpData.timeVals,erp_Ign,'b'); 
   xlim(hPlot(1,1),[-1.5 1.5])
   
   plot(hPlot(1,2),energyData.freqVals,psd_Att,'r'); hold(hPlot(1,2),'on');
   plot(hPlot(1,2),energyData.freqVals,psd_Ign,'b');
   plot(hPlot(1,2),energyData.freqVals,psdBL_Att,'k'); hold(hPlot(1,2),'on');
   plot(hPlot(1,2),energyData.freqVals,psdBL_Ign,'--k');
   
   plot(hPlot(1,2),energyData.freqVals,diffPSD,'k'); xlim(hPlot(1,2),[0 50])
end

% get rmsERP Data and power Data for Selective Analysis Electrodes
% for Attended and Ignored Conditions for Flicker Stimuli

rhythmIDs = [1 3 4 5 6];
colors = {'y','k',[0.4940 0.1840 0.5560],'m',[0.4940 0.1840 0.5560],'m','g','c'};

[HitsAnalysisData,MissesAnalysisData]= ...
    getHitsVsMisses_BarPlotData_FlickerStimuli(rmsERPData,powerData,....
    rhythmIDs,subjectIdx,nanFlag,showElecsLeft,showElecsRight);

[HitsAnalysisDataBL,MissesAnalysisDataBL]= ...
    getHitsVsMisses_BarPlotData_FlickerStimuli(rmsERPData,powerDataBL,....
    rhythmIDs,subjectIdx,nanFlag,showElecsLeft,showElecsRight);

for iPlot = 1:2
    switch iPlot
        case 1; hPlot = hPlot3;
        case 2; hPlot = hPlot4;
    end
    
    for iBar = 1:length(HitsAnalysisData{1,1})
        
        if iBar ==1
            HitsData = HitsAnalysisData{iPlot}{iBar};
            MissesData = MissesAnalysisData{iPlot}{iBar};
            diffData = HitsData-MissesData;
            mBar = mean(diffData,1,nanFlag);
            errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
        else
            if plotBaselineSubtractedPowerFlag
                HitsData = log10(HitsAnalysisData{iPlot}{iBar})-log10(HitsAnalysisDataBL{iPlot}{iBar});
                MissesData = log10(MissesAnalysisData{iPlot}{iBar})-log10(MissesAnalysisDataBL{iPlot}{iBar});
            else
                HitsData = log10(HitsAnalysisData{iPlot}{iBar});
                MissesData = log10(MissesAnalysisData{iPlot}{iBar});
            end
            diffData = 10*(HitsData-MissesData); %dB
            mBar = mean(diffData,1,nanFlag);
            errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
        end
        
        mBars(iBar) = mBar; %#ok<*AGROW>
        eBars(iBar) = errorBar;
        
        subplot(hPlot(1,3));hold(hPlot(1,3),'on');
        barPlot = bar(iBar,mBar);
        barPlot.FaceColor = colors{iBar};
        ylim(hPlot(1,3),[-3 4])
        
    end
    errorbar(hPlot(1,3),1:length(mBars),mBars,eBars,'.','color','k');
    
end



textStartPosGapFromMidline = 0.02;
textWidth = 0.15; textHeight = 0.025;
textGap = 0.26;
topoPlotLabels = {'Hits','Misses','Hits - Misses'};

for i=1:length(topoPlotLabels)
TopoPlotPos = get(hPlot1(1,i),'Position');
TopoPlotMidline = TopoPlotPos(1)+ TopoPlotPos(3)/2;
annotation('textbox',[TopoPlotPos(1)-textStartPosGapFromMidline TopoPlotPos(2)+textGap textWidth textHeight],...
    'EdgeColor','none','String',topoPlotLabels{i},'fontSize',14,'fontWeight','bold','FitBoxToText','on',...
    'HorizontalAlignment','center');
end

stringLabels1 = {'SSVEP Response' 'at 24 Hz'};
stringLabels2 = {'SSVEP Response' 'at 32 Hz'};

for i=1:2
annotation('textbox',[0.002 0.862-(i-1)*0.225 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',stringLabels1,'fontSize',14);
annotation('textbox',[0.002 0.36-(i-1)*0.225 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',stringLabels2,'fontSize',14);
end

stimDiskDistanceFromMidline = 0.01;
textStartPosGapFromMidline = 0.001;

ellipseYGap = 0.195;
ellipseWidth = 0.018;
ellipseHeight = 0.015;
textYGap = 0.205;
textWidth = 0.04;
textHeight = 0.0241;


% Stim TF: Left 12 Hz; Right 16 Hz; Attended Left: 12 Hz; Ignored Left: 12 Hz;
for i=1:2
TopoPlotPos = get(hPlot1(1,i),'Position');
TopoPlotMidline = TopoPlotPos(1)+ TopoPlotPos(3)/2;
% YLine = annotation('line',[AttendPlotMidline AttendPlotMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline- stimDiskDistanceFromMidline AttendPlotMidline- stimDiskDistanceFromMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline+ stimDiskDistanceFromMidline AttendPlotMidline+ stimDiskDistanceFromMidline],[0.5 1]);
elpsL = annotation('ellipse',[TopoPlotMidline - ellipseWidth - stimDiskDistanceFromMidline TopoPlotPos(2) + ellipseYGap ellipseWidth ellipseHeight],'units','normalized'); 
elpsR = annotation('ellipse',[TopoPlotMidline + stimDiskDistanceFromMidline TopoPlotPos(2)+ellipseYGap ellipseWidth ellipseHeight]);

if i==1
    elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
elseif i==2
    elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
end

annotation('textbox',[TopoPlotMidline-(textWidth+textStartPosGapFromMidline) TopoPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','12 Hz','fontSize',10,'EdgeColor','none','FitBoxToText','on',...
    'HorizontalAlignment','center');

annotation('textbox',[TopoPlotMidline+textStartPosGapFromMidline TopoPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','16 Hz','fontSize',10,...
    'EdgeColor','none','FitBoxToText','on','HorizontalAlignment','center');
end

% Stim TF: Left 16 Hz; Right 12 Hz; Attended Right: 12 Hz; Ignored Right: 12 Hz;
for i=1:2
TopoPlotPos = get(hPlot1(2,i),'Position');
TopoPlotMidline = TopoPlotPos(1)+ TopoPlotPos(3)/2;
% YLine = annotation('line',[AttendPlotMidline AttendPlotMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline- stimDiskDistanceFromMidline AttendPlotMidline- stimDiskDistanceFromMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline+ stimDiskDistanceFromMidline AttendPlotMidline+ stimDiskDistanceFromMidline],[0.5 1]);
elpsL = annotation('ellipse',[TopoPlotMidline-ellipseWidth- stimDiskDistanceFromMidline TopoPlotPos(2)+ellipseYGap ellipseWidth ellipseHeight],'units','normalized'); 
elpsR = annotation('ellipse',[TopoPlotMidline + stimDiskDistanceFromMidline TopoPlotPos(2)+ellipseYGap ellipseWidth ellipseHeight]);

if i==1
    elpsL.FaceColor = 'none'; elpsR.FaceColor = 'k';
elseif i==2
    elpsL.FaceColor = 'none'; elpsR.FaceColor = 'k';
end

annotation('textbox',[TopoPlotMidline-(textWidth+textStartPosGapFromMidline) TopoPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','16 Hz','fontSize',10,'EdgeColor','none','FitBoxToText','on',...
    'HorizontalAlignment','center');

annotation('textbox',[TopoPlotMidline+textStartPosGapFromMidline TopoPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','12 Hz','fontSize',10,...
    'EdgeColor','none','FitBoxToText','on','HorizontalAlignment','center');
end

% Stim TF: Left 12 Hz; Right 16 Hz; Attended Right: 16 Hz; Ignored Right: 16 Hz;
for i=1:2
TopoPlotPos = get(hPlot2(1,i),'Position');
TopoPlotMidline = TopoPlotPos(1)+ TopoPlotPos(3)/2;
% YLine = annotation('line',[AttendPlotMidline AttendPlotMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline- stimDiskDistanceFromMidline AttendPlotMidline- stimDiskDistanceFromMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline+ stimDiskDistanceFromMidline AttendPlotMidline+ stimDiskDistanceFromMidline],[0.5 1]);
elpsL = annotation('ellipse',[TopoPlotMidline-ellipseWidth- stimDiskDistanceFromMidline TopoPlotPos(2)+ellipseYGap ellipseWidth ellipseHeight],'units','normalized'); 
elpsR = annotation('ellipse',[TopoPlotMidline + stimDiskDistanceFromMidline TopoPlotPos(2)+ellipseYGap ellipseWidth ellipseHeight]);

if i==1
    elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
elseif i==2
    elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
end

annotation('textbox',[TopoPlotMidline-(textWidth+textStartPosGapFromMidline) TopoPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','16 Hz','fontSize',10,'EdgeColor','none','FitBoxToText','on',...
    'HorizontalAlignment','center');

annotation('textbox',[TopoPlotMidline+textStartPosGapFromMidline TopoPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','12 Hz','fontSize',10,...
    'EdgeColor','none','FitBoxToText','on','HorizontalAlignment','center');
end

% Stim TF: Left 16 Hz; Right 12 Hz; Attended Right: 16 Hz; Ignored Right: 16 Hz;
for i=1:2
TopoPlotPos = get(hPlot2(2,i),'Position');
TopoPlotMidline = TopoPlotPos(1)+ TopoPlotPos(3)/2;
% YLine = annotation('line',[AttendPlotMidline AttendPlotMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline- stimDiskDistanceFromMidline AttendPlotMidline- stimDiskDistanceFromMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline+ stimDiskDistanceFromMidline AttendPlotMidline+ stimDiskDistanceFromMidline],[0.5 1]);
elpsL = annotation('ellipse',[TopoPlotMidline-ellipseWidth- stimDiskDistanceFromMidline TopoPlotPos(2)+ellipseYGap ellipseWidth ellipseHeight],'units','normalized'); 
elpsR = annotation('ellipse',[TopoPlotMidline + stimDiskDistanceFromMidline TopoPlotPos(2)+ellipseYGap ellipseWidth ellipseHeight]);

if i==1
    elpsL.FaceColor = 'none'; elpsR.FaceColor = 'k';
elseif i==2
    elpsL.FaceColor = 'none'; elpsR.FaceColor = 'k';
end

annotation('textbox',[TopoPlotMidline-(textWidth+textStartPosGapFromMidline) TopoPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','12 Hz','fontSize',10,'EdgeColor','none','FitBoxToText','on',...
    'HorizontalAlignment','center');

annotation('textbox',[TopoPlotMidline+textStartPosGapFromMidline TopoPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','16 Hz','fontSize',10,...
    'EdgeColor','none','FitBoxToText','on','HorizontalAlignment','center');
end





% save Figures


if length(subjectIdx) == 26
    subString = ['subjects_N' num2str(length(subjectIdx)) '_'];
elseif length(subjectIdx) == 1
    subString = ['subjects_N' num2str(length(subjectIdx)) '_SubjectID_' num2str(subjectIdx) '_'];
else
    subString = ['subjects_N' num2str(length(subjectIdx)) '_SubjectIDs_'];
    for i= 1:length(subjectIdx)
        subString = strcat(subString,[num2str(subjectIdx(i)),'_']);
    end
end

if analysisMethodFlag == 1
    ssvepMethod = 'MT_upon_trial-averaged_signal';
else
    ssvepMethod = 'MT_upon_singleTrial_signal';
end

saveFolder = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\Figures\SRC-Attention\Topoplots\HitsVsMisses\');
figName1 = fullfile(saveFolder,[protocolType '_' subString  timeEpoch '_bandPower_tapers_' , num2str(tapers(2))]);
figName2 = fullfile(saveFolder,[protocolType '_' subString  timeEpoch '_SSVEP_', ssvepMethod,'_tapers_' , num2str(tapers(2))]);

if analysisMethodFlag==0
saveas(hFig1,[figName1 '.fig'])
print(hFig1,[figName1 '.tif'],'-dtiff','-r600')
end
saveas(hFig2,[figName2 '.fig'])
print(hFig2,[figName2 '.tif'],'-dtiff','-r600')

end


%% Accessory Functions

% Process Attend Vs. Ignored TopoPlot data for Static Stimuli
function [HitsData,MissesData,diffData]= ...
    getHitsVsMisses_TopoPlotPowerData_StaticStimuli...
    (data,rhythmIDs,topoPlotStyle,subjectIdx,nanFlag)

dataLabels = {'Alpha Uni Ref.','Slow gamma Uni','Fast Gamma Uni'...
    'Slow gamma Bi','Fast Gamma Bi'};

topoData = cell(1,length(dataLabels));

refType = 1;
topoData{1} = data{refType}{rhythmIDs(1)};
topoData{2} = data{refType}{rhythmIDs(2)};
topoData{3} = data{refType}{rhythmIDs(3)};
refType = 2;
topoData{4} = data{refType}{rhythmIDs(2)};
topoData{5} = data{refType}{rhythmIDs(3)};

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
eotCodeHits = 1; eotCodeMisses = 2; % eot Indices

if strcmp(topoPlotStyle,'LeftVsRight')
    attLoc = 2; cued_TF = 1; 
elseif strcmp(topoPlotStyle,'RightVsLeft')
    attLoc = 1; cued_TF = 1; 
end

for iRhythm = 1:length(topoData)
    HitsData{iRhythm}= squeeze(mean(log10(topoData{iRhythm}(subjectIdx,:,eotCodeHits,attLoc,cued_TF)),1,nanFlag));
    MissesData{iRhythm} = squeeze(mean(log10(topoData{iRhythm}(subjectIdx,:,eotCodeMisses,attLoc,cued_TF)),1,nanFlag));
    diffData{iRhythm} = HitsData{iRhythm} - MissesData{iRhythm};
end

end

% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions
function [attData,ignData,diffData]= getHitsVsMissesCombinedData_StaticStimuli(data,refType,topoPlotStyle,subjectIdx,nanFlag,elecsLeft,elecsRight)

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left

HitsData_all = cell(1,length(attendLocs));
MissesData_all = cell(1,length(attendLocs));
diffData_all = cell(1,length(attendLocs));

eotCodeHits = 1;eotCodeMisses = 2;

if strcmp(topoPlotStyle,'BothSides')
    attLoc = attendLocs; ign_AttLoc = flip(attendLocs); cued_TF = 1;
    elecNums{1} = elecsLeft{1};elecNums{2} = elecsRight{1};
elseif strcmp(topoPlotStyle,'LeftVsRight')
    attLoc = 2; cued_TF = 1; elecNums{1} = elecsRight{1}; 
elseif strcmp(topoPlotStyle,'RightVsLeft')
    attLoc = 1; cued_TF = 1; elecNums{1} = elecsLeft{1};
end

for i=1:length(attLoc)
    clear attDataTMP ignDataTMP
    HitsDataTMP = squeeze(data{refType}(subjectIdx,elecNums{i},eotCodeHits,attLoc(i),cued_TF,:));
    MissesDataTMP = squeeze(data{refType}(subjectIdx,elecNums{i},eotCodeMisses,attLoc(i),cued_TF,:));
    
    HitsData_all{i} = HitsDataTMP;
    MissesData_all{i}  = MissesDataTMP;
    diffData_all{i}  = HitsDataTMP - MissesDataTMP;
end

if length(HitsData_all)== 1
    attData = squeeze(mean(HitsData_all{1},2,nanFlag));
    ignData = squeeze(mean(MissesData_all{1},2,nanFlag));
    diffData = squeeze(mean(diffData_all{1},2,nanFlag));
elseif length(HitsData_all)== 2
    attData = squeeze(mean(cat(2,HitsData_all{1},HitsData_all{2}),2,nanFlag));
    ignData = squeeze(mean(cat(2,MissesData_all{1},MissesData_all{2}),2,nanFlag));
    diffData = squeeze(mean(cat(2,diffData_all{1},diffData_all{2}),2,nanFlag));
end
    
end

% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions for Analysis Electrodes for Static Stimuli

function [HitsData,MissesData]= getHitsVsMisses_BarPlotData_StaticStimuli(rmsERPData,powerData,topoPlotStyle,rhythmIDs,subjectIdx,nanFlag,elecsLeft,elecsRight)

dataLabels = {'rmsERP','Alpha Uni Ref.','Slow gamma Uni','Fast Gamma Uni'...
                'Slow gamma Bi','Fast Gamma Bi','SSVEP 23/24 Hz','SSVEP 31/32 Hz'};

data = cell(1,length(dataLabels));

refType = 1;
data{1} = rmsERPData{refType};
data{2} = powerData{refType}{rhythmIDs(1)}; % Alpha Unipolar Ref
data{3} = powerData{refType}{rhythmIDs(4)}; % Slow Gamma Unipolar Ref
data{4} = powerData{refType}{rhythmIDs(5)}; % Fast Gamma Unipolar Ref
data{7} = powerData{refType}{rhythmIDs(2)}; % 24 Hz
data{8} = powerData{refType}{rhythmIDs(3)}; % 32 HZ

refType = 2;
data{5} = powerData{refType}{rhythmIDs(4)}; % Slow Gamma Bipolar Ref
data{6} = powerData{refType}{rhythmIDs(5)}; % Fast Gamma Bipolar Ref

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
ssvepFreqs = [1 2]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz

HitsData = cell(1,length(data));
MissesData = cell(1,length(data));
eotCodeHits = 1;eotCodeMisses = 2;

if strcmp(topoPlotStyle,'BothSides')
    attLoc = attendLocs; cued_TF = 1; 
    elecNums{1} = elecsLeft; elecNums{2} = elecsRight;
elseif strcmp(topoPlotStyle,'LeftVsRight')
    attLoc = 2; cued_TF = 1; elecNums = {elecsRight};
elseif strcmp(topoPlotStyle,'RightVsLeft')
    attLoc = 1; cued_TF = 1; elecNums = {elecsLeft};
end

HitsData_all = cell(1,length(data));
MissesData_all = cell(1,length(data));
diffData_all = cell(1,length(data));
eotCodeHits = 1;eotCodeMisses = 2;

for i=1:length(attLoc)
    for iDataType = 1: length(data)
        if iDataType == 5 || iDataType == 6
            elecs = elecNums{i}{2};
        else
            elecs = elecNums{i}{1};
        end
        HitsData_all{1,iDataType}(:,i) = squeeze(mean(data{iDataType}(subjectIdx,elecs,eotCodeHits,attLoc(i),cued_TF),2,nanFlag));
        MissesData_all{1,iDataType}(:,i) = squeeze(mean(data{iDataType}(subjectIdx,elecs,eotCodeMisses,attLoc(i),cued_TF),2,nanFlag));
    end
end
        
if size(HitsData_all{1},2) == 1
    HitsData = HitsData_all;
    MissesData = MissesData_all;
elseif size(HitsData_all{1},2) == 2
    for i = 1:size(HitsData_all,2)
    HitsData{1,i} = mean(HitsData_all{1,i},2,nanFlag);
    MissesData{1,i} = mean(MissesData_all{1,i},2,nanFlag);
    end
end

end


% Process Attend Vs. Ignored TopoPlot data for Flickering Stimuli
function [HitsData,MissesData,diffData]= getHitsVsMisses_TopoPlotPowerData_FlickerStimuli(data,rhythmIDs,refType,subjectIdx,nanFlag)

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
ssvepFreqs = [1 2]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz

HitsData = cell(length(attendLocs),length(ssvepFreqs));
MissesData = cell(length(attendLocs),length(ssvepFreqs));
diffData = cell(length(attendLocs),length(ssvepFreqs));
eotCodeHits = 1;eotCodeMisses = 2;

for iAttendLoc = 1:2
    for iSSVEPFreq = 1:2
        condition = str2double(strcat(num2str(iAttendLoc),num2str(iSSVEPFreq)));
        switch(condition)
            case 21
                attLoc = 2; cued_TF = 2; 
            case 22
                attLoc = 2; cued_TF = 3; 
            case 11
                attLoc = 1; cued_TF = 2; 
            case 12
                attLoc = 1; cued_TF = 3; 
        end
        
        HitsDataTMP = squeeze(mean(log10(data{refType}{rhythmIDs(iSSVEPFreq)}(subjectIdx,:,eotCodeHits,attLoc,cued_TF)),1,nanFlag));
        MissesDataTMP = squeeze(mean(log10(data{refType}{rhythmIDs(iSSVEPFreq)}(subjectIdx,:,eotCodeMisses,attLoc,cued_TF)),1,nanFlag));
        diffDataTMP = HitsDataTMP - MissesDataTMP;

        HitsData{iAttendLoc,iSSVEPFreq} = HitsDataTMP; 
        MissesData{iAttendLoc,iSSVEPFreq} = MissesDataTMP;
        diffData{iAttendLoc,iSSVEPFreq} = diffDataTMP;
    end
end

end


% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions
function [attData,ignData,diffData]= getHitsVsMissesCombinedData_FlickerStimuli(data,refType,subjectIdx,nanFlag,elecsLeft,elecsRight)

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
ssvepFreqs = [1 2]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz

attData = cell(1,2); attData_all = cell(length(attendLocs),length(ssvepFreqs));
ignData = cell(1,2); ignData_all = cell(length(attendLocs),length(ssvepFreqs));
diffData = cell(1,2);diffData_all = cell(length(attendLocs),length(ssvepFreqs));

for iAttendLoc = 1:2
    for iSSVEPFreq = 1:2
        condition = str2double(strcat(num2str(iAttendLoc),num2str(iSSVEPFreq)));
        switch(condition)
            case 11
                attLoc = 1; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 2; elecNums = elecsLeft{1}; eotCodeIdx_Hits = 1;eotCodeIdx_Misses = 2;
            case 21
                attLoc = 2; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 2; elecNums = elecsRight{1}; eotCodeIdx_Hits = 1;eotCodeIdx_Misses = 2;
            case 12
                attLoc = 1; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 3; elecNums = elecsLeft{1}; eotCodeIdx_Hits = 1;eotCodeIdx_Misses = 2;
            case 22
                attLoc = 2; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 3; elecNums = elecsRight{1}; eotCodeIdx_Hits = 1;eotCodeIdx_Misses = 2;
        end
        
        attDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx_Hits,attLoc,att_TF,:));
        ignDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx_Misses,ign_AttLoc,ign_AttTF,:));
        diffDataTMP = attDataTMP-ignDataTMP ;
        
        attData_all{iAttendLoc,iSSVEPFreq} = attDataTMP; 
        ignData_all{iAttendLoc,iSSVEPFreq} = ignDataTMP;
        diffData_all{iAttendLoc,iSSVEPFreq} = diffDataTMP;
    end
end

for i=1:2 % SSVEP Freqs
attData{i} = squeeze(mean(cat(2,attData_all{1,i},attData_all{2,i}),2,nanFlag));
ignData{i} = squeeze(mean(cat(2,ignData_all{1,i},ignData_all{2,i}),2,nanFlag));
diffData{i} = squeeze(mean(cat(2,diffData_all{1,i},diffData_all{2,i}),2,nanFlag));
end

end

% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions for Analysis Electrodes

function [attData,ignData]= getHitsVsMisses_BarPlotData_FlickerStimuli(rmsERPData,powerData,rhythmIDs,subjectIdx,nanFlag,elecsLeft,elecsRight)

dataLabels = {'rmsERP','Alpha Uni Ref.','Slow gamma Uni','Fast Gamma Uni'...
                'Slow gamma Bi','Fast Gamma Bi','SSVEP 23/24 Hz','SSVEP 31/32 Hz'};

data = cell(1,length(dataLabels));

refType = 1;
data{1} = rmsERPData{refType};
data{2} = powerData{refType}{rhythmIDs(1)}; % Alpha Unipolar Ref
data{3} = powerData{refType}{rhythmIDs(4)}; % Slow Gamma Unipolar Ref
data{4} = powerData{refType}{rhythmIDs(5)}; % Fast Gamma Unipolar Ref
data{7} = powerData{refType}{rhythmIDs(2)}; % SSVEP 24 Hz
data{8} = powerData{refType}{rhythmIDs(3)}; % SSVEP 32 Hz

refType = 2;
data{5} = powerData{refType}{rhythmIDs(4)}; % Slow Gamma Bipolar Ref
data{6} = powerData{refType}{rhythmIDs(5)}; % Fast Gamma Bipolar Ref

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
ssvepFreqs = [1 2]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz

attData = cell(1,2); attData_all = cell(length(attendLocs),length(ssvepFreqs));
ignData = cell(1,2); ignData_all = cell(length(attendLocs),length(ssvepFreqs));
diffData = cell(1,2);diffData_all = cell(length(attendLocs),length(ssvepFreqs));

for iAttendLoc = 1:2
    for iSSVEPFreq = 1:2
        condition = str2double(strcat(num2str(iAttendLoc),num2str(iSSVEPFreq)));
        switch(condition)
            case 21
                attLoc = 2; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 2; elecNums = elecsRight; eotCodeIdx_Hits = 1;eotCodeIdx_Misses = 2;
            case 22
                attLoc = 2; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 3; elecNums = elecsRight; eotCodeIdx_Hits = 1;eotCodeIdx_Misses = 2;
            case 11
                attLoc = 1; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 2; elecNums = elecsLeft; eotCodeIdx_Hits = 1;eotCodeIdx_Misses = 2;
            case 12
                attLoc = 1; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 3; elecNums = elecsLeft; eotCodeIdx_Hits = 1;eotCodeIdx_Misses = 2;
        end
        
        for iDataType = 1: length(data)
            if iDataType == 5 || iDataType == 6
                elecs = elecNums{2};
            else
                elecs = elecNums{1};
            end
            attDataTMP{iDataType} = data{iDataType}(subjectIdx,elecs,eotCodeIdx_Hits,attLoc,att_TF); 
            ignDataTMP{iDataType} = data{iDataType}(subjectIdx,elecs,eotCodeIdx_Misses,ign_AttLoc,ign_AttTF); 
        end
        

        attData_all{iAttendLoc,iSSVEPFreq} = attDataTMP; 
        ignData_all{iAttendLoc,iSSVEPFreq} = ignDataTMP;
    end
end

for i=1:2
    for j = 1:length(dataLabels)
        attData{i}{j} = squeeze(mean(cat(2,attData_all{1,i}{j},attData_all{2,i}{j}),2,nanFlag));
        ignData{i}{j} = squeeze(mean(cat(2,ignData_all{1,i}{j},ignData_all{2,i}{j}),2,nanFlag));
    end
end

end




