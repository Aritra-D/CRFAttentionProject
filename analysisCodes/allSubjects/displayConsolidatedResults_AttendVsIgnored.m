% This program change in Power wrt to Baseline Topoplots for static
% and flickering stimuli, ERP,PSD and Delta Power Changes for attended and
% Ignored conditions

function displayConsolidatedResults_AttendVsIgnored(protocolType,...
    subjectIdx,timeEpoch,eotCodeIdx,removeBadElectrodeData,...
    plotBaselineSubtractedPowerFlag,topoplot_style,colorMap,badTrialStr,statTest)

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

fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',[protocolType '_tapers_' num2str(tapers(2)) ...
    '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz_' 'badTrial_' badTrialStr '.mat']);

if exist(fileName, 'file')
    load(fileName,'erpData','energyData','badElecs','badHighPriorityElecs') %#ok<*LOAD>
else
    [erpData,fftData,energyData,freqRanges_SubjectWise,badHighPriorityElecs,badElecs] = ...
        getData_SRCLongProtocols_v1(protocolType,gridType,timingParamters,tapers,badTrialStr);
    save(fileName,'erpData','fftData','energyData','freqRanges_SubjectWise','badHighPriorityElecs','badElecs')
end


% Replace the PSD and power Values if trial avg  PSD and power is plotted
% if analysisMethodFlag
%     clear energyData.dataBL energyData.dataST energyData.dataTG
%     clear energyData.analysisDataBL energyData.analysisDataST energyData.analysisDataTG
%     for iRef = 1:2
%         energyData.dataBL{iRef} = energyData.dataBL_trialAvg{iRef};
%         energyData.dataST{iRef} = energyData.dataST_trialAvg{iRef};
%         energyData.dataTG{iRef} = energyData.dataTG_trialAvg{iRef};
%         
%         energyData.analysisDataBL{iRef} = energyData.analysisDataBL_trialAvg{iRef};
%         energyData.analysisDataST{iRef} = energyData.analysisDataST_trialAvg{iRef};
%         energyData.analysisDataTG{iRef} = energyData.analysisDataTG_trialAvg{iRef};
%     end
% end

% remove Bad Electrodes- converting the data for bad Elecs to NaN
declaredBadElectrodes = [8 9 10 11 43 44];
if removeBadElectrodeData
    for iSub = 1:length(subjectIdx)
        for iRef = 1:2
            clear badElecsTMP
%             if subjectIdx(iSub)>7
                badElecsTMP = union(badElecs{iRef}{subjectIdx(iSub)},declaredBadElectrodes);
