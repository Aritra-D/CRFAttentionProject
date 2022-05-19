function displayResults_AttendVsIgnored(protocolType,analysisMethodFlag,subjectIdx,timeEpoch,eotCodeIdx,removeBadElectrodeData,topoplot_style,colorMap)

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
    %     clear energyData.dataBL energyData.dataST energyData.dataTG
    %     clear energyData.analysisDataBL energyData.analysisDataST energyData.analysisDataTG
    for iRef = 1:2
        energyData.dataBL{iRef}(:,:,:,:,2:3,:) = energyData.dataBL_trialAvg{iRef}(:,:,:,:,2:3,:);
        energyData.dataST{iRef}(:,:,:,:,2:3,:) = energyData.dataST_trialAvg{iRef}(:,:,:,:,2:3,:);
        energyData.dataTG{iRef}(:,:,:,:,2:3,:) = energyData.dataTG_trialAvg{iRef}(:,:,:,:,2:3,:);
        
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

cLimsRaw1 = [-1 2];
cLimsRaw2 = [-1 2];
cLimsRaw3 = [-1 2];

cLimsDiff1 = [-1 2];
cLimsDiff2 = [-1 2];
cLimsDiff3 = [-1 2];

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
    ERPData = erpData.dataST;
    psdData = energyData.dataST;
    rmsERPData = erpData.analysisData_ST;
elseif strcmp(timeEpoch,'PreTarget')
    powerData = energyData.analysisDataTG;
    ERPData = erpData.dataTG;
    psdData = energyData.dataTG;
    rmsERPData = erpData.analysisData_TG;
end

topoPlotStyle = 'LeftVsRight'; rhythmIDs = [1 5 6];
[attData_Topo,ignData_Topo,diffData_Topo]= getAttendVsIgnored_TopoPlotPowerData_StaticStimuli(powerData,rhythmIDs,topoPlotStyle,subjectIdx,eotCodeIdx,nanFlag); %#ok<*ASGLU>

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
    topoPlot_Attended =  attData_Topo{iPlot};
    topoPlot_Ignored = ignData_Topo{iPlot};
    topoPlot_AttendedMinusIgnored = 10*(topoPlot_Attended-topoPlot_Ignored);
    
    
    subplot(hPlot1(iPlot,1)); cla; hold on;
    topoplot_murty(topoPlot_Attended,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Attended); caxis(cLimsRaw1);colorbar;
    topoplot_murty([],chanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
    
    subplot(hPlot1(iPlot,2)); cla; hold on;
    topoplot_murty(topoPlot_Ignored,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Ignored); caxis(cLimsRaw1);colorbar;
    topoplot_murty([],chanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);

    subplot(hPlot1(iPlot,3)); cla; hold on;
    topoplot_murty(topoPlot_AttendedMinusIgnored,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_AttendedMinusIgnored); caxis(cLimsDiff1);colorbar;
    topoplot_murty([],chanlocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);

end

lineWidth = 1.5;
refType = 1;
[attData_erp,ignData_erp,~]= getAttendVsIgnoredCombinedData_StaticStimuli(ERPData,refType,topoPlotStyle,subjectIdx,eotCodeIdx,nanFlag,showElecsLeft,showElecsRight);
[attData_psd,ignData_psd,~]= getAttendVsIgnoredCombinedData_StaticStimuli(psdData,refType,topoPlotStyle,subjectIdx,eotCodeIdx,nanFlag,showElecsLeft,showElecsRight);

plot(hPlot2(1),erpData.timeVals,mean(attData_erp,1,nanFlag),'r'); hold(hPlot2(1),'on');
plot(hPlot2(1),erpData.timeVals,mean(ignData_erp,1,nanFlag),'b');
xlim(hPlot2(1),[-1.5 1.5]);

deltaPSD = 10*(log10(attData_psd)-log10(ignData_psd));
plot(hPlot2(2),energyData.freqVals,mean(log10(attData_psd),1,nanFlag),'r','LineWidth',lineWidth); hold(hPlot2(2),'on');
plot(hPlot2(2),energyData.freqVals,mean(log10(ignData_psd),1,nanFlag),'b','LineWidth',lineWidth);
plot(hPlot2(2),energyData.freqVals,mean(deltaPSD,1,nanFlag),'k','LineWidth',lineWidth);
xlim(hPlot2(2),[0 100]);

rhythmIDs = [1 3 4 5 6];
[attAnalysisData,ignAnalysisData]= getAttendVsIgnored_BarPlotData_StaticStimuli(rmsERPData,powerData,topoPlotStyle,rhythmIDs,subjectIdx,eotCodeIdx,nanFlag,showElecsLeft,showElecsRight);
colors = {'y','k',[0.4940 0.1840 0.5560],'m',[0.4940 0.1840 0.5560],'m','g','c'};

% attAnalysisData{7} = [];
% attAnalysisData{8} = [];
for iBar = 1:length(attAnalysisData)-2
    
    if iBar ==1
        attData = attAnalysisData{iBar};
        ignData = ignAnalysisData{iBar};
        diffData = attData-ignData;
        mBar = mean(diffData,1,nanFlag);
        errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
    else
        attData = log10(attAnalysisData{iBar});
        ignData = log10(ignAnalysisData{iBar});
        diffData = 10*(attData-ignData); %dB
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


annotation('textbox',[0.13 0.97 0.1 0.0241],'EdgeColor','none','String','Attend Left','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.18+ 0.12 0.97 0.1 0.0241],'EdgeColor','none','String','Attend Right','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.34+ 0.12 0.97 0.3 0.0241],'EdgeColor','none','String','Attend Left - Attend Right','fontSize',14,'fontWeight','bold');

