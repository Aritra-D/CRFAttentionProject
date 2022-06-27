% This program change in Power wrt to Baseline Topoplots for static
% and flickering stimuli, ERP,PSD and Delta Power Changes for attended and
% Ignored conditions. This program furthermore combines the band powers for
% static and flickering stimuli and combines SSVEP powers for 24 and 32 Hz

function statData = displayCombinedResults_AttendVsIgnored(protocolType,analysisMethodFlag,...
    subjectIdx,timeEpoch,eotCodeIdx,removeBadElectrodeData,...
    plotBaselineSubtractedPowerFlag,topoplot_style,colorMap) %#ok<INUSL>

% close all;
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
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz.mat']);
if exist(fileName, 'file')
    load(fileName,'erpData','energyData','badElecs','badHighPriorityElecs') %#ok<*LOAD>
else
    [erpData,fftData,energyData,badHighPriorityElecs,badElecs] = ...
        getData_SRCLongProtocols_v1(protocolType,gridType,timingParamters,tapers);
    save(fileName,'erpData','fftData','energyData','badHighPriorityElecs','badElecs')
end

% Replace the PSD and power Values if trial avg  PSD and power is plotted
if analysisMethodFlag
    clear energyData.dataBL energyData.dataST energyData.dataTG
    clear energyData.analysisDataBL energyData.analysisDataST energyData.analysisDataTG
    for iRef = 1:2
        energyData.dataBL{iRef} = energyData.dataBL_trialAvg{iRef};
        energyData.dataST{iRef} = energyData.dataST_trialAvg{iRef};
        energyData.dataTG{iRef} = energyData.dataTG_trialAvg{iRef};
        
        energyData.analysisDataBL{iRef} = energyData.analysisDataBL_trialAvg{iRef};
        energyData.analysisDataST{iRef} = energyData.analysisDataST_trialAvg{iRef};
        energyData.analysisDataTG{iRef} = energyData.analysisDataTG_trialAvg{iRef};
    end
end

% remove Bad Electrodes- converting the data for bad Elecs to NaN
if removeBadElectrodeData
    for iSub = 1:length(subjectIdx)
        for iRef = 1:2
            clear badElecsTMP
            badElecsTMP = badElecs{iRef}{subjectIdx(iSub)};
            
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
% hPlot1 = getPlotHandles(5,3,[0.1 0.05, 0.5 0.85],0.02,0.04,0);
hPlot2 = getPlotHandles(1,2,[0.18 0.4, 0.6 0.4],0.05,0.1,0);

if plotBaselineSubtractedPowerFlag
    cLimsRaw = [-2 2]; % range in dB
    cLimsDiff = [-1 2]; % range in dB
else
    cLimsRaw = [-1 2]; % range in log10 scale
    cLimsDiff = [-1 2]; % range in log10 scale
end

fontSizeLarge = 14; tickLengthMedium = [0.025 0];

showMode = 'dots';
showElecsUnipolarLeft = [24 29 57 61];
showElecsUnipolarRight = [26 31 58 63];
showElecsBipolarLeft = [93 94 101];
showElecsBipolarRight = [96 97 102];

showElecsLeft{1} = showElecsUnipolarLeft;
showElecsLeft{2} = showElecsBipolarLeft;
showElecsRight{1} = showElecsUnipolarRight;
showElecsRight{2} = showElecsBipolarRight;

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

% topoPlotType = 'LeftVsRight'; rhythmIDs = [1 5 6];
 
% SSVEP Topoplots 
% rhythmIDs = [3 4]; % 3- SSVEP Response at 24 Hz; 4- SSVEP Response at 32 Hz
% if analysisMethodFlag
%     if plotBaselineSubtractedPowerFlag
%         cLimsSSVEPRaw = [-1 10];
%         cLimsSSVEPDiff = [-2 5];
%     else
%         cLimsSSVEPRaw = [-3 -1];
%         cLimsSSVEPDiff = [-2 5];
%     end
% else
%     if plotBaselineSubtractedPowerFlag
%         cLimsSSVEPRaw = [-1 5];
%         cLimsSSVEPDiff = [-2 5];
%     else
%         cLimsSSVEPRaw = [-2 1];
%         cLimsSSVEPDiff = [-1 1];
%     end
% end
% showAllElecs = 1:64;
% 
% topoPlotFlag = 1;
% refType = 1;
% [attData_Topo,ignData_Topo,diffData_Topo]= ...
%     getAttendVsIgnored_TopoPlotPowerData...
%     (powerData,rhythmIDs,refType,subjectIdx,eotCodeIdx,nanFlag);
% 
% [attDataBL_Topo,ignDataBL_Topo,diffDataBL_Topo]= ...
%     getAttendVsIgnored_TopoPlotPowerData...
%     (powerDataBL,rhythmIDs,refType,subjectIdx,eotCodeIdx,nanFlag);