%             else
%                 badElecsTMP = badElecs{iRef}{subjectIdx(iSub)};
%             end
                
            
            % removing ERP data for Bad Electrodes
            erpData.dataST{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            erpData.dataTG{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            erpData.analysisData_BL{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
            erpData.analysisData_ST{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
            erpData.analysisData_TG{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
            
            % removing Energy data (PSD & Power) for Bad Electrodes
            energyData.dataBL{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            energyData.dataST{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            energyData.dataTG{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            energyData.dataBL_trialAvg{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            energyData.dataST_trialAvg{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            energyData.dataTG_trialAvg{iRef}(subjectIdx(iSub),badElecsTMP,:,:,:,:) = NaN;
            
            for iFreqRanges = 1: length(freqRanges)
                energyData.analysisDataBL{iRef}{iFreqRanges}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
                energyData.analysisDataST{iRef}{iFreqRanges}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
                energyData.analysisDataTG{iRef}{iFreqRanges}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
                energyData.analysisDataBL_trialAvg{iRef}{iFreqRanges}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
                energyData.analysisDataST_trialAvg{iRef}{iFreqRanges}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
                energyData.analysisDataTG_trialAvg{iRef}{iFreqRanges}(subjectIdx(iSub),badElecsTMP,:,:,:) = NaN;
            end
        end
    end
end

nanFlag = 'omitnan';

% Plots
hFig1 = figure(1); colormap(colorMap)
set(hFig1,'units','normalized','outerPosition',[0 0 1 1]);
hPlot1 = getPlotHandles(4,3,[0.05 0.05, 0.5 0.85],0.005,0.04,0);
hPlot2 = getPlotHandles(3,2,[0.59 0.07, 0.18 0.86],0.035,0.07,0);
hPlot3 = getPlotHandles(3,2,[0.81 0.07, 0.18 0.86],0.035,0.07,0);
tickPlotLength = get(hPlot2(1,1),'TickLength');


if plotBaselineSubtractedPowerFlag
    cLims{1} = [-2 2]; % range in dB
    cLims{2} = [-1 1.5]; % range in dB
    cLims{3} = [-1 2];
    cLims{4} = [-1 10];
    cLimsDiff{1} = [-1 2]; % range in dB
    cLimsDiff{2} = [-1 1.5]; % range in dB
    cLimsDiff{3} = [0 1]; % range in dB
    cLimsDiff{4} = [0 4]; % range in dBelse
else
    cLims{1} = [-2 2]; % range in dB
    cLims{2} = [-1 1.5]; % range in dB
    cLims{3} = [-1 2];
    cLims{4} = [-1 10];
    cLimsDiff{1} = [-1 2]; % range in dB
    cLimsDiff{2} = [-1 1.5]; % range in dB
    cLimsDiff{3} = [0 1]; % range in dB
    cLimsDiff{4} = [0 4]; % range in dBelse
end

fontSize = 14; tickLengthMedium = [0.025 0];

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

showFrontalElecsUnipolarLeft = [1 33 34 3 37 4]; %[8 9 43];
showFrontalElecsUnipolarRight =[2 35 36 6 40 7]; % [10 11 44];
showFrontalElecsBipolarLeft = [1 2 5 7 8 9 10 15 16 17]; %[25 33 34 41 42]
showFrontalElecsBipolarRight = [3 4 6 11 12 13 14 20 21 22]; %[28 35 36 43 44];
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
    powerData = energyData.analysisDataST;
    powerData_trialAvg = energyData.analysisDataST_trialAvg;
    powerDataBL = energyData.analysisDataBL;
    powerDataBL_trialAvg = energyData.analysisDataBL_trialAvg;
    
    psdData = energyData.dataST;
    psdData_trialAvg = energyData.dataST_trialAvg;
    psdDataBL = energyData.dataBL;
    psdDataBL_trialAvg = energyData.dataBL_trialAvg;
    
    ERPData = erpData.dataST;
    rmsERPData = erpData.analysisData_ST;
    
elseif strcmp(timeEpoch,'PreTarget')
    powerData = energyData.analysisDataTG;
    powerData_trialAvg = energyData.analysisDataTG_trialAvg;
    powerDataBL = energyData.analysisDataBL;
    powerDataBL_trialAvg = energyData.analysisDataBL_trialAvg;
    
    psdData = energyData.dataTG;
    psdData_trialAvg = energyData.dataTG_trialAvg;
    psdDataBL = energyData.dataBL;
    psdDataBL_trialAvg = energyData.dataBL_trialAvg;
    
    ERPData = erpData.dataTG;
    rmsERPData = erpData.analysisData_TG;
end

% if strcmp(timeEpoch,'StimOnset')
%     powerData = energyData.analysisDataST;
%     powerDataBL = energyData.analysisDataBL;
%     ERPData = erpData.dataST;
%     psdData = energyData.dataST;
%     
%     psdDataBL = energyData.dataBL;
%     rmsERPData = erpData.analysisData_ST;
% elseif strcmp(timeEpoch,'PreTarget')
%     powerData = energyData.analysisDataTG;
%     powerDataBL = energyData.analysisDataBL;
%     ERPData = erpData.dataTG;
%     psdData = energyData.dataTG;
%     psdDataBL = energyData.dataBL;
%     rmsERPData = erpData.analysisData_TG;
% end

topoPlotType = 'LeftVsRight'; rhythmIDs = [1 2 3 4];

[attData_Topo,ignData_Topo]= ...
    getAttendVsIgnored_TopoPlotPowerData...
    (powerData,powerData_trialAvg,rhythmIDs,topoPlotType,subjectIdx,eotCodeIdx,nanFlag);

[~,ignDataBL_Topo]= ...
    getAttendVsIgnored_TopoPlotPowerData...
    (powerDataBL,powerDataBL_trialAvg,rhythmIDs,topoPlotType,subjectIdx,eotCodeIdx,nanFlag);


for iPlot = 1:4
    switch iPlot
        case 1
            chanlocs = chanlocs_Unipolar;
            showElecIDs = [showOccipitalElecsUnipolar]; %#ok<*NBRAK>
        case 2
            chanlocs = chanlocs_Unipolar;
            showElecIDs = [showOccipitalElecsUnipolar];
        case 3
            chanlocs = chanlocs_Unipolar;
            showElecIDs = [showOccipitalElecsUnipolar];
        case 4
            chanlocs = chanlocs_Unipolar;
            showElecIDs = [showOccipitalElecsUnipolar];
    end
    cLim = cLims{iPlot}; cLimDiff = cLimsDiff{iPlot};
    
    if plotBaselineSubtractedPowerFlag
        topoPlot_Attended = 10*(attData_Topo{iPlot}-ignDataBL_Topo{iPlot});
        topoPlot_Ignored = 10*(ignData_Topo{iPlot}-ignDataBL_Topo{iPlot});
        topoPlot_AttendedMinusIgnored = topoPlot_Attended-topoPlot_Ignored;
    else
        topoPlot_Attended =  attData_Topo{iPlot};
        topoPlot_Ignored = ignData_Topo{iPlot};
        topoPlot_AttendedMinusIgnored = 10*(topoPlot_Attended-topoPlot_Ignored);
    end
    
    figure(1)
    % TopoPlots for Static Stimuli
    subplot(hPlot1(iPlot,1)); cla; hold on;
    topoplot_murty(topoPlot_Attended,chanlocs,'electrodes','on','style',...
        topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',...
        topoPlot_Attended); caxis(cLim); 
    cBar_Att = colorbar; cTicks = [cLim(1) 0 cLim(2)]; 
    set(cBar_Att,'Ticks',cTicks,'tickLength',3*tickPlotLength(1),'TickDir','out','fontSize',fontSize);
    if iPlot == 4
        cBar_Att.Label.String ='\Delta Power (dB)'; cBar_Att.Label.FontSize = fontSize;
    end
     
    topoplot_murty([],chanlocs,'electrodes','on','style','blank',...
        'drawaxis','off','nosedir','+X','plotchans',showElecIDs);
    
    subplot(hPlot1(iPlot,2)); cla; hold on;
    topoplot_murty(topoPlot_Ignored,chanlocs,'electrodes','on','style',...
        topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',...
        topoPlot_Ignored); caxis(cLim); cTicks = [cLim(1) 0 cLim(2)]; 
    cBar_Ign = colorbar; set(cBar_Ign,'Ticks',cTicks,'tickLength',3*tickPlotLength(1),'TickDir','out','fontSize',12);
    topoplot_murty([],chanlocs,'electrodes','on','style','blank',...
        'drawaxis','off','nosedir','+X','plotchans',showElecIDs);
%     if iPlot == 4
%         cBar_Ign.Label.String ='\Delta Power (dB)'; cBar_Ign.Label.FontSize = fontSize;
%     end
    
    subplot(hPlot1(iPlot,3)); cla; hold on;
    topoplot_murty(topoPlot_AttendedMinusIgnored,chanlocs,...
        'electrodes','on','style',topoplot_style,'drawaxis','off',...
        'nosedir','+X','emarkercolors',topoPlot_AttendedMinusIgnored);
    caxis(cLimDiff); cTicks = [cLimDiff(1) 0.5 cLimDiff(2)]; 
    cBar_Diff = colorbar; set(cBar_Diff,'Ticks',cTicks,'tickLength',3*tickPlotLength(1),'TickDir','out','fontSize',12);
    topoplot_murty([],chanlocs,'electrodes','on','style','blank',...
        'drawaxis','off','nosedir','+X','plotchans',showElecIDs);
%     if iPlot == 4
%         cBar_Diff.Label.String ='\Delta Power (dB)'; cBar_Diff.Label.FontSize = fontSize;
%     end
    
    
end

annotation('textbox',[0.08 0.97 0.1 0.0241],'EdgeColor','none','String','Attend Left','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.13+ 0.12 0.97 0.1 0.0241],'EdgeColor','none','String','Attend Right','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.29+ 0.1 0.97 0.3 0.0241],'EdgeColor','none','String','Attend Left - Attend Right','fontSize',14,'fontWeight','bold');

% Attend Left; Left: 0 Hz; Right: 0 Hz;
elpsL = annotation('ellipse',[0.092 0.8983 0.0146 0.0136]); elpsR = annotation('ellipse',[0.122 0.8983 0.0146 0.0136]);
elpsL.FaceColor = 'k'; elpsR.FaceColor = 'none';
% annotation('textbox',[0.0796 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);
% annotation('textbox',[0.1114 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);

% Attend Right; Left: 0 Hz; Right: 0 Hz;
elpsL = annotation('ellipse',[0.1234+0.1375 0.8983 0.0146 0.0136]); elpsR = annotation('ellipse',[0.1234+0.1677 0.8983 0.0146 0.0136]);
elpsL.FaceColor = 'none'; elpsR.FaceColor = 'k';
% annotation('textbox',[0.1234+0.1296 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);
% annotation('textbox',[0.1234+0.1614 0.9193 0.0381 0.0252],'EdgeColor','none','String','Static','fontSize',12);

annotation('textbox',[0.001 0.82 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Alpha' '(8-12 Hz)'},'fontSize',14);
annotation('textbox',[0.001 0.82-0.23 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'Gamma' '(25-70 Hz)'},'fontSize',14);
annotation('textbox',[0.001 0.82-2*0.23 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'SSVEP' 'Single Trial'},'fontSize',14);
annotation('textbox',[0.001 0.82-3*0.23 0.08 0.0241],'EdgeColor','none','HorizontalAlignment','center','String',{'SSVEP' 'TrialAvg'},'fontSize',14);

lineWidth = 1.5;
refType = 1;
DataType = 'BothSides';

% Loop for plotting PSDs for occipital and frontal electrodes for static
% stimuli

for iElecgroup = 1:2 % 1: Occipital PSD, 2: Frontal PSD
    clear attData_psd ignData_psd attDataBL_psd ignDataBL_psd
    switch iElecgroup
        case 1
            elecsLeft = showOccipitalElecsLeft;
            elecsRight = showOccipitalElecsRight;
            hPlot = hPlot2(1,1);
        case 2
            elecsLeft = showFrontalElecsLeft;
            elecsRight = showFrontalElecsRight;
            hPlot = hPlot3(1,1);
    end
    
    [attData_psd,ignData_psd]= getAttendVsIgnoredCombinedData_StaticStimuli...
        (psdData,refType,DataType,subjectIdx,eotCodeIdx,nanFlag,...
        elecsLeft,elecsRight);
    [attDataBL_psd,ignDataBL_psd]= getAttendVsIgnoredCombinedData_StaticStimuli...
        (psdDataBL,refType,DataType,subjectIdx,eotCodeIdx,nanFlag,...
        elecsLeft,elecsRight);
    
    deltaPSD = 10*(log10(attData_psd)-log10(ignData_psd));
    
    plot(hPlot,energyData.freqVals,mean(log10(attData_psd),1,nanFlag),'r','LineWidth',lineWidth);
    hold(hPlot,'on');
    plot(hPlot,energyData.freqVals,mean(log10(ignData_psd),1,nanFlag),'b','LineWidth',lineWidth);
    plot(hPlot,energyData.freqVals,mean(log10(attDataBL_psd),1,nanFlag),'k','LineWidth',lineWidth);
    plot(hPlot,energyData.freqVals,mean(log10(ignDataBL_psd),1,nanFlag),'--k','LineWidth',lineWidth);
    plot(hPlot,energyData.freqVals,mean(deltaPSD,1,nanFlag),'k','LineWidth',lineWidth);
    xlim(hPlot,[0 72]);
end

% Loop for plotting delta Powers for occipital and frontal electrodes for static
% stimuli

for iElecGroup = 1:2
rhythmIDs = [1 2 3 4 5 6];
    switch iElecGroup
        case 1
            elecsLeft = showOccipitalElecsLeft;
            elecsRight = showOccipitalElecsRight;
            hPlot = hPlot2(1,2);
        case 2
            elecsLeft = showFrontalElecsLeft;
            elecsRight = showFrontalElecsRight;
            hPlot = hPlot3(1,2);
    end

[attAnalysisData,ignAnalysisData]= getAttendVsIgnored_BarPlotData_StaticStimuli...
    (rmsERPData,powerData,DataType,rhythmIDs,subjectIdx,eotCodeIdx,...
    nanFlag,elecsLeft,elecsRight);
[attAnalysisDataBL,ignAnalysisDataBL]= getAttendVsIgnored_BarPlotData_StaticStimuli...
    (rmsERPData,powerDataBL,DataType,rhythmIDs,subjectIdx,eotCodeIdx,...
    nanFlag,elecsLeft,elecsRight); %#ok<*ASGLU>

colors = {'y','k','r','c'};

for iBar = 2:length(attAnalysisData)-5
    if iBar ==1
        attData = attAnalysisData{iBar};
        ignData = ignAnalysisData{iBar};
        diffData = attData-ignData;
        mBar = mean(diffData,1,nanFlag);
        errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
    else
        if plotBaselineSubtractedPowerFlag
            attData = log10(attAnalysisData{iBar})-log10(ignAnalysisDataBL{iBar});
            ignData = log10(ignAnalysisData{iBar})-log10(ignAnalysisDataBL{iBar});
        else
            attData = log10(attAnalysisData{iBar});
            ignData = log10(ignAnalysisData{iBar});
        end
        diffData = 10*(attData-ignData); %dB
        mBar = mean(diffData,1,nanFlag);
        errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
        
    end
            statData(iBar-1,:) = diffData;

    
    mBars(iBar-1) = mBar; %#ok<*AGROW>
    eBars(iBar-1) = errorBar;
    subplot(hPlot);hold(hPlot,'on');
    
    barPlot = bar(iBar-1,mBar);
    barPlot.FaceColor = colors{iBar};
    ylim(hPlot,[-1 1])
    
end

NeuralMeasures = {'alpha','gamma'};
statData(1,:) = -statData(1,:); % making the delta alpha powers negative
allCombinations = nchoosek(1:size(statData,1),2);
for iComb=1:size(allCombinations,1)
    if strcmp(statTest,'RankSum')
        pVals(iComb) = ranksum(statData(allCombinations(iComb,1),:),statData(allCombinations(iComb,2),:));
    elseif strcmp(statTest,'t-test')
        [~,pVals(iComb)] = ttest(statData(allCombinations(iComb,1),:),statData(allCombinations(iComb,2),:));
    end
end
H = sigstar({[1,2]},pVals,0);

errorbar(hPlot,1:length(mBars),mBars,eBars,'.','color','k');
xlim(hPlot,[0 4]);

end

% Loop for plotting PSDs for occipital and frontal electrodes for
% Flickering stimuli
for iSSVEPMethod = 1:2
    switch iSSVEPMethod
        case 1
            data_psd = psdData;
            dataBL_psd = psdDataBL;
        case 2
            data_psd = psdData_trialAvg;
            dataBL_psd = psdDataBL_trialAvg;
    end


for iElecgroup = 1:2 % 1: Occipital PSD, 2: Frontal PSD
    clear attData_psd ignData_psd attDataBL_psd ignDataBL_psd
    switch iElecgroup
        case 1
            elecsLeft = showOccipitalElecsLeft;
            elecsRight = showOccipitalElecsRight;
            hPlot = hPlot2(iSSVEPMethod+1,1);
        case 2
            elecsLeft = showFrontalElecsLeft;
            elecsRight = showFrontalElecsRight;
            hPlot = hPlot3(iSSVEPMethod+1,1);
    end
    
    [attData_psd,ignData_psd]= getAttendVsIgnoredCombinedData_FlickerStimuli...
        (data_psd,refType,subjectIdx,eotCodeIdx,nanFlag,...
        elecsLeft,elecsRight);
    [attDataBL_psd,ignDataBL_psd]= getAttendVsIgnoredCombinedData_FlickerStimuli...
        (dataBL_psd,refType,subjectIdx,eotCodeIdx,nanFlag,...
        elecsLeft,elecsRight);
    
    deltaPSD = 10*(log10(attData_psd)-log10(ignData_psd));
    
    plot(hPlot,energyData.freqVals,mean(log10(attData_psd),1,nanFlag),'r','LineWidth',lineWidth);
    hold(hPlot,'on');
    plot(hPlot,energyData.freqVals,mean(log10(ignData_psd),1,nanFlag),'b','LineWidth',lineWidth);
    plot(hPlot,energyData.freqVals,mean(log10(attDataBL_psd),1,nanFlag),'k','LineWidth',lineWidth);
    plot(hPlot,energyData.freqVals,mean(log10(ignDataBL_psd),1,nanFlag),'--k','LineWidth',lineWidth);
    plot(hPlot,energyData.freqVals,mean(deltaPSD,1,nanFlag),'k','LineWidth',lineWidth);
    xlim(hPlot,[0 72]);
end
end

% Loop for plotting delta Powers for occipital and frontal electrodes for
% flickering stimuli
for iSSVEPMethod = 2:2
    switch iSSVEPMethod
        case 1
            powerDataTMP = powerData;
            powerDataBLTMP = powerDataBL;
        case 2
            powerDataTMP = powerData_trialAvg;
            powerDataBLTMP = powerDataBL_trialAvg;
    end

for iElecGroup = 1:2
    clear attAnalysisData ignAnalysisData attAnalysisDataBL ignAnalysisDataBL
rhythmIDs = [1 2 3 4 5 6];
    switch iElecGroup
        case 1
            elecsLeft = showOccipitalElecsLeft;
            elecsRight = showOccipitalElecsRight;
            hPlot = hPlot2(iSSVEPMethod+1,2);
        case 2
            elecsLeft = showFrontalElecsLeft;
            elecsRight = showFrontalElecsRight;
            hPlot = hPlot3(iSSVEPMethod+1,2);
    end

[attAnalysisData_Flick,ignAnalysisData_Flick]= getAttendVsIgnored_BarPlotData_FlickerStimuli...
    (rmsERPData,powerDataTMP,rhythmIDs,subjectIdx,eotCodeIdx,...
    nanFlag,elecsLeft,elecsRight);
[attAnalysisDataBL_Flick,ignAnalysisDataBL_Flick]= getAttendVsIgnored_BarPlotData_FlickerStimuli...
    (rmsERPData,powerDataBLTMP,rhythmIDs,subjectIdx,eotCodeIdx,...
    nanFlag,elecsLeft,elecsRight); %#ok<*ASGLU>

colors = {'k','r','c'};
dataIDs = [2 3 9];

for iBar = 1:length(dataIDs)
    if plotBaselineSubtractedPowerFlag
        attData = log10(attAnalysisData_Flick{dataIDs(iBar)})-log10(ignAnalysisDataBL_Flick{dataIDs(iBar)});
        ignData = log10(ignAnalysisData_Flick{dataIDs(iBar)})-log10(ignAnalysisDataBL_Flick{dataIDs(iBar)});
    else
        attData = log10(attAnalysisData_Flick{dataIDs(iBar)});
        ignData = log10(ignAnalysisData_Flick{dataIDs(iBar)});
    end
    diffData = 10*(attData-ignData); %dB
    mBar = mean(diffData,1,nanFlag);
    errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
    
    mBars(iBar) = mBar; %#ok<*AGROW>
    eBars(iBar) = errorBar;
    subplot(hPlot);hold(hPlot,'on');
    
    barPlot = bar(iBar,mBar);
    barPlot.FaceColor = colors{iBar};
    ylim(hPlot,[-1 1])
    
end

errorbar(hPlot,1:length(mBars),mBars,eBars,'.','color','k');
xlim(hPlot,[0 4]);

end
end

tickPlotLength = get(hPlot2(1,1),'TickLength');
fontSize = 12;

for i=1:3
    for j=1:2
    set(hPlot2(i,j),'fontSize',fontSize,'box','off','tickLength',2*tickPlotLength,'TickDir','out')
    set(hPlot3(i,j),'fontSize',fontSize,'box','off','tickLength',2*tickPlotLength,'TickDir','out')
    end
end

linkaxes(hPlot2(1:3,1)); xlim(hPlot2(1,1),[0 72]); ylim(hPlot2(1,1),[-4 4])
linkaxes(hPlot3(1:3,1));  xlim(hPlot2(1,1),[0 72]); ylim(hPlot3(1,1),[-4 4])

linkaxes(hPlot2(1:3,2)); xlim(hPlot2(1,2),[0 4]); ylim(hPlot2(1,2),[-2 3])
linkaxes(hPlot3(1:3,2)); xlim(hPlot3(1,2),[0 4]); ylim(hPlot3(1,2),[-2 3])

Datalabels = {'alpha','gamma','SSVEP'};

set(hPlot2(1,2),'yTick',[-2 0 3],'xTick',1:2,'xTickLabel',Datalabels(1:2),'XTickLabelRotation',30);
set(hPlot3(1,2),'yTick',[-2 0 3],'xTick',1:2,'xTickLabel',Datalabels(1:2),'XTickLabelRotation',30);

for i=2:3
set(hPlot2(i,2),'yTick',[-2 0 3],'xTick',1:3,'xTickLabel',Datalabels,'XTickLabelRotation',30);
set(hPlot3(i,2),'yTick',[-2 0 3],'xTick',1:3,'xTickLabel',Datalabels,'XTickLabelRotation',30);
end

lineWidth_lines = 1.3;
for i=1:3
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
if i==2|| i==3
xline(hPlot2(i,1),24,'color',colors{3},'LineWidth',lineWidth_lines)
xline(hPlot2(i,1),32,'color',colors{3},'LineWidth',lineWidth_lines)
xline(hPlot3(i,1),24,'color',colors{3},'LineWidth',lineWidth_lines)
xline(hPlot3(i,1),32,'color',colors{3},'LineWidth',lineWidth_lines)
end
end

ylabel(hPlot2(3,1),'log_1_0 (Power (\muV^2))'); xlabel(hPlot2(3,1),'Frequency (Hz)'); 
ylabel(hPlot2(3,2),'Change in Power (dB)'); 

annotation('textbox',[0.63 0.97 0.2 0.0241],'EdgeColor','none','String','Occipital Electrodes','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.85 0.97 0.2 0.0241],'EdgeColor','none','String','Frontal Electrodes','fontSize',14,'fontWeight','bold');
title(hPlot2(1,1),'PSD','fontSize',fontSize);
title(hPlot2(1,2),'\Delta Power','fontSize',fontSize);
title(hPlot3(1,1),'PSD','fontSize',fontSize);
title(hPlot3(1,2),'\Delta Power','fontSize',fontSize);



 
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

saveFolder = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\Figures\SRC-Attention\ConsolidatedTopoplots\AttendedVsIgnored\');
figName1 = fullfile(saveFolder,[protocolType '_' subString  timeEpoch, '_' eotString '_tapers_' , ...
    num2str(tapers(2)) '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz' 'badTrial_' badTrialStr]);


saveas(hFig1,[figName1 'v2.fig'])
print(hFig1,[figName1 'v2.tif'],'-dtiff','-r600')

end


%% Accessory Functions

% Process Attend Vs. Ignored TopoPlot data for Static Stimuli
function [attData,ignData]= ...
    getAttendVsIgnored_TopoPlotPowerData...
    (data,data_trialAvg,rhythmIDs,topoPlotStyle,subjectIdx,eotCodeIdx,nanFlag)

for iRhythm = 1:4
    switch iRhythm
        case 1
            refType = 1;
            topoData = data{refType}{rhythmIDs(1)};
            if strcmp(topoPlotStyle,'LeftVsRight')
                attLoc = 2; ign_AttLoc = 1; att_TF = 1; ign_AttTF = 1;
            elseif strcmp(topoPlotStyle,'RightVsLeft')
                attLoc = 1; ign_AttLoc = 2; att_TF = 1; ign_AttTF = 1;
            end
            attData{iRhythm}= squeeze(mean(log10(topoData(subjectIdx,:,eotCodeIdx,attLoc,att_TF)),1,nanFlag));
            ignData{iRhythm} = squeeze(mean(log10(topoData(subjectIdx,:,eotCodeIdx,ign_AttLoc,ign_AttTF)),1,nanFlag));
            
            
        case 2
            refType = 1;
            topoData = data{refType}{rhythmIDs(2)};
            if strcmp(topoPlotStyle,'LeftVsRight')
                attLoc = 2; ign_AttLoc = 1; att_TF = 1; ign_AttTF = 1;
            elseif strcmp(topoPlotStyle,'RightVsLeft')
                attLoc = 1; ign_AttLoc = 2; att_TF = 1; ign_AttTF = 1;
            end
            attData{iRhythm}= squeeze(mean(log10(topoData(subjectIdx,:,eotCodeIdx,attLoc,att_TF)),1,nanFlag));
            ignData{iRhythm} = squeeze(mean(log10(topoData(subjectIdx,:,eotCodeIdx,ign_AttLoc,ign_AttTF)),1,nanFlag));
            
            
        case 3
            refType = 1;
            count = 1;
            for iAttendLoc = 1:2
                for iSSVEPFreq = 1:2
                    condition = str2double(strcat(num2str(iAttendLoc),num2str(iSSVEPFreq)));
                    switch(condition)
                        case 21
                            attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3;
                            topoDataTMP = data{refType}{rhythmIDs(3)};
                            
                        case 22
                            attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2;
                            topoDataTMP = data{refType}{rhythmIDs(4)};
                            
                        case 11
                            attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3;
                            topoDataTMP = mirrorTopoplotData(data{refType}{rhythmIDs(3)});
                            
                        case 12
                            attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2;
                            topoDataTMP = mirrorTopoplotData(data{refType}{rhythmIDs(4)});
                    end
                    
                    att_topoDataTMP_all(count,:,:) = squeeze(topoDataTMP(subjectIdx,:,eotCodeIdx,attLoc,att_TF));
                    ign_topoDataTMP_all(count,:,:) = squeeze(topoDataTMP(subjectIdx,:,eotCodeIdx,ign_AttLoc,ign_AttTF));
                    count  = count+1;
                end
            end
            
            attData{iRhythm} = squeeze(mean(log10(mean(att_topoDataTMP_all,1,nanFlag)),2,nanFlag));
            ignData{iRhythm} = squeeze(mean(log10(mean(ign_topoDataTMP_all,1,nanFlag)),2,nanFlag));
            
        case 4
            refType = 1;
            count = 1;
            for iAttendLoc = 1:2
                for iSSVEPFreq = 1:2
                    condition = str2double(strcat(num2str(iAttendLoc),num2str(iSSVEPFreq)));
                    switch(condition)
                        case 21
                            attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3;
                            topoDataTMP = data_trialAvg{refType}{rhythmIDs(3)};
                            
                        case 22
                            attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2;
                            topoDataTMP = data_trialAvg{refType}{rhythmIDs(4)};
                            
                        case 11
                            attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3;
                            topoDataTMP = mirrorTopoplotData(data_trialAvg{refType}{rhythmIDs(3)});
                            
                        case 12
                            attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2;
                            topoDataTMP = mirrorTopoplotData(data_trialAvg{refType}{rhythmIDs(4)});
                    end
                    
                    att_topoDataTMP_all_trialavg(count,:,:) = squeeze(topoDataTMP(subjectIdx,:,eotCodeIdx,attLoc,att_TF));
                    ign_topoDataTMP_all_trialavg(count,:,:) = squeeze(topoDataTMP(subjectIdx,:,eotCodeIdx,ign_AttLoc,ign_AttTF));
                    count  = count+1;
                end
            end
            
            attData{iRhythm} = squeeze(mean(log10(mean(att_topoDataTMP_all_trialavg,1,nanFlag)),2,nanFlag));
            ignData{iRhythm} = squeeze(mean(log10(mean(ign_topoDataTMP_all_trialavg,1,nanFlag)),2,nanFlag));
    end
end
end


% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions
function [attData,ignData]= ...
    getAttendVsIgnoredCombinedData_StaticStimuli...
    (data,refType,topoPlotStyle,subjectIdx,eotCodeIdx,nanFlag,...
    elecsLeft,elecsRight)

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left

attData_all = cell(1,length(attendLocs));
ignData_all = cell(1,length(attendLocs));

if strcmp(topoPlotStyle,'BothSides')
    attLoc = attendLocs; ign_AttLoc = flip(attendLocs); att_TF = 1; 
    ign_AttTF = 1; elecNums{1} = elecsLeft{1};elecNums{2} = elecsRight{1};
elseif strcmp(topoPlotStyle,'LeftVsRight')
    attLoc = 2; ign_AttLoc = 1; att_TF = 1; ign_AttTF = 1;
    elecNums{1} = elecsRight{1};
elseif strcmp(topoPlotStyle,'RightVsLeft')
    attLoc = 1; ign_AttLoc = 2; att_TF = 1; ign_AttTF = 1; 
    elecNums{1} = elecsLeft{1};
end

for i=1:length(attLoc)
    clear attDataTMP ignDataTMP
    attDataTMP = squeeze(data{refType}(:,elecNums{i},eotCodeIdx,attLoc(i),att_TF,:));
    ignDataTMP = squeeze(data{refType}(:,elecNums{i},eotCodeIdx,ign_AttLoc(i),ign_AttTF,:));
    
    attData_all{i} = attDataTMP;
    ignData_all{i}  = ignDataTMP;
end

if length(attData_all)== 1
    attData = squeeze(mean(attData_all{1},2,nanFlag));
    ignData = squeeze(mean(ignData_all{1},2,nanFlag));
elseif length(attData_all)== 2
    attDataTMP2 = squeeze(mean(cat(2,attData_all{1},attData_all{2}),2,nanFlag));
    ignDataTMP2 = squeeze(mean(cat(2,ignData_all{1},ignData_all{2}),2,nanFlag));
    attData = attDataTMP2(subjectIdx,:);
    ignData = ignDataTMP2(subjectIdx,:);
end
end

% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions for Analysis Electrodes for Static Stimuli

function [attData,ignData]= ...
    getAttendVsIgnored_BarPlotData_StaticStimuli...
    (rmsERPData,powerData,topoPlotStyle,rhythmIDs,subjectIdx,...
    eotCodeIdx,nanFlag,elecsLeft,elecsRight)


refType = 1;
data{1} = rmsERPData{refType};
data{2} = powerData{refType}{rhythmIDs(1)}; % Alpha Unipolar Ref
data{3} = powerData{refType}{rhythmIDs(2)}; % Gamma Unipolar Ref
data{4} = powerData{refType}{rhythmIDs(3)}; % Slow Gamma Unipolar Ref
data{5} = powerData{refType}{rhythmIDs(4)}; % Fast Gamma Unipolar Ref

refType = 2;
data{6} = powerData{refType}{rhythmIDs(2)}; %  Gamma Bipolar Ref
data{7} = powerData{refType}{rhythmIDs(5)}; % Slow Gamma Bipolar Ref
data{8} = powerData{refType}{rhythmIDs(6)}; % Fast Gamma Bipolar Ref

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
ssvepFreqs = [1 2]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz

attData = cell(1,length(data));
ignData = cell(1,length(data));

if strcmp(topoPlotStyle,'BothSides')
    attLoc = attendLocs; ign_AttLoc = flip(attendLocs); att_TF = 1; 
    ign_AttTF = 1; elecNums{1} = elecsLeft; elecNums{2} = elecsRight;
elseif strcmp(topoPlotStyle,'LeftVsRight')
    attLoc = 2; ign_AttLoc = 1; att_TF = 1; ign_AttTF = 1; 
    elecNums = {elecsRight};
elseif strcmp(topoPlotStyle,'RightVsLeft')
    attLoc = 1; ign_AttLoc = 2; att_TF = 1; ign_AttTF = 1; 
    elecNums = {elecsLeft};
end

attData_all = cell(1,length(data));
ignData_all = cell(1,length(data));
diffData_all = cell(1,length(data));

for i=1:length(attLoc)
    for iDataType = 1: length(data)
        if iDataType == 6 || iDataType == 7 || iDataType == 8
            elecs = elecNums{i}{2};
        else
            elecs = elecNums{i}{1};
        end
        attData_all{1,iDataType}(:,i) = squeeze(mean(data{iDataType}(subjectIdx,elecs,eotCodeIdx,attLoc(i),att_TF),2,nanFlag));
        ignData_all{1,iDataType}(:,i) = squeeze(mean(data{iDataType}(subjectIdx,elecs,eotCodeIdx,ign_AttLoc(i),ign_AttTF),2,nanFlag));
    end
end

if size(attData_all{1},2) == 1
    attData = attData_all;
    ignData = ignData_all;
elseif size(attData_all{1},2) == 2
    for i = 1:size(attData_all,2)
        attData{1,i} = mean(attData_all{1,i},2,nanFlag);
        ignData{1,i} = mean(ignData_all{1,i},2,nanFlag);
    end
end
end


% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions
function [attData,ignData]= ...
    getAttendVsIgnoredCombinedData_FlickerStimuli...
    (data,refType,subjectIdx,eotCodeIdx,nanFlag,elecsLeft,elecsRight)

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
ssvepFreqs = [1 2]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz


count = 1;
for iAttendLoc = 1:length(attendLocs)
    for iSSVEPFreq = 1:length(ssvepFreqs)
        condition = str2double(strcat(num2str(iAttendLoc),num2str(iSSVEPFreq)));
        switch(condition)
            case 11
                attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3; elecNums = elecsLeft{1};
            case 21
                attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3; elecNums = elecsRight{1};
            case 12
                attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2; elecNums = elecsLeft{1};
            case 22
                attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2; elecNums = elecsRight{1};
        end
        
        attDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx,attLoc,att_TF,:));
        ignDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx,ign_AttLoc,ign_AttTF,:));
        
        attData_all(count,:,:,:) = attDataTMP;
        ignData_all(count,:,:,:) = ignDataTMP;
        count = count+1;
    end
end

attData = squeeze(mean(mean(attData_all,1,nanFlag),3,nanFlag));
ignData = squeeze(mean(mean(ignData_all,1,nanFlag),3,nanFlag));

end

% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions for Analysis Electrodes

function [attData,ignData]= ...
    getAttendVsIgnored_BarPlotData_FlickerStimuli...
    (rmsERPData,powerData,rhythmIDs,subjectIdx,eotCodeIdx,nanFlag,...
    elecsLeft,elecsRight)


refType = 1;
data{1} = rmsERPData{refType};
data{2} = powerData{refType}{rhythmIDs(1)}; % Alpha Unipolar Ref
data{3} = powerData{refType}{rhythmIDs(2)}; %  Gamma Unipolar Ref
data{4} = powerData{refType}{rhythmIDs(3)}; % SSVEP 24 Hz
data{5} = powerData{refType}{rhythmIDs(4)}; % SSVEP 32 Hz

refType = 2;
data{6} = powerData{refType}{rhythmIDs(2)}; %  Gamma Bipolar Ref
data{7} = powerData{refType}{rhythmIDs(5)}; % Slow Gamma Bipolar Ref
data{8} = powerData{refType}{rhythmIDs(6)}; % Fast Gamma Bipolar Ref

attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
ssvepFreqs = [1 2]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz


count = 1;
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
            if iDataType == 6 || iDataType == 7 || iDataType == 8
                elecs = elecNums{2};
            else
                elecs = elecNums{1};
            end
            attDataTMP{iDataType}(count,:,:) = squeeze(data{iDataType}(subjectIdx,elecs,eotCodeIdx,attLoc,att_TF));
            ignDataTMP{iDataType}(count,:,:) = squeeze(data{iDataType}(subjectIdx,elecs,eotCodeIdx,ign_AttLoc,ign_AttTF));
            count = count+1;
        end
    end
end

for i=1:length(data)
attData{i} = squeeze(mean(mean(attDataTMP{i},1,nanFlag),3,nanFlag))';
ignData{i} = squeeze(mean(mean(ignDataTMP{i},1,nanFlag),3,nanFlag))';
end

% combining SSVEP Freq

refType = 1;
count = 1;
for iAttendLoc = 1:2
    for iSSVEPFreq = 1:2
        condition = str2double(strcat(num2str(iAttendLoc),num2str(iSSVEPFreq)));
        switch(condition)
            case 21
                attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3; elecNums = elecsRight;
                dataTMP = powerData{refType}{rhythmIDs(3)};
                
            case 22
                attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2; elecNums = elecsRight;
                dataTMP = powerData{refType}{rhythmIDs(4)};
                
            case 11
                attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3; elecNums = elecsLeft;
                dataTMP = powerData{refType}{rhythmIDs(3)};
                
            case 12
                attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2; elecNums = elecsLeft;
                dataTMP = powerData{refType}{rhythmIDs(4)};
        end
        
        elecs = elecNums{1};
        att_SSVEP_all(count,:,:) = squeeze(dataTMP(subjectIdx,elecs,eotCodeIdx,attLoc,att_TF));
        ign_SSVEP_all(count,:,:) = squeeze(dataTMP(subjectIdx,elecs,eotCodeIdx,ign_AttLoc,ign_AttTF));
        count  = count+1;
    end
end
            
attData{length(data)+1} = squeeze(mean(mean(att_SSVEP_all,1,nanFlag),3,nanFlag))';
ignData{length(data)+1} = squeeze(mean(mean(ign_SSVEP_all,1,nanFlag),3,nanFlag))';
end






% Accessory Functions
function mirrored_topoData = mirrorTopoplotData(data)
mirror_elecNums = [2 1	7	6	5	4	3	11	10	9	8	16	15	14 ...
    13	12	22	21	20	19	18	17	27	26	25	24	23	32	31	30	29 ...
    28	36	35	34	33	40	39	38	37	46	45	44	43	42	41	50	49 ...
    48	47	55	54	53	52	51	59	58	57	56	64	63	62	61	60];

mirrored_topoData = data(:,mirror_elecNums,:,:,:);


% for i = 1:size(data,1)
%         mirrored_topoData2(i,:) = data(i,mirror_elecNums);
% end
%
% for i = 1:size(data,1)
%     for j = 1:size(data,2)
%         mirrored_topoData(i,j) = data(i,mirror_elecNums(j));
%     end
% end

end




