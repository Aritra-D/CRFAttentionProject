function displayResults_HitsVsMisses_StaticResults...
    (protocolType,analysisMethodFlag,...
    subjectIdx,timeEpoch,removeBadElectrodeData,...
    BaselineCondition,topoplot_style,colorMap) %#ok<*INUSL,*INUSD>

close all;
if ~exist('gridType','var');            gridType='EEG';      end
capType = 'actiCap64';
numFreqs = 7;

fileName = 'E:\HitsVsMissesData_bootstrap_10.mat';

if exist(fileName, 'file')
    load(fileName) %#ok<*LOAD>
else
    error('File not Found!')
end


if  all(subjectIdx<8) % First Set of Recording- Nov-Dec 2021
    freqRanges{1} = [8 12];    % alpha
    freqRanges{2} = [25 70];   % gamma
    freqRanges{3} = [23 23];   % SSVEP Left Stim; Flicker Freq moved by 0.5 Hz due one extra blank Frame
    freqRanges{4} = [31 31];   % SSVEP Right Stim; Flicker Freq moved by 0.5 Hz due one extra blank Frame
    freqRanges{5} = [26 34];   % Slow Gamma
    freqRanges{6} = [44 56];   % Fast Gamma
    freqRanges{7} = [102 250]; % High Gamma
    
else                   % Second Set of Recording- Jan-Mar 2022
    freqRanges{1} = [8 12];    % alpha
    freqRanges{2} = [25 70];   % gamma
    freqRanges{3} = [24 24];   % SSVEP Left Stim; Flicker Freq bug Fixed
    freqRanges{4} = [32 32];   % SSVEP Right Stim; Flicker Freq bug Fixed
    freqRanges{5} = [26 34];   % Slow Gamma
    freqRanges{6} = [44 56];   % Fast Gamma
    freqRanges{7} = [102 250]; % High Gamma
end
numFreqs = length(freqRanges);


% Replace the PSD and power Values if trial avg  PSD and power is plotted
if analysisMethodFlag
    clear energyData.dataBL energyData.dataST energyData.dataTG
    clear energyData.analysisDataBL energyData.analysisDataST energyData.analysisDataTG
    for iRef = 1:2
        psdData.dataBL{iRef} = psdData.dataBL_trialAvg{iRef};
        psdData.dataTG{iRef} = psdData.dataTG_trialAvg{iRef};
        
        psdData.analysisDataBL{iRef} = psdData.analysisDataBL_trialAvg{iRef};
        psdData.analysisDataTG{iRef} = psdData.analysisDataTG_trialAvg{iRef};
    end
end