% figure(2)
% for iPlot = 1:4
%     switch iPlot
%         case 1
%             if plotBaselineSubtractedPowerFlag
%                 topoPlot_Attended =  10*(attData_Topo{2,1}-ignDataBL_Topo{2,1});
%                 topoPlot_Ignored = 10*(ignData_Topo{2,1}-ignDataBL_Topo{2,1});
%                 topoPlot_AttendedMinusIgnored = topoPlot_Attended-topoPlot_Ignored;% 10*(diffData_Topo{2,1}-diffDataBL_Topo{2,1});
%             else
%                 topoPlot_Attended =  attData_Topo{2,1};
%                 topoPlot_Ignored = ignData_Topo{2,1};
%                 topoPlot_AttendedMinusIgnored = 10*(topoPlot_Attended-topoPlot_Ignored); % 10*(diffData_Topo{2,1});
%             end
%             hTopo = hPlot1; plotID = 1; showElecIDs = showElecsUnipolarRight;
%         case 2
%             if plotBaselineSubtractedPowerFlag
%                 topoPlot_Attended =  10*(attData_Topo{1,1}-ignDataBL_Topo{1,1});
%                 topoPlot_Ignored = 10*(ignData_Topo{1,1}-ignDataBL_Topo{1,1});
%                 topoPlot_AttendedMinusIgnored = topoPlot_Attended-topoPlot_Ignored; %10*(diffData_Topo{1,1}-diffDataBL_Topo{1,1});
%             else
%                 topoPlot_Attended =  attData_Topo{1,1};
%                 topoPlot_Ignored = ignData_Topo{1,1};
%                 topoPlot_AttendedMinusIgnored = topoPlot_Attended-topoPlot_Ignored; %10*(diffData_Topo{1,1});
%             end
%             hTopo = hPlot1; plotID = 2; showElecIDs = showElecsUnipolarLeft;
%         case 3
%             if plotBaselineSubtractedPowerFlag
%                 topoPlot_Attended = 10*(attData_Topo{2,2}-ignDataBL_Topo{2,2});
%                 topoPlot_Ignored = 10*(ignData_Topo{2,2}-ignDataBL_Topo{2,2});
%                 topoPlot_AttendedMinusIgnored = topoPlot_Attended-topoPlot_Ignored; %10*(diffData_Topo{2,2}-diffDataBL_Topo{2,2});
%             else
%                 topoPlot_Attended =  attData_Topo{2,2};
%                 topoPlot_Ignored = ignData_Topo{2,2};
%                 topoPlot_AttendedMinusIgnored = 10*(topoPlot_Attended-topoPlot_Ignored); %10*(diffData_Topo{2,2});
%             end
%             hTopo = hPlot2; plotID = 1; showElecIDs = showElecsUnipolarRight;
%             
%         case 4
%             if plotBaselineSubtractedPowerFlag
%                 topoPlot_Attended = 10*(attData_Topo{1,2}-ignDataBL_Topo{1,2});
%                 topoPlot_Ignored = 10*(ignData_Topo{1,2}-ignDataBL_Topo{1,2});
%                 topoPlot_AttendedMinusIgnored = topoPlot_Attended-topoPlot_Ignored; %10*(diffData_Topo{1,2}-diffDataBL_Topo{1,2});
%             else
%                 topoPlot_Attended =  attData_Topo{1,2};
%                 topoPlot_Ignored = ignData_Topo{1,2};
%                 topoPlot_AttendedMinusIgnored = 10*(topoPlot_Attended-topoPlot_Ignored); %10*(diffData_Topo{1,2});
%             end
%             hTopo = hPlot2; plotID = 2; showElecIDs = showElecsUnipolarLeft;
%             
%     end
%     
%     subplot(hTopo(plotID,1)); cla; hold on;
%     topoplot_murty(topoPlot_Attended,chanlocs_Unipolar,'electrodes','on',...
%         'style',topoplot_style,'drawaxis','off','nosedir','+X',...
%         'emarkercolors',topoPlot_Attended); caxis(cLimsSSVEPRaw);colorbar;
%     topoplot_murty([],chanlocs_Unipolar,'electrodes','on',...
%         'style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
%     
%     subplot(hTopo(plotID,2)); cla; hold on;
%     topoplot_murty(topoPlot_Ignored,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlot_Ignored); caxis(cLimsSSVEPRaw);colorbar;
%     topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
%     
%     subplot(hTopo(plotID,3)); cla; hold on;
%     topoplot_murty(topoPlot_AttendedMinusIgnored,chanlocs_Unipolar,...
%         'electrodes','on','style',topoplot_style,'drawaxis','off',...
%         'nosedir','+X','emarkercolors',topoPlot_AttendedMinusIgnored); 
%     caxis(cLimsSSVEPDiff);colorbar;
%     topoplot_murty([],chanlocs_Unipolar,'electrodes','on',...
%         'style','blank','drawaxis','off','nosedir','+X','plotchans',showElecIDs);
%     
% end

% % get ERP Data for Attended and Ignored Conditions for Flicker Stimuli
% [attData_erp,ignData_erp,~]= getAttendVsIgnoredCombinedData...
%     (ERPData,refType,subjectIdx,eotCodeIdx,showElecsLeft,showElecsRight);
% % get PSD Data for Attended and Ignored Conditions for Flicker Stimuli
% [attData_psd,ignData_psd,~]= getAttendVsIgnoredCombinedData...
%     (psdData,refType,subjectIdx,eotCodeIdx,showElecsLeft,showElecsRight);
% [attDataBL_psd,ignDataBL_psd,~]= getAttendVsIgnoredCombinedData...
%     (psdDataBL,refType,subjectIdx,eotCodeIdx,showElecsLeft,showElecsRight);
% 
% for iPlot = 1:2
%     switch iPlot
%         case 1 
%             erp_Att = mean(attData_erp{1},1,nanFlag);
%             erp_Ign = mean(ignData_erp{1},1,nanFlag);
%             psd_Att = mean(log10(attData_psd{1}),1,nanFlag);
%             psd_Ign = mean(log10(ignData_psd{1}),1,nanFlag);
%             psdBL_Att = mean(log10(attDataBL_psd{1}),1,nanFlag);
%             psdBL_Ign = mean(log10(ignDataBL_psd{1}),1,nanFlag);
%             diffPSD = 10*(psd_Att-psd_Ign); hPlot = hPlot3;
%         case 2 
%             erp_Att = mean(attData_erp{2},1,nanFlag);
%             erp_Ign = mean(ignData_erp{2},1,nanFlag);
%             psd_Att = mean(log10(attData_psd{2}),1,nanFlag);
%             psd_Ign = mean(log10(ignData_psd{2}),1,nanFlag);
%             psdBL_Att = mean(log10(attDataBL_psd{2}),1,nanFlag);
%             psdBL_Ign = mean(log10(ignDataBL_psd{2}),1,nanFlag);
%             diffPSD = 10*(psd_Att-psd_Ign); hPlot = hPlot4;
%     end
%     
%     plot(hPlot(1,1),erpData.timeVals,erp_Att,'r'); hold(hPlot(1,1),'on');
%     plot(hPlot(1,1),erpData.timeVals,erp_Ign,'b');
%     xlim(hPlot(1,1),[-1.5 1.5])
%     
%     plot(hPlot(1,2),energyData.freqVals,psd_Att,'r'); hold(hPlot(1,2),'on');
%     plot(hPlot(1,2),energyData.freqVals,psd_Ign,'b');
%     plot(hPlot(1,2),energyData.freqVals,psdBL_Att,'k');
%     plot(hPlot(1,2),energyData.freqVals,psdBL_Ign,'--k');
%     plot(hPlot(1,2),energyData.freqVals,diffPSD,'k'); xlim(hPlot(1,2),[0 50])
% end

% get rmsERP Data and power Data for Selective Analysis Electrodes
% for Attended and Ignored Conditions for all (static and flickering
% Stimuli)

rhythmIDs = [1 3 4 5 6];
colors = {'y','k',[0.4940 0.1840 0.5560],'m',[0.4940 0.1840 0.5560],'m','c'};

[attAnalysisData,ignAnalysisData]= ...
    getAttendVsIgnored_BarPlotData(rmsERPData,powerData,....
    rhythmIDs,subjectIdx,eotCodeIdx,showElecsLeft,showElecsRight);

[~,ignAnalysisDataBL]= ...
    getAttendVsIgnored_BarPlotData(rmsERPData,powerDataBL,....
    rhythmIDs,subjectIdx,eotCodeIdx,showElecsLeft,showElecsRight);

if analysisMethodFlag == 0
    hPlot = hPlot2(1,1);
elseif  analysisMethodFlag == 1
    hPlot = hPlot2(1,2);
end

% combine band powers across all attention locations and TF conditions
% combine SSVEP powers across all attention locations and
% 12Hz and 16 Hz flickering stimuli

% combine across attention Locations
for iTF = 1:3
    for iNeuralMeasure = 1:8
        attDataTMP{iTF,iNeuralMeasure} = cat(3,attAnalysisData{1,iTF}{1,iNeuralMeasure},attAnalysisData{2,iTF}{1,iNeuralMeasure});
        ignDataTMP{iTF,iNeuralMeasure} = cat(3,ignAnalysisData{1,iTF}{1,iNeuralMeasure},ignAnalysisData{2,iTF}{1,iNeuralMeasure});
        ignDataBLTMP{iTF,iNeuralMeasure} = cat(3,ignAnalysisDataBL{1,iTF}{1,iNeuralMeasure},ignAnalysisDataBL{2,iTF}{1,iNeuralMeasure});
    end
end

% combine across TFs for bandPowers
for iNeuralMeasure = 1:6
    attData_combined{iNeuralMeasure} = mean(mean(mean(cat(4,attDataTMP{1,iNeuralMeasure},attDataTMP{2,iNeuralMeasure},attDataTMP{3,iNeuralMeasure}),4,nanFlag),3,nanFlag),2,nanFlag);
    ignData_combined{iNeuralMeasure} = mean(mean(mean(cat(4,ignDataTMP{1,iNeuralMeasure},ignDataTMP{2,iNeuralMeasure},ignDataTMP{3,iNeuralMeasure}),4,nanFlag),3,nanFlag),2,nanFlag);
    ignDataBL_combined{iNeuralMeasure} = mean(mean(mean(cat(4,ignDataBLTMP{1,iNeuralMeasure},ignDataBLTMP{2,iNeuralMeasure},ignDataBLTMP{3,iNeuralMeasure}),4,nanFlag),3,nanFlag),2,nanFlag);
end

SSVEP_IDs = [7 8];

for iSSVEP = 1:2
attData_SSVEP_TMP{iSSVEP} = mean(mean(mean(cat(4,attDataTMP{2,SSVEP_IDs(iSSVEP)},attDataTMP{3,SSVEP_IDs(iSSVEP)}),4,nanFlag),3,nanFlag),2,nanFlag);
ignData_SSVEP_TMP{iSSVEP} = mean(mean(mean(cat(4,ignDataTMP{2,SSVEP_IDs(iSSVEP)},ignDataTMP{3,SSVEP_IDs(iSSVEP)}),4,nanFlag),3,nanFlag),2,nanFlag);
ignDataBL_SSVEP_TMP{iSSVEP} = mean(mean(mean(cat(4,ignDataBLTMP{2,SSVEP_IDs(iSSVEP)},ignDataBLTMP{3,SSVEP_IDs(iSSVEP)}),4,nanFlag),3,nanFlag),2,nanFlag);
end

attData_combined{SSVEP_IDs(1)} = mean(cat(2,attData_SSVEP_TMP{1},attData_SSVEP_TMP{2}),2,nanFlag);
ignData_combined{SSVEP_IDs(1)} = mean(cat(2,ignData_SSVEP_TMP{1},ignData_SSVEP_TMP{2}),2,nanFlag);
ignDataBL_combined{SSVEP_IDs(1)} = mean(cat(2,ignDataBL_SSVEP_TMP{1},ignDataBL_SSVEP_TMP{2}),2,nanFlag);
count =1;
jitterAmount =0.03;
for iBar = 1:length(attData_combined)
    if iBar ==1
        attData = attData_combined{iBar};
        ignData = ignData_combined{iBar};
        diffData = attData-ignData;
        mBar = mean(diffData,1,nanFlag);
        errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
    else
        if plotBaselineSubtractedPowerFlag
            attData = log10(attData_combined{iBar})-log10(ignDataBL_combined{iBar});
            ignData = log10(ignData_combined{iBar})-log10(ignDataBL_combined{iBar});
        else
            attData = log10(attData_combined{iBar});
            ignData = log10(attData_combined{iBar});
        end
        diffData = 10*(attData-ignData); %dB
        
        
        if iBar == 2|| iBar == 7
            statData(:,count) = diffData;
            count = count+1;
        end
        
        mBar = mean(diffData,1,nanFlag);
        errorBar = std(diffData,[],1,nanFlag)./sqrt(length(diffData));
    end
    
    mBars(iBar) = mBar; %#ok<*AGROW>
    eBars(iBar) = errorBar;
    subplot(hPlot);hold(hPlot,'on');
    barPlot = bar(iBar,mBar);
    barPlot.FaceColor = colors{iBar};
    scatter(iBar,diffData,'k','filled','jitter','on','jitterAmount',jitterAmount)

    ylim(hPlot,[-2 2])
    xlim(hPlot,[0 8])
end

errorbar(hPlot,1:length(mBars),mBars,eBars,'.','color','k');

[~,p_tTest] = ttest(abs(statData(:,1)),statData(:,2));


tickLengthMedium = [0.025 0];
tickPlotLength = tickLengthMedium; fontSize = 14;
Datalabels = {'ERP','alpha','Slow-\gamma','Fast-\gamma','Bip-Slow-\gamma','Bip-Fast-\gamma','SSVEP'};

set(hPlot,'box','off','xTick',1:7,'tickLength',2*tickPlotLength,'TickDir','out',...
    'xTickLabel',Datalabels,'XTickLabelRotation',30, 'fontSize', fontSize)

if analysisMethodFlag == 0
title(hPlot,'Individual Trial Power estimation');  ylabel(hPlot, {'\Delta Power(dB)' 'Attended vs Ignored'})
% legend('location','northeast')
elseif analysisMethodFlag == 1
    title(hPlot,'Trial Avg Power estimation'); 
    
end

text(hPlot,1.8,1,['pVals alpha & SSVEP = ' num2str(p_tTest)]);




% % save Figures
% if eotCodeIdx == 1
%     eotString = 'Hits';
% elseif eotCodeIdx == 2
%     eotString = 'Misses';
% end
% 
% if length(subjectIdx) == 26
%     subString = ['subjects_N' num2str(length(subjectIdx)) '_'];
% elseif length(subjectIdx) == 1
%     subString = ['subjects_N' num2str(length(subjectIdx)) '_SubjectID_' num2str(subjectIdx) '_'];
% else
%     subString = ['subjects_N' num2str(length(subjectIdx)) '_SubjectIDs_'];
%     for i= 1:length(subjectIdx)
%         subString = strcat(subString,[num2str(subjectIdx(i)),'_']);
%     end
% end
% 
% if analysisMethodFlag == 1
%     ssvepMethod = 'MT_upon_trial-averaged_signal';
% else
%     ssvepMethod = 'MT_upon_singleTrial_signal';
% end
% 
% saveFolder = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\Figures\SRC-Attention\Topoplots\AttendedVsIgnored\');
% figName1 = fullfile(saveFolder,[protocolType '_' subString  timeEpoch '_bandPower_', ssvepMethod,'_' eotString '_tapers_' , num2str(tapers(2))]);
% 
% if analysisMethodFlag==0
%     saveas(hFig1,[figName1 '.fig'])
%     print(hFig1,[figName1 '.tif'],'-dtiff','-r600')
% end
% saveas(hFig2,[figName2 '.fig'])
% print(hFig2,[figName2 '.tif'],'-dtiff','-r600')

end


%% Accessory Functions


% % Process Attend Vs. Ignored TopoPlot data for Flickering Stimuli
% function [attData,ignData,diffData]= ...
%     getAttendVsIgnored_TopoPlotPowerData...
%     (data,rhythmIDs,refType,subjectIdx,eotCodeIdx,nanFlag)
% 
% attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
% ssvepFreqs = [1 2]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz
% 
% attData = cell(length(attendLocs),length(ssvepFreqs));
% ignData = cell(length(attendLocs),length(ssvepFreqs));
% diffData = cell(length(attendLocs),length(ssvepFreqs));
% 
% for iAttendLoc = 1:2
%     for iSSVEPFreq = 1:2
%         condition = str2double(strcat(num2str(iAttendLoc),num2str(iSSVEPFreq)));
%         switch(condition)
%             case 21
%                 attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3;
%             case 22
%                 attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2;
%             case 11
%                 attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3;
%             case 12
%                 attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2;
%         end
%         
%         attDataTMP = squeeze(mean(log10(data{refType}{rhythmIDs(iSSVEPFreq)}(subjectIdx,:,eotCodeIdx,attLoc,att_TF)),1,nanFlag));
%         ignDataTMP = squeeze(mean(log10(data{refType}{rhythmIDs(iSSVEPFreq)}(subjectIdx,:,eotCodeIdx,ign_AttLoc,ign_AttTF)),1,nanFlag));
%         diffDataTMP = attDataTMP - ignDataTMP;
%         
%         attData{iAttendLoc,iSSVEPFreq} = attDataTMP;
%         ignData{iAttendLoc,iSSVEPFreq} = ignDataTMP;
%         diffData{iAttendLoc,iSSVEPFreq} = diffDataTMP;
%     end
% end
% 
% end
% 
% 
% % Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% % Conditions
% function [attData,ignData]= getAttendVsIgnoredCombinedData...
%     (data,refType,subjectIdx,eotCodeIdx,elecsLeft,elecsRight)
% 
% attendLocs = [1 2]; % AttendLoc; 1- Right; 2-Left
% TFs = [1 2 3]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz
% 
% attData = cell(length(attendLocs),length(TFs));
% ignData = cell(length(attendLocs),length(TFs));
% 
% for iAttendLoc = 1:2
%     for iTF = 1:3
%         condition = str2double(strcat(num2str(iAttendLoc),num2str(iTF)));
%         switch(condition)
%             case 11
%                 attLoc = 1; ign_AttLoc = 2; att_TF = 1; ign_AttTF = 1; elecNums = elecsLeft{1};
%             case 21
%                 attLoc = 2; ign_AttLoc = 1; att_TF = 1; ign_AttTF = 1; elecNums = elecsRight{1};
%             case 12
%                 attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3; elecNums = elecsLeft{1};
%             case 22
%                 attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3; elecNums = elecsRight{1};
%             case 13
%                 attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2; elecNums = elecsLeft{1};
%             case 23
%                 attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2; elecNums = elecsRight{1};
%         end
%         
%         attDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx,attLoc,att_TF,:));
%         ignDataTMP = squeeze(data{refType}(subjectIdx,elecNums,eotCodeIdx,ign_AttLoc,ign_AttTF,:));
%         diffDataTMP = attDataTMP-ignDataTMP ;
%         
%         attData{iAttendLoc,iTF} = attDataTMP;
%         ignData{iAttendLoc,iTF} = ignDataTMP;
%         diffData{iAttendLoc,iTF} = diffDataTMP;
%     end
% end
% end