% Attend Left; Left: 0 Hz; Right: 0 Hz;
elpsL = annotation('ellipse',[0.1375 0.8983 0.0146 0.0136]); elpsR = annotation('ellipse',[0.1677 0.8983 0.0146 0.0136]);
elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
annotation('textbox',[0.1296 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);
annotation('textbox',[0.1614 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);

% Attend Right; Left: 0 Hz; Right: 0 Hz;
elpsL = annotation('ellipse',[0.1734+0.1375 0.8983 0.0146 0.0136]); elpsR = annotation('ellipse',[0.1734+0.1677 0.8983 0.0146 0.0136]);
elpsL.FaceColor = 'none'; elpsR.FaceColor = 'k';
annotation('textbox',[0.1734+0.1296 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);
annotation('textbox',[0.1734+0.1614 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);

annotation('textbox',[0.03 0.85 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Alpha' '(8-12 Hz)'},'fontSize',14);
annotation('textbox',[0.03 0.85-0.18 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Slow Gamma' '(20-34 Hz)'},'fontSize',14);
annotation('textbox',[0.03 0.85-2*0.18 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Fast Gamma' '(36-66 Hz)'},'fontSize',14);
annotation('textbox',[0.03 0.85-3*0.18 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Bipolar Ref.' 'Slow Gamma' '(20-34 Hz)'},'fontSize',14);
annotation('textbox',[0.03 0.85-4*0.18 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Bipolar Ref.' 'Fast Gamma' '(36-66 Hz)'},'fontSize',14);

title(hPlot2(1),'ERP'); xlabel(hPlot2(1),'Time (s)'); ylabel(hPlot2(1),'\muV')
title(hPlot2(2),'PSD');xlabel(hPlot2(2),'Frequency (Hz)'); ylabel(hPlot2(2),'log_1_0 (Power)')
title(hPlot2(3),'\Delta Power (Attended vs. Ignored)');  ylabel(hPlot2(3), '\Delta Power (dB)')
fontSize = 12;
tickPlotLength = get(hPlot2(1),'TickLength');
Datalabels = {'ERP','alpha','Slow-\gamma','Fast-\gamma','Bip-Slow-\gamma','Bip-Fast-\gamma'}; 

for i=1:3
set(hPlot2(i),'fontSize',fontSize,'box','off','tickLength',2*tickPlotLength,'TickDir','out')
end

set(hPlot2(3),'xTick',1:6,'xTickLabel',Datalabels,'XTickLabelRotation',30);

hFig2 = figure(2); colormap(colorMap)
set(hFig2,'units','normalized','outerPosition',[0 0 1 1]);
hPlot1 = getPlotHandles(2,3,[0.07 0.52, 0.45 0.42],0.02,0.02,0);
hPlot2 = getPlotHandles(2,3,[0.07 0.02, 0.45 0.42],0.02,0.02,0);
hPlot3 = getPlotHandles(1,3,[0.56 0.58, 0.42 0.3],0.04,0.02,0);
hPlot4 = getPlotHandles(1,3,[0.56 0.08, 0.42 0.3],0.04,0.02,0);


% SSVEP Topoplots (Figure 2)
rhythmIDs = [3 4]; % 3- SSVEP Response at 24 Hz; 4- SSVEP Response at 32 Hz
if analysisMethodFlag
    cLimsSSVEPRaw = [-3 -1];
    cLimsSSVEPDiff = [-3 5];
else
    cLimsSSVEPRaw = [-2 1];
    cLimsSSVEPDiff = [-1 1];
end
showAllElecs = 1:64;

topoPlotFlag = 1; 
refType = 1;
[attData_Topo,ignData_Topo,diffData_Topo]= ...
    getAttendVsIgnored_TopoPlotPowerData_FlickerStimuli...
    (powerData,rhythmIDs,refType,subjectIdx,eotCodeIdx,nanFlag);

figure(2)
for iPlot = 1:4
    switch iPlot
        case 1
            topoPlot_Attended =  attData_Topo{2,1};
            topoPlot_Ignored = ignData_Topo{2,1};
            topoPlot_AttendedMinusIgnored = 10*(diffData_Topo{2,1});
            hTopo = hPlot1; plotID = 1; showElecIDs = showElecsUnipolarRight;
        case 2
            topoPlot_Attended =  attData_Topo{1,1};
            topoPlot_Ignored = ignData_Topo{1,1};
            topoPlot_AttendedMinusIgnored = 10*(diffData_Topo{1,1});
            hTopo = hPlot1; plotID = 2; showElecIDs = showElecsUnipolarLeft;
        case 3
            topoPlot_Attended =  attData_Topo{2,2};
            topoPlot_Ignored = ignData_Topo{2,2};
            topoPlot_AttendedMinusIgnored = 10*(diffData_Topo{2,2});
            hTopo = hPlot2; plotID = 1; showElecIDs = showElecsUnipolarRight;
        case 4
            topoPlot_Attended =  attData_Topo{1,2};
            topoPlot_Ignored = ignData_Topo{1,2};
            topoPlot_AttendedMinusIgnored = 10*(diffData_Topo{1,2});
            hTopo = hPlot2; plotID = 2; showElecIDs = showElecsUnipolarLeft;
    end

    subplot(hTopo(plotID,1)); cla; hold on;
    topoplot_murty(topoPlot_Attended,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Attended); caxis(cLimsSSVEPRaw);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
    
    subplot(hTopo(plotID,2)); cla; hold on;
    topoplot_murty(topoPlot_Ignored,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Ignored); caxis(cLimsSSVEPRaw);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);

    subplot(hTopo(plotID,3)); cla; hold on;
    topoplot_murty(topoPlot_AttendedMinusIgnored,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_AttendedMinusIgnored); caxis(cLimsSSVEPDiff);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);

end

% get ERP Data for Attended and Ignored Conditions for Flicker Stimuli
[attData_erp,ignData_erp,~]= getAttendVsIgnoredCombinedData_FlickerStimuli(ERPData,refType,subjectIdx,eotCodeIdx,nanFlag,showElecsLeft,showElecsLeft);
% get PSD Data for Attended and Ignored Conditions for Flicker Stimuli
[attData_psd,ignData_psd,~]= getAttendVsIgnoredCombinedData_FlickerStimuli(psdData,refType,subjectIdx,eotCodeIdx,nanFlag,showElecsLeft,showElecsLeft);

for iPlot = 1:2
    switch iPlot
        case 1; erp_Att = mean(attData_erp{1},1,nanFlag); 
                erp_Ign = mean(ignData_erp{1},1,nanFlag); 
                psd_Att = mean(log10(attData_psd{1}),1,nanFlag); 
                psd_Ign = mean(log10(ignData_psd{1}),1,nanFlag); 
                diffPSD = 10*(psd_Att-psd_Ign); hPlot = hPlot3;
        case 2; erp_Att = mean(attData_erp{2},1,nanFlag); 
                erp_Ign = mean(ignData_erp{2},1,nanFlag); 
                psd_Att = mean(log10(attData_psd{2}),1,nanFlag); 
                psd_Ign = mean(log10(ignData_psd{2}),1,nanFlag); 
                diffPSD = 10*(psd_Att-psd_Ign); hPlot = hPlot4;
    end
    
   plot(hPlot(1,1),erpData.timeVals,erp_Att,'r'); hold(hPlot(1,1),'on');
   plot(hPlot(1,1),erpData.timeVals,erp_Ign,'b'); 
   xlim(hPlot(1,1),[-1.5 1.5])
   
   plot(hPlot(1,2),energyData.freqVals,psd_Att,'r'); hold(hPlot(1,2),'on');
   plot(hPlot(1,2),energyData.freqVals,psd_Ign,'b'); 
   plot(hPlot(1,2),energyData.freqVals,diffPSD,'k'); xlim(hPlot(1,2),[0 50])
end

% get rmsERP Data and power Data for Selective Analysis Electrodes
% for Attended and Ignored Conditions for Flicker Stimuli

rhythmIDs = [1 3 4 5 6];
colors = {'y','k',[0.4940 0.1840 0.5560],'m',[0.4940 0.1840 0.5560],'m','g','c'};

[attAnalysisData,ignAnalysisData]= ...
    getAttendVsIgnored_BarPlotData_FlickerStimuli(rmsERPData,powerData,....
    rhythmIDs,subjectIdx,eotCodeIdx,nanFlag,showElecsLeft,showElecsLeft);

for iPlot = 1:2
    switch iPlot
        case 1; hPlot = hPlot3;
        case 2; hPlot = hPlot4;
    end
    
    for iBar = 1:length(attAnalysisData{1,1})
        
        if iBar ==1
            attData = attAnalysisData{iPlot}{iBar};
            ignData = ignAnalysisData{iPlot}{iBar};
            diffData = attData-ignData;
            mBar = mean(diffData,1,nanFlag);
            errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
        else
            attData = log10(attAnalysisData{iPlot}{iBar});
            ignData = log10(ignAnalysisData{iPlot}{iBar});
            diffData = 10*(attData-ignData); %dB
            mBar = mean(diffData,1,nanFlag);
            errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
        end
        
        mBars(iBar) = mBar; %#ok<*AGROW>
        eBars(iBar) = errorBar;
        
        subplot(hPlot(1,3));hold(hPlot(1,3),'on');
        barPlot = bar(iBar,mBar);
        barPlot.FaceColor = colors{iBar};
        ylim(hPlot(1,3),[-3 3])
        
    end
    errorbar(hPlot(1,3),1:length(mBars),mBars,eBars,'.','color','k');
    
end

AttendPlotPos = get(hPlot1(1,1),'Position');
AttendPlotMidline = AttendPlotPos(1)+ AttendPlotPos(3)/2;
stimDiskDistanceFromMidline = 0.0275;
textWidth = 0.1;

annotation('textbox',[AttendPlotMidline-stimDiskDistanceFromMidline AttendPlotPos(2)+0.24 0.1 0.025],'EdgeColor','none','String','Attended','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.18+ 0.115 0.97 0.1 0.0241],'EdgeColor','none','String','Ignored','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.33+ 0.115 0.97 0.3 0.0241],'EdgeColor','none','String','Attended - Ignored','fontSize',14,'fontWeight','bold');

% Attend Left; Left: 12 Hz; Right: 16 Hz;
elpsL = annotation('ellipse',[0.1220 0.9 0.0216 0.0194]); elpsR = annotation('ellipse',[0.1638 0.9 0.0216 0.0194]);
elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
annotation('textbox',[0.1172 0.9266 0.04 0.0241],'EdgeColor','none','String','12 Hz','fontSize',12);
annotation('textbox',[0.1590 0.9266 0.04 0.0241],'EdgeColor','none','String','16 Hz','fontSize',12);

% Attend Right; Left: 12 Hz; Right: 16 Hz;
elpsL = annotation('ellipse',[0.18+0.1220 0.9 0.0216 0.0194]); elpsR = annotation('ellipse',[0.18+0.1638 0.9 0.0216 0.0194]);
elpsL.FaceColor = 'none'; elpsR.FaceColor = 'k';
annotation('textbox',[0.18+0.1172 0.9266 0.04 0.0241],'EdgeColor','none','String','12 Hz','fontSize',12);
annotation('textbox',[0.18+0.1590 0.9266 0.04 0.0241],'EdgeColor','none','String','16 Hz','fontSize',12);

% Attend Left; Left: 16 Hz; Right: 12 Hz;
elpsL = annotation('ellipse',[0.1220 0.9-0.448 0.0216 0.0194]); elpsR = annotation('ellipse',[0.1638 0.9-0.448 0.0216 0.0194]);
elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
annotation('textbox',[0.1172 0.9266-0.448 0.04 0.0241],'EdgeColor','none','String','16 Hz','fontSize',12);
annotation('textbox',[0.1590 0.9266-0.448 0.04 0.0241],'EdgeColor','none','String','12 Hz','fontSize',12);

% Attend Right; Left: 16 Hz; Right: 12 Hz;
elpsL = annotation('ellipse',[0.18+0.1220 0.9-0.448 0.0216 0.0194]); elpsR = annotation('ellipse',[0.18+0.1638 0.9-0.448 0.0216 0.0194]);
elpsL.FaceColor = 'none'; elpsR.FaceColor = 'k';
annotation('textbox',[0.18+0.1172 0.9266-0.448 0.04 0.0241],'EdgeColor','none','String','16 Hz','fontSize',12);
annotation('textbox',[0.18+0.1590 0.9266-0.448 0.04 0.0241],'EdgeColor','none','String','12 Hz','fontSize',12);


annotation('textbox',[0.03 0.825 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'SSVEP Response' 'at 24 Hz'},'fontSize',14);
annotation('textbox',[0.03 0.825-0.225 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'SSVEP Response' 'at 32 Hz'},'fontSize',14);
annotation('textbox',[0.03 0.825-2*0.225 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'SSVEP Response' 'at 24 Hz'},'fontSize',14);
annotation('textbox',[0.03 0.825-3*0.225 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'SSVEP Response' 'at 32 Hz'},'fontSize',14);

% save Figures
if eotCodeIdx == 1
    eotString = 'Hits';
elseif eotCodeIdx == 2
    eotString = 'Misses';
end

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

saveFolder = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\Figures\SRC-Attention\Topoplots\topoPlots-SRCLong-AttendedVsIgnored\');
figName1 = fullfile(saveFolder,[protocolType '_' subString  timeEpoch '_bandPower_', eotString '_tapers_' , num2str(tapers(2))]);
figName2 = fullfile(saveFolder,[protocolType '_' subString  timeEpoch '_SSVEP_', ssvepMethod,'_' eotString '_tapers_' , num2str(tapers(2))]);

if analysisMethodFlag
saveas(hFig1,[figName1 '.fig'])
print(hFig1,[figName1 '.tif'],'-dtiff','-r600')
end
saveas(hFig2,[figName2 '.fig'])
print(hFig2,[figName2 '.tif'],'-dtiff','-r600')

end


%% Accessory Functions

% Process Attend Vs. Ignored TopoPlot data for Static Stimuli
function [attData,ignData,diffData]= getAttendVsIgnored_TopoPlotPowerData_StaticStimuli(data,rhythmIDs,topoPlotStyle,subjectIdx,eotCodeIdx,nanFlag)

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

if strcmp(topoPlotStyle,'LeftVsRight')
    attLoc = 2; ign_AttLoc = 1; att_TF = 1; ign_AttTF = 1;
elseif strcmp(topoPlotStyle,'RightVsLeft')
    attLoc = 1; ign_AttLoc = 2; att_TF = 1; ign_AttTF = 1;
end

for iRhythm = 1:length(topoData)
    attData{iRhythm}= squeeze(mean(log10(topoData{iRhythm}(subjectIdx,:,eotCodeIdx,attLoc,att_TF)),1,nanFlag));
    ignData{iRhythm} = squeeze(mean(log10(topoData{iRhythm}(subjectIdx,:,eotCodeIdx,ign_AttLoc,ign_AttTF)),1,nanFlag));
    diffData{iRhythm} = attData{iRhythm} - ignData{iRhythm};
end

end

% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions
function [attData,ignData,diffData]= getAttendVsIgnoredCombinedData_StaticStimuli(data,refType,topoPlotStyle,subjectIdx,eotCodeIdx,nanFlag,elecsLeft,elecsRight)

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left

attData_all = cell(1,length(attendLocs));
ignData_all = cell(1,length(attendLocs));
diffData_all = cell(1,length(attendLocs));

if strcmp(topoPlotStyle,'LeftVsRight')
    attLoc = 2; ign_AttLoc = 1; att_TF = 1; ign_AttTF = 1; elecNums = elecsRight{1};
elseif strcmp(topoPlotStyle,'RightVsLeft')
    attLoc = 1; ign_AttLoc = 2; att_TF = 1; ign_AttTF = 1; elecNums = elecsLeft{1};
end

attDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx,attLoc,att_TF,:));
ignDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx,ign_AttLoc,ign_AttTF,:));
        

attData = squeeze(mean(attDataTMP,2,nanFlag));
ignData = squeeze(mean(ignDataTMP,2,nanFlag));
diffData = attData-ignData;

% attData = squeeze(mean(cat(2,attData_all{1},attData_all{2}),2,nanFlag));
% ignData = squeeze(mean(cat(2,ignData_all{1},ignData_all{2}),2,nanFlag));
% diffData = squeeze(mean(cat(2,diffData_all{1},diffData_all{2}),2,nanFlag));


end

% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions for Analysis Electrodes for Static Stimuli

function [attData,ignData]= getAttendVsIgnored_BarPlotData_StaticStimuli(rmsERPData,powerData,topoPlotStyle,rhythmIDs,subjectIdx,eotCodeIdx,nanFlag,elecsLeft,elecsRight)

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

attData_all = cell(1,length(attendLocs));
ignData_all = cell(1,length(attendLocs));
diffData_all = cell(1,length(attendLocs));

if strcmp(topoPlotStyle,'LeftVsRight')
    attLoc = 2; ign_AttLoc = 1; att_TF = 1; ign_AttTF = 1; elecNums = elecsRight;
elseif strcmp(topoPlotStyle,'RightVsLeft')
    attLoc = 1; ign_AttLoc = 2; att_TF = 1; ign_AttTF = 1; elecNums = elecsLeft;
end
        
        

for iDataType = 1: length(data)
    if iDataType == 5 || iDataType == 6
        elecs = elecNums{2};
    else
        elecs = elecNums{1};
    end
    attData{iDataType} = squeeze(mean(data{iDataType}(subjectIdx,elecs,eotCodeIdx,attLoc,att_TF),2,nanFlag));
    ignData{iDataType} = squeeze(mean(data{iDataType}(subjectIdx,elecs,eotCodeIdx,ign_AttLoc,ign_AttTF),2,nanFlag));
end
        
% 
% if strcmp(topoPlotStyle,'LeftVsRight')
%     attData = squeeze(mean(attData_all{2},2,nanFlag));
%     ignData = squeeze(mean(ignData_all{2},2,nanFlag));
%     diffData = attData-ignData;
% elseif strcmp(topoPlotStyle,'RightVsLeft')
%     attData = squeeze(mean(attData_all{1},2,nanFlag));
%     ignData = squeeze(mean(ignData_all{1},2,nanFlag));
%     diffData = attData-ignData;
% end

end


% Process Attend Vs. Ignored TopoPlot data for Flickering Stimuli
function [attData,ignData,diffData]= getAttendVsIgnored_TopoPlotPowerData_FlickerStimuli(data,rhythmIDs,refType,subjectIdx,eotCodeIdx,nanFlag)

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
ssvepFreqs = [1 2]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz

attData = cell(length(attendLocs),length(ssvepFreqs));
ignData = cell(length(attendLocs),length(ssvepFreqs));
diffData = cell(length(attendLocs),length(ssvepFreqs));

for iAttendLoc = 1:2
    for iSSVEPFreq = 1:2
        condition = str2double(strcat(num2str(iAttendLoc),num2str(iSSVEPFreq)));
        switch(condition)
            case 21
                attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3; 
            case 22
                attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2; 
            case 11
                attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3; 
            case 12
                attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2; 
        end
        
        attDataTMP = squeeze(mean(log10(data{refType}{rhythmIDs(iSSVEPFreq)}(subjectIdx,:,eotCodeIdx,attLoc,att_TF)),1,nanFlag));
        ignDataTMP = squeeze(mean(log10(data{refType}{rhythmIDs(iSSVEPFreq)}(subjectIdx,:,eotCodeIdx,ign_AttLoc,ign_AttTF)),1,nanFlag));
        diffDataTMP = attDataTMP - ignDataTMP;

        attData{iAttendLoc,iSSVEPFreq} = attDataTMP; 
        ignData{iAttendLoc,iSSVEPFreq} = ignDataTMP;
        diffData{iAttendLoc,iSSVEPFreq} = diffDataTMP;
    end
end

end


% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions
function [attData,ignData,diffData]= getAttendVsIgnoredCombinedData_FlickerStimuli(data,refType,subjectIdx,eotCodeIdx,nanFlag,elecsLeft,elecsRight)

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
                attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3; elecNums = elecsRight{1};
            case 22
                attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2; elecNums = elecsRight{1};
            case 11
                attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3; elecNums = elecsLeft{1};
            case 12
                attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2; elecNums = elecsLeft{1};
        end
        
        attDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx,attLoc,att_TF,:));
        ignDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx,ign_AttLoc,ign_AttTF,:));
        diffDataTMP = attDataTMP-ignDataTMP ;
        
        attData_all{iAttendLoc,iSSVEPFreq} = attDataTMP; 
        ignData_all{iAttendLoc,iSSVEPFreq} = ignDataTMP;
        diffData_all{iAttendLoc,iSSVEPFreq} = diffDataTMP;
    end
end

for i=1:2
attData{i} = squeeze(mean(cat(2,attData_all{1,i},attData_all{2,i}),2,nanFlag));
ignData{i} = squeeze(mean(cat(2,ignData_all{1,i},ignData_all{2,i}),2,nanFlag));
diffData{i} = squeeze(mean(cat(2,diffData_all{1,i},diffData_all{2,i}),2,nanFlag));
end

end

% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions for Analysis Electrodes

function [attData,ignData]= getAttendVsIgnored_BarPlotData_FlickerStimuli(rmsERPData,powerData,rhythmIDs,subjectIdx,eotCodeIdx,nanFlag,elecsLeft,elecsRight)

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
                attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3; elecNums = elecsRight;
            case 22
                attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2; elecNums = elecsRight;
            case 11
                attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3; elecNums = elecsLeft;
            case 12
                attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2; elecNums = elecsLeft;
        end
        
        for iDataType = 1: length(data)
            if iDataType == 5 || iDataType == 6
                elecs = elecNums{2};
            else
                elecs = elecNums{1};
            end
            attDataTMP{iDataType} = data{iDataType}(subjectIdx,elecs,eotCodeIdx,attLoc,att_TF); 
            ignDataTMP{iDataType} = data{iDataType}(subjectIdx,elecs,eotCodeIdx,ign_AttLoc,ign_AttTF); 
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