% remove Bad Electrodes- converting the data for bad Elecs to NaN
if removeBadElectrodeData
    for iSub = 1:length(subjectIdx)
        for iRef = 1:2
            clear badElecsTMP
            badElecsTMP = badElecs{iRef}{subjectIdx(iSub)}; %#ok<USENS>
            
            % removing Energy data (PSD & Power) for Bad Electrodes
            psdData.dataBL{iRef}(:,subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            psdData.dataTG{iRef}(:,subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            psdData.dataBL_trialAvg{iRef}(:,subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            psdData.dataTG_trialAvg{iRef}(:,subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            
            
            for iFreqRanges = 1: numFreqs
                psdData.analysisDataBL{iRef}{iFreqRanges}(:,subjectIdx(iSub),badElecsTMP,:) = NaN;
                psdData.analysisDataTG{iRef}{iFreqRanges}(:,subjectIdx(iSub),badElecsTMP,:) = NaN;
                psdData.analysisDataBL_trialAvg{iRef}{iFreqRanges}(:,subjectIdx(iSub),badElecsTMP,:) = NaN;
                psdData.analysisDataTG_trialAvg{iRef}{iFreqRanges}(:,subjectIdx(iSub),badElecsTMP,:) = NaN;
                
            end
        end
    end
end

nanFlag = 'omitnan';

% Plots
hFig1 = figure(1); colormap(colorMap)
set(hFig1,'units','normalized','outerPosition',[0 0 1 1]);
hPlot1 = getPlotHandles(4,3,[0.05 0.07, 0.5 0.85],0.02,0.04,0);
hPlot2 = getPlotHandles(4,2,[0.59 0.07, 0.18 0.86],0.035,0.04,0);
hPlot3 = getPlotHandles(4,2,[0.81 0.07, 0.18 0.86],0.035,0.04,0);

if BaselineCondition
    cLimsRaw = [-2 2]; % range in dB
    cLimsDiff = [-1 2]; % range in dB
else
    cLimsRaw = [-1 2]; % range in log10 scale
    cLimsDiff = [-1 2]; % range in log10 scale
end

fontSizeLarge = 14; tickLengthMedium = [0.025 0];

showMode = 'dots';
showOccipitalElecsUnipolarLeft = [24 29 57 61];
showOccipitalElecsUnipolarRight = [26 31 58 63];
showOccipitalElecsBipolarLeft = [93 94 101];
showOccipitalElecsBipolarRight = [96 97 102];
showOccipitalElecsUnipolar = [showOccipitalElecsUnipolarLeft showOccipitalElecsUnipolarRight];
showOccipitalElecsBipolar = [showOccipitalElecsBipolarLeft showOccipitalElecsBipolarRight];

showOccipitalElecsLeft{1} = showOccipitalElecsUnipolarLeft;
showOccipitalElecsLeft{2} = showOccipitalElecsBipolarLeft;
showOccipitalElecsRight{1} = showOccipitalElecsUnipolarRight;
showOccipitalElecsRight{2} = showOccipitalElecsBipolarRight;

showFrontalElecsUnipolarLeft = [8 9 43];%[1 33 34 3 37 4];
showFrontalElecsUnipolarRight = [10 11 44]; %[2 35 36 6 40 7];
showFrontalElecsBipolarLeft = [25 33 34 41 42];%[1 2 5 7 8 9 10 15 16 17];
showFrontalElecsBipolarRight = [28 35 36 43 44];%[3 4 6 11 12 13 14 20 21 22];
showFrontalElecsUnipolar = [showFrontalElecsUnipolarLeft showFrontalElecsUnipolarRight];
showFrontalElecsBipolar = [showFrontalElecsBipolarLeft showFrontalElecsBipolarRight];

showFrontalElecsLeft{1} = showFrontalElecsUnipolarLeft;
showFrontalElecsLeft{2} = showFrontalElecsBipolarLeft;
showFrontalElecsRight{1} = showFrontalElecsUnipolarRight;
showFrontalElecsRight{2} = showFrontalElecsBipolarRight;


% Get the electrode list
capLayout = {'actiCap64'};
cL_Unipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages',...
    'Layouts',capLayout{1},[capLayout{1} '.mat']));
chanlocs_Unipolar = cL_Unipolar.chanlocs;

cL_Bipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages',...
    'Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
bL = load(fullfile(pwd,'programs\ProgramsMAP','Montages',...
    'Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat'])); %#ok<*NASGU>
chanlocs_Bipolar = cL_Bipolar.eloc;

if strcmp(timeEpoch,'StimOnset')
    powerData = psdData.analysisDataST;
    powerDataBL = psdData.analysisDataBL;
    psdDataTMP = psdData.dataST;
    psdDataBLTMP = psdData.dataBL;
elseif strcmp(timeEpoch,'PreTarget')
    powerData = psdData.analysisDataTG;
    powerDataBL = psdData.analysisDataBL;
    psdDataTMP = psdData.dataTG;
    psdDataBLTMP = psdData.dataBL;
end

% topoPlotType = 'LeftVsRight'; % rhythmIDs = [1 3 4 5 6];

% hFig2 = figure(2); colormap(colorMap)
% set(hFig2,'units','normalized','outerPosition',[0 0 1 1]);
% hPlot1 = getPlotHandles(2,3,[0.07 0.5, 0.45 0.42],0.02,0.02,0);
% hPlot2 = getPlotHandles(2,3,[0.07 0.01, 0.45 0.42],0.02,0.02,0);
% hPlot3 = getPlotHandles(1,3,[0.58 0.56, 0.42 0.3],0.04,0.02,0);
% hPlot4 = getPlotHandles(1,3,[0.58 0.07, 0.42 0.3],0.04,0.02,0);
fontSize = 12;

count = 1;
for i=1:2
    
    if i==1
        rhythmIDs = [1 1];
        refType = 1;
        if analysisMethodFlag
            if strcmp(BaselineCondition,'none')
                cLimsSSVEPRaw = [-3 -1];
                cLimsSSVEPDiff = [-2 5];
            else
                cLimsSSVEPRaw = [-2 2];
                cLimsSSVEPDiff = [-1 2];
            end
        else
            if strcmp(BaselineCondition,'none')
                cLimsSSVEPRaw = [-1 3];
                cLimsSSVEPDiff = [-1 1];
            else
                cLimsSSVEPRaw = [-2 2];
                cLimsSSVEPDiff = [-1 2];
            end
        end
    elseif i==2
        rhythmIDs = [2 2];
        refType = 2;
        if analysisMethodFlag
            if strcmp(BaselineCondition,'none')
                cLimsSSVEPRaw = [-2 -1];
                cLimsSSVEPDiff = [-2 2];
            else
                cLimsSSVEPRaw = [-2 2];
                cLimsSSVEPDiff = [-1 2];
            end
        else
            if strcmp(BaselineCondition,'none')
                cLimsSSVEPRaw = [-2 1];
                cLimsSSVEPDiff = [-1 1];
                
            else
                cLimsSSVEPRaw = [-2 2];
                cLimsSSVEPDiff = [-1 2];
            end
        end
        
        
    end
    
    
    
    [HitsData_Topo,MissesData_Topo]= ...
        getHitsVsMisses_TopoPlotPowerData_FlickerStimuli...
        (powerData,rhythmIDs,refType,subjectIdx,nanFlag);
    
    [HitsDataBL_Topo,MissesDataBL_Topo]= ...
        getHitsVsMisses_TopoPlotPowerData_FlickerStimuli...
        (powerDataBL,rhythmIDs,refType,subjectIdx,nanFlag);
    
    for iPlot = 1:2
        if i==1 && iPlot==1
            showElecIDs = [showOccipitalElecsUnipolarRight showFrontalElecsUnipolarRight];
            chanLocs = chanlocs_Unipolar;
        elseif i==1 && iPlot==2
            showElecIDs = [showOccipitalElecsUnipolarLeft showFrontalElecsUnipolarLeft];
            chanLocs = chanlocs_Unipolar;
        elseif i==2 && iPlot==1
            showElecIDs = [showOccipitalElecsBipolarRight showFrontalElecsBipolarRight];
            chanLocs = chanlocs_Bipolar;
        elseif i==2 && iPlot==2
            showElecIDs = [showOccipitalElecsBipolarLeft showFrontalElecsBipolarLeft];
            chanLocs = chanlocs_Bipolar;
        end
        
        if strcmp(BaselineCondition,'Hits')
            topoPlot_Attended =  10*(HitsData_Topo{1,iPlot}-HitsDataBL_Topo{1,iPlot});
            topoPlot_Ignored = 10*(MissesData_Topo{1,iPlot}-HitsDataBL_Topo{1,iPlot});
            topoPlot_AttendedMinusIgnored = topoPlot_Attended-topoPlot_Ignored;
        elseif strcmp(BaselineCondition,'Misses')
            topoPlot_Attended =  10*(HitsData_Topo{1,iPlot}-MissesDataBL_Topo{1,iPlot});
            topoPlot_Ignored = 10*(MissesData_Topo{1,iPlot}-MissesDataBL_Topo{1,iPlot});
            topoPlot_AttendedMinusIgnored = topoPlot_Attended-topoPlot_Ignored;
        elseif strcmp(BaselineCondition,'Respective')
            topoPlot_Attended =  10*(HitsData_Topo{1,iPlot}-HitsDataBL_Topo{1,iPlot});
            topoPlot_Ignored = 10*(MissesData_Topo{1,iPlot}-MissesDataBL_Topo{1,iPlot});
            topoPlot_AttendedMinusIgnored = topoPlot_Attended-topoPlot_Ignored;
        elseif strcmp(BaselineCondition,'none')
            topoPlot_Attended =  HitsData_Topo{1,iPlot};
            topoPlot_Ignored = MissesData_Topo{1,iPlot};
            topoPlot_AttendedMinusIgnored = 10*(topoPlot_Attended-topoPlot_Ignored);
        end
        
        
        tickPlotLength = get(hPlot1(1,1),'TickLength');
        subplot(hPlot1(count,1)); cla; hold on;
        topoplot_murty(topoPlot_Attended,chanLocs,'electrodes','on',...
            'style',topoplot_style,'drawaxis','off','nosedir','+X',...
            'emarkercolors',topoPlot_Attended);
        caxis(cLimsSSVEPRaw);    cBar_Att = colorbar; cTicks = [cLimsSSVEPRaw(1) 0:cLimsSSVEPRaw(2)/2:cLimsSSVEPRaw(2)];
        set(cBar_Att,'Ticks',cTicks,'tickLength',3*tickPlotLength(1),'TickDir','out','fontSize',fontSize);
        
        topoplot_murty([],chanLocs,'electrodes','on',...
            'style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
        
        subplot(hPlot1(count,2)); cla; hold on;
        topoplot_murty(topoPlot_Ignored,chanLocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Ignored);
        caxis(cLimsSSVEPRaw); cBar_Ign = colorbar; cTicks = [cLimsSSVEPRaw(1) 0:cLimsSSVEPRaw(2)/2:cLimsSSVEPRaw(2)];
        set(cBar_Ign,'Ticks',cTicks,'tickLength',3*tickPlotLength(1),'TickDir','out','fontSize',fontSize);
        
        topoplot_murty([],chanLocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
        
        subplot(hPlot1(count,3)); cla; hold on;
        topoplot_murty(topoPlot_AttendedMinusIgnored,chanLocs,...
            'electrodes','on','style',topoplot_style,'drawaxis','off',...
            'nosedir','+X','emarkercolors',topoPlot_AttendedMinusIgnored);
        caxis(cLimsSSVEPDiff);   cBar_Diff = colorbar; cTicks = [cLimsSSVEPDiff(1) 0 cLimsSSVEPDiff(2)];
        set(cBar_Diff,'Ticks',cTicks,'tickLength',3*tickPlotLength(1),'TickDir','out','fontSize',fontSize);
        if iPlot==4
            cBar_Diff.Label.String ='\Delta Power (dB)'; cBar_Diff.Label.FontSize = 14;
        end
        
        topoplot_murty([],chanLocs,'electrodes','on',...
            'style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
        count = count+1;
    end
end

textStartPosGapFromMidline = 0.02;
textWidth = 0.15; textHeight = 0.025;
textGap = 0.26;
topoPlotLabels = {'Hits','Misses','Hits - Misses'};

annotation('textbox',[0.11 0.97 0.1 0.0241],'EdgeColor','none','String','Hits','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.17+ 0.12 0.97 0.1 0.0241],'EdgeColor','none','String','Misses','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.35+ 0.1 0.97 0.3 0.0241],'EdgeColor','none','String','Hits - Misses','fontSize',14,'fontWeight','bold');

textH2 = getPlotHandles(1,1,[0.03 0.6 0.01 0.01]);
textString1 = {'Alpha (8-12 Hz)'};
set(textH2,'Visible','Off');
text(0.35,1.15,textString1,'unit','normalized','fontsize',18,'fontweight','bold','rotation',90,'parent',textH2);

textH2 = getPlotHandles(1,1,[0.03 0.15 0.01 0.01]);
textString1 = {'Gamma (25-70 Hz)'};
set(textH2,'Visible','Off');
text(0.35,1.15,textString1,'unit','normalized','fontsize',18,'fontweight','bold','rotation',90,'parent',textH2);


% Stim TF: Left 12 Hz; Right 16 Hz; Attended Left: 12 Hz; Ignored Left: 12 Hz;
attLoc{1,1} = 1;
attLoc{1,2} = 1;
attLoc{2,1} = 2;
attLoc{2,2} = 2;
attLoc{3,1} = 1;
attLoc{3,2} = 1;
attLoc{4,1} = 2;
attLoc{4,2} = 2;

% ssvepFreqs{1,1} = [12 16];
% ssvepFreqs{1,2} = [12 16];
% ssvepFreqs{2,1} = [16 12];
% ssvepFreqs{2,2} = [16 12];
% ssvepFreqs{3,1} = [16 12];
% ssvepFreqs{3,2} = [16 12];
% ssvepFreqs{4,1} = [12 16];
% ssvepFreqs{4,2} = [12 16];
% ssvepFreqs{5,1} = [];
% ssvepFreqs{5,2} = [];

for i=1:4
    for j=1:2
        plotStimDisks(hPlot1(i,j),attLoc{i,j})
    end
end



% % get ERP Data for Attended and Ignored Conditions for Flicker Stimuli
% [attData_erp,ignData_erp]= getAttendVsIgnoredCombinedData_FlickerStimuli...
%     (ERPData,refType,subjectIdx,eotCodeIdx,nanFlag,showElecsLeft,showElecsRight);

% get PSD Data for Attended and Ignored Conditions for Flicker Stimuli

for i=1:2
    refType = i;
    for iElecgroup = 1:2 % 1: Occipital PSD, 2: Frontal PSD
        count = 1;
        clear attData_psd ignData_psd attDataBL_psd ignDataBL_psd
        switch iElecgroup
            case 1
                elecsLeft = showOccipitalElecsLeft;
                elecsRight = showOccipitalElecsRight;
                hPlot = hPlot2(:,1);
            case 2
                elecsLeft = showFrontalElecsLeft;
                elecsRight = showFrontalElecsRight;
                hPlot = hPlot3(:,1);
        end
        [HitsData_psd,MissesData_psd]= getHitsVsMissesCombinedData_FlickerStimuli...
            (psdDataTMP,refType,subjectIdx,nanFlag,elecsLeft,elecsRight);
        [HitsDataBL_psd,MissesDataBL_psd]= getHitsVsMissesCombinedData_FlickerStimuli...
            (psdDataBLTMP,refType,subjectIdx,nanFlag,elecsLeft,elecsRight);
        
        for iPlot= 1:2
            psd_Att = squeeze(mean(log10(mean(HitsData_psd(iPlot,:,:,:),3,nanFlag)),2,nanFlag));
            psd_Ign = squeeze(mean(log10(mean(MissesData_psd(iPlot,:,:,:),3,nanFlag)),2,nanFlag));
            psdBL_Att = squeeze(mean(log10(mean(HitsDataBL_psd(iPlot,:,:,:),3,nanFlag)),2,nanFlag));
            psdBL_Ign = squeeze(mean(log10(mean(MissesDataBL_psd(iPlot,:,:,:),3,nanFlag)),2,nanFlag));
            diffPSD = 10*(psd_Att-psd_Ign);
            
            plot(hPlot(2*(i-1)+count,1),psdData.freqVals,psd_Att,'r'); hold(hPlot(2*(i-1)+count,1),'on');
            plot(hPlot(2*(i-1)+count,1),psdData.freqVals,psd_Ign,'b');
            plot(hPlot(2*(i-1)+count,1),psdData.freqVals,psdBL_Att,'k');
            plot(hPlot(2*(i-1)+count,1),psdData.freqVals,psdBL_Ign,'--k');
            plot(hPlot(2*(i-1)+count,1),psdData.freqVals,diffPSD,'k');
            xlim(hPlot(2*(i-1)+count,1),[0 72])
            ylim(hPlot(2*(i-1)+count,1),[-4 4])
            count = count+1;
        end
    end
end

% get rmsERP Data and power Data for Selective Analysis Electrodes
% for Attended and Ignored Conditions for Flicker Stimuli

colors = {'k','r','c'};

for iElecGroup = 1:2
    rhythmIDs = [1 2];
    switch iElecGroup
        case 1
            elecsLeft = showOccipitalElecsLeft;
            elecsRight = showOccipitalElecsRight;
            hPlot = hPlot2(:,2);
        case 2
            elecsLeft = showFrontalElecsLeft;
            elecsRight = showFrontalElecsRight;
            hPlot = hPlot3(:,2);
    end
    
    [HitsAnalysisData,MissesAnalysisData]= ...
        getHitsVsMisses_BarPlotData_FlickerStimuli(powerData,....
        rhythmIDs,subjectIdx,nanFlag,elecsLeft,elecsRight);
    
    [HitsAnalysisDataBL,MissesAnalysisDataBL]= ...
        getHitsVsMisses_BarPlotData_FlickerStimuli(powerDataBL,....
        rhythmIDs,subjectIdx,nanFlag,elecsLeft,elecsRight);
    
    dataIDs = [1 2];
    
    for iRef = 1:2
        for iPlot = 1:2
            for iBar = 1:length(dataIDs)
                HitsTMP = squeeze(mean(HitsAnalysisData{2*(iRef-1)+iBar}(iPlot,:,:),3,nanFlag));
                MissesTMP = squeeze(mean(MissesAnalysisData{2*(iRef-1)+iBar}(iPlot,:,:),3,nanFlag));
                HitsBLTMP = squeeze(mean(HitsAnalysisDataBL{2*(iRef-1)+iBar}(iPlot,:,:),3,nanFlag));
                MissesBLTMP = squeeze(mean(MissesAnalysisDataBL{2*(iRef-1)+iBar}(iPlot,:,:),3,nanFlag));
                if strcmp(BaselineCondition,'Hits')
                    HitsData = log10(HitsTMP)-log10(HitsBLTMP);
                    MissesData = log10(MissesTMP)-log10(HitsBLTMP);
                elseif strcmp(BaselineCondition,'Misses')
                    HitsData = log10(HitsTMP)-log10(MissesBLTMP);
                    MissesData = log10(MissesTMP)-log10(MissesBLTMP);
                elseif strcmp(BaselineCondition,'Respective')
                    HitsData = log10(HitsTMP)-log10(HitsBLTMP);
                    MissesData = log10(MissesTMP)-log10(MissesBLTMP);
                elseif strcmp(BaselineCondition,'none')
                    HitsData = log10(HitsTMP);
                    MissesData = log10(MissesTMP);
                end
                diffData = 10*(HitsData-MissesData); %dB
                mBar = mean(diffData,2,nanFlag);
                errorBar = std(diffData,[],2,nanFlag)./sqrt(length(diffData));
                
                mBars(iBar) = mBar; %#ok<*AGROW>
                eBars(iBar) = errorBar;
                
                subplot(hPlot(2*(iRef-1)+iPlot,1));hold(hPlot(2*(iRef-1)+iPlot,1),'on');
                barPlot = bar(iBar,mBar);
                barPlot.FaceColor = colors{iBar};
                ylim(hPlot(2*(iRef-1)+iPlot,1),[-4 4])
                
            end
            errorbar(hPlot(2*(iRef-1)+iPlot,1),1:length(mBars),mBars,eBars,'.','color','k');
        end
    end
end


tickPlotLength = get(hPlot2(1,1),'TickLength');
fontSize = 12;

for i=1:4
    for j=1:2
        set(hPlot2(i,j),'fontSize',fontSize,'box','off','tickLength',2*tickPlotLength,'TickDir','out')
        set(hPlot3(i,j),'fontSize',fontSize,'box','off','tickLength',2*tickPlotLength,'TickDir','out')
    end
end

linkaxes(hPlot2(1:4,1)); xlim(hPlot2(1,1),[0 72]); ylim(hPlot2(1,1),[-4.5 4.5])
linkaxes(hPlot3(1:4,1));  xlim(hPlot2(1,1),[0 72]); ylim(hPlot3(1,1),[-4.5 4.5])

linkaxes(hPlot2(1:4,2)); xlim(hPlot2(1,2),[0 3]); ylim(hPlot2(1,2),[-1.5 1.5])
linkaxes(hPlot3(1:4,2)); xlim(hPlot3(1,2),[0 3]); ylim(hPlot3(1,2),[-1.5 1.5])

Datalabels = {'alpha','gamma'};
for i=1:3
set(hPlot2(i,2),'yTick',[-1 0 1],'xTick',1:2);
set(hPlot3(i,2),'yTick',[-1 0 1],'xTick',1:2);
end

for i=4:4
    set(hPlot2(i,2),'yTick',[-1 0 1],'xTick',1:2,'xTickLabel',Datalabels,'XTickLabelRotation',30);
    set(hPlot3(i,2),'yTick',[-1 0 1],'xTick',1:2,'xTickLabel',Datalabels,'XTickLabelRotation',30);
end

for i=1:4
    set(hPlot2(i,2),'yTick',[-1 0 1]);
    set(hPlot3(i,2),'yTick',[-1 0 1]);
end


lineWidth_lines = 1.3;
for i=1:4
    set(hPlot2(i,1),'yTick',[-4 0 4],'xTick',[0 50 70]);
    set(hPlot3(i,1),'yTick',[-4 0 4],'xTick',[0 50 70]);
    yline(hPlot2(i,1),0,'color',colors{1},'LineWidth',lineWidth_lines)
    yline(hPlot3(i,1),0,'color',colors{1},'LineWidth',lineWidth_lines)
    xline(hPlot2(i,1),8,'color',colors{1},'LineWidth',lineWidth_lines)
    xline(hPlot2(i,1),12,'color',colors{1},'LineWidth',lineWidth_lines)
    xline(hPlot2(i,1),25,'color',colors{2},'LineWidth',lineWidth_lines)
    xline(hPlot2(i,1),70,'color',colors{2},'LineWidth',lineWidth_lines)
    xline(hPlot3(i,1),8,'color',colors{1},'LineWidth',lineWidth_lines)
    xline(hPlot3(i,1),12,'color',colors{1},'LineWidth',lineWidth_lines)
    xline(hPlot3(i,1),25,'color',colors{2},'LineWidth',lineWidth_lines)
    xline(hPlot3(i,1),70,'color',colors{2},'LineWidth',lineWidth_lines)
    
end

ylabel(hPlot2(4,1),'log_1_0 (Power (\muV^2))'); xlabel(hPlot2(4,1),'Frequency (Hz)');
ylabel(hPlot2(4,2),'Change in Power (dB)');

annotation('textbox',[0.63 0.97 0.2 0.0241],'EdgeColor','none','String','Occipital Electrodes','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.85 0.97 0.2 0.0241],'EdgeColor','none','String','Frontal Electrodes','fontSize',14,'fontWeight','bold');
title(hPlot2(1,1),'PSD','fontSize',fontSize);
title(hPlot2(1,2),'\Delta Power','fontSize',fontSize);
title(hPlot3(1,1),'PSD','fontSize',fontSize);
title(hPlot3(1,2),'\Delta Power','fontSize',fontSize);


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

saveFolder = fullfile('E:\','Projects\Aritra_AttentionEEGProject\Figures\SRC-Attention\Topoplots\HitsVsMisses\DistributionMatched');
if ~exist(saveFolder,'dir')
    mkdir(saveFolder)
end
figName1 = fullfile(saveFolder,[protocolType '_' subString  timeEpoch '_StaticStimuli_', '_tapers_1' , ...
    '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz' 'badTrial_' 'v5']);


saveas(hFig1,[figName1 'EyeElecs.fig'])
print(hFig1,[figName1 '.EyeElecs.tif'],'-dtiff','-r600')


end


%% Accessory Functions



% Process Attend Vs. Ignored TopoPlot data for Flickering Stimuli
function [HitsData,MissesData]= ...
    getHitsVsMisses_TopoPlotPowerData_FlickerStimuli...
    (data,rhythmIDs,refType,subjectIdx,nanFlag)

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left

HitsData = cell(1,length(attendLocs));
MissesData = cell(1,length(attendLocs));

for iCount = 1: length(attendLocs)
    switch(iCount)
        case 1
            attLoc = 2; ign_AttLoc = 1; SSVEPFreq = 1; conditionID_Hits = 1; conditionID_Misses = 7;
        case 2
            attLoc = 1; ign_AttLoc = 2; SSVEPFreq = 1; conditionID_Hits = 2; conditionID_Misses = 8;
    end
    
    HitsDataTMP = squeeze(mean(mean(log10(data{refType}{rhythmIDs(SSVEPFreq)}(:,subjectIdx,:,conditionID_Hits)),2,nanFlag),1,nanFlag));
    MissesDataTMP = squeeze(mean(mean(log10(data{refType}{rhythmIDs(SSVEPFreq)}(:,subjectIdx,:,conditionID_Misses)),2,nanFlag),1,nanFlag));
    
    HitsData{iCount} = HitsDataTMP;
    MissesData{iCount} = MissesDataTMP;
end

%  averaged across all conditions and log-averaged over all subjects with AttR conditions mirrored with z-line
% for iCount = 1: length(attendLocs)*length(ssvepFreqs)
%     switch(iCount)
%         case 1
%             attLoc = 2; ign_AttLoc = 1; SSVEPFreq = 1; conditionID_Hits = 3; conditionID_Misses = 9;
%             topoDataTMP = data{refType}{rhythmIDs(SSVEPFreq)};
%         case 2
%             attLoc = 1; ign_AttLoc = 2; SSVEPFreq = 1; conditionID_Hits = 4; conditionID_Misses = 10;
%             topoDataTMP = mirrorTopoplotData(data{refType}{rhythmIDs(SSVEPFreq)},refType);
%         case 3
%             attLoc = 2; ign_AttLoc = 1; SSVEPFreq = 2; conditionID_Hits = 5; conditionID_Misses = 11;
%             topoDataTMP = data{refType}{rhythmIDs(SSVEPFreq)};
%         case 4
%             attLoc = 1; ign_AttLoc = 2; SSVEPFreq = 2; conditionID_Hits = 6; conditionID_Misses = 12;
%             topoDataTMP = mirrorTopoplotData(data{refType}{rhythmIDs(SSVEPFreq)},refType);
%     end
%
%     HitsData_allcondTMP(iCount,:,:,:) = squeeze(topoDataTMP(:,subjectIdx,:,conditionID_Hits));
%     MissesData_allcondTMP(iCount,:,:,:) = squeeze(topoDataTMP(:,subjectIdx,:,conditionID_Misses));
%
% end

% HitsData{length(attendLocs)*length(ssvepFreqs)+1} = squeeze(mean(mean(log10(mean(HitsData_allcondTMP,1,nanFlag)),3,nanFlag),2,nanFlag));
% MissesData{length(attendLocs)*length(ssvepFreqs)+1} = squeeze(mean(mean(log10(mean(MissesData_allcondTMP,1,nanFlag)),3,nanFlag),2,nanFlag));



end



% Process Attend Vs. Ignored PSD data combined for Attend Left and Attend Right
% Conditions
function [HitsData,MissesData]= ...
    getHitsVsMissesCombinedData_FlickerStimuli...
    (data,refType,subjectIdx,nanFlag,elecsLeft,elecsRight) %#ok<*INUSL>

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left

for iCount = 1:length(attendLocs)
    switch iCount
        case 1
            attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3; conditionID_Hits = 1; conditionID_Misses = 7; elecNums = elecsRight;
        case 2
            attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3; conditionID_Hits = 2; conditionID_Misses = 8; elecNums = elecsLeft;
    end
    
    elecs = elecNums{refType};
    
    HitsDataTMP = squeeze(data{refType}(:,subjectIdx,elecs,conditionID_Hits,:));
    MissesDataTMP = squeeze(data{refType}(:,subjectIdx,elecs,conditionID_Misses,:));
    
    HitsData(iCount,:,:,:) = squeeze(mean(HitsDataTMP,1,nanFlag));
    MissesData(iCount,:,:,:) = squeeze(mean(MissesDataTMP,1,nanFlag));
end

end

% Process Attend Vs. Ignored Power data combined for Attend Left and Attend Right
% Conditions for Analysis Electrodes

function [HitsData,MissesData]= ...
    getHitsVsMisses_BarPlotData_FlickerStimuli...
    (powerData,rhythmIDs,subjectIdx,nanFlag,...
    elecsLeft,elecsRight)

dataLabels = {'Alpha Uni Ref.','Slow gamma Uni','Fast Gamma Uni'...
    'Slow gamma Bi','Fast Gamma Bi','SSVEP 23/24 Hz','SSVEP 31/32 Hz'};


refType = 1;
data{1} = powerData{refType}{rhythmIDs(1)}; % Alpha Unipolar Ref
data{2} = powerData{refType}{rhythmIDs(2)}; % Gamma Bipolar Ref

refType = 2;
data{3} = powerData{refType}{rhythmIDs(1)}; % Alpha Unipolar Ref
data{4} = powerData{refType}{rhythmIDs(2)}; % Gamma Bipolar Ref

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left

for iCount = 1:length(attendLocs)
    switch iCount
        case 1
            attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3; conditionID_Hits = 1; conditionID_Misses = 7; elecNums = elecsRight;
        case 2
            attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3; conditionID_Hits = 2; conditionID_Misses = 8; elecNums = elecsLeft;
    end
    
    for iDataType = 1: length(data)
        if iDataType == 3 || iDataType == 4
            elecs = elecNums{2};
        else
            elecs = elecNums{1};
        end
        HitsDataTMP{iDataType}(iCount,:,:) = squeeze(mean(data{iDataType}(:,subjectIdx,elecs,conditionID_Hits),1,nanFlag));
        MissesDataTMP{iDataType}(iCount,:,:) = squeeze(mean(data{iDataType}(:,subjectIdx,elecs,conditionID_Misses),1,nanFlag));
        
    end
end

HitsData = HitsDataTMP;
MissesData = MissesDataTMP;

end


% function mirrored_topoData = mirrorTopoplotData(data,refType)
% if refType ==1
%     mirror_elecNums = [2 1	7	6	5	4	3	11	10	9	8	16	15	14 ...
%         13	12	22	21	20	19	18	17	27	26	25	24	23	32	31	30	29 ...
%         28	36	35	34	33	40	39	38	37	46	45	44	43	42	41	50	49 ...
%         48	47	55	54	53	52	51	59	58	57	56	64	63	62	61	60];
% elseif refType ==2
%     mirror_elecNums = [ 4	3	2	1	6	5	14	13	12	11	10	9	8	7 ...
%         22	21	20	19	18	17	16	15	30	29	28	27	26	25	24	23	38	...
%         37	36	35	34	33	32	31	46	45	44	43	42	41	40	39	54	53	...
%         52	51	50	49	48	47	63	62	61	60	59	58	57	56	55	73	72	...
%         71	70	69	68	67	66	65	64	82	81	80	79	78	77	76	75	74	...
%         90	89	88	87	86	85	84	83	99	98	97	96	95	94	93	92	91	...
%         103	102	101	100	110	109	108	107	106	105	104	112	111];
% end
%
%
% mirrored_topoData = data(:,:,mirror_elecNums,:);
% % for i = 1:size(data,1)
% %         mirrored_topoData2(i,:) = data(i,mirror_elecNums);
% % end
% %
% % for i = 1:size(data,1)
% %     for j = 1:size(data,2)
% %         mirrored_topoData(i,j) = data(i,mirror_elecNums(j));
% %     end
% % end
%
% end

function plotStimDisks(hPlot,attLoc,ssvepFreqs)
stimDiskDistanceFromMidline = 0.01;
textStartPosGapFromMidline = 0.001;
ellipseYGap = 0.185;
ellipseWidth = 0.015;
ellipseHeight = 0.012;
textYGap = 0.195;
textWidth = 0.04;
textHeight = 0.0241;

AttendPlotPos = get(hPlot,'Position');
AttendPlotMidline = AttendPlotPos(1)+ AttendPlotPos(3)/2;
% YLine = annotation('line',[AttendPlotMidline AttendPlotMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline- stimDiskDistanceFromMidline AttendPlotMidline- stimDiskDistanceFromMidline],[0.5 1]);
% YLine = annotation('line',[AttendPlotMidline+ stimDiskDistanceFromMidline AttendPlotMidline+ stimDiskDistanceFromMidline],[0.5 1]);
elpsL = annotation('ellipse',[AttendPlotMidline-ellipseWidth- stimDiskDistanceFromMidline AttendPlotPos(2)+ellipseYGap ellipseWidth ellipseHeight],'units','normalized');
elpsR = annotation('ellipse',[AttendPlotMidline + stimDiskDistanceFromMidline AttendPlotPos(2)+ellipseYGap ellipseWidth ellipseHeight]);

if attLoc==1
    elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
elseif attLoc==2
    elpsL.FaceColor = 'none'; elpsR.FaceColor = 'k';
end

annotation('textbox',[AttendPlotMidline-(textWidth+textStartPosGapFromMidline) AttendPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','Static','fontSize',10,'EdgeColor','none','FitBoxToText','on',...
    'HorizontalAlignment','center');

annotation('textbox',[AttendPlotMidline+textStartPosGapFromMidline AttendPlotPos(2)+textYGap textWidth textHeight],...
    'EdgeColor','none','String','Static','fontSize',10,...
    'EdgeColor','none','FitBoxToText','on','HorizontalAlignment','center');



end