% Process Attend Vs. Ignored data combined for Attend Left and Attend Right
% Conditions for Analysis Electrodes

function [attData,ignData]= ...
    getAttendVsIgnored_BarPlotData...
    (rmsERPData,powerData,rhythmIDs,subjectIdx,eotCodeIdx,...
    elecsLeft,elecsRight)

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
TFs = [1 2 3]; % SSVEPFreq; 1- 24 Hz; 2- 32 Hz

attData = cell(length(attendLocs),length(TFs));
ignData = cell(length(attendLocs),length(TFs));

for iAttendLoc = 1:2
    for iTF = 1:3
        condition = str2double(strcat(num2str(iAttendLoc),num2str(iTF)));
        switch(condition)
            case 11
                attLoc = 1; ign_AttLoc = 2; att_TF = 1; ign_AttTF = 1; elecNums = elecsLeft;
            case 12
                attLoc = 1; ign_AttLoc = 2; att_TF = 2; ign_AttTF = 3; elecNums = elecsLeft;
            case 13
                attLoc = 1; ign_AttLoc = 2; att_TF = 3; ign_AttTF = 2; elecNums = elecsLeft;
            case 21
                attLoc = 2; ign_AttLoc = 1; att_TF = 1; ign_AttTF = 1; elecNums = elecsRight;
            case 22
                attLoc = 2; ign_AttLoc = 1; att_TF = 2; ign_AttTF = 3; elecNums = elecsRight;
            case 23
                attLoc = 2; ign_AttLoc = 1; att_TF = 3; ign_AttTF = 2; elecNums = elecsRight;
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
        
        attData{iAttendLoc,iTF} = attDataTMP;
        ignData{iAttendLoc,iTF} = ignDataTMP;
    end
end

end




