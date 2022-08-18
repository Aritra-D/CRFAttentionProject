% This version only analyzes total Gamma for Unipolar Ref Scheme 
function plotFigures_SFORIProtocols_HumanEEG_v2(protocolType,...
    SSVEPAnalysisMethod,removeBadElectrodeData,subjectIdx,topoplot_style)

close all;

if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

tapers = [1 1];

timingParamters.blRange = [-0.5 0];
timingParamters.stRange = [0.25 0.75];
timingParamters.erpRange = [0 0.25];

freqRanges{1} = [8 12];    % alpha
freqRanges{2} = [25 70];   % gamma
freqRanges{3} = [24 24];   % SSVEP Left Stim
freqRanges{4} = [32 32];   % SSVEP Right Stim
freqRanges{5} = [26 34];   % Slow Gamma
freqRanges{6} = [44 56];   % Fast Gamma
freqRanges{7} = [102 250]; % High Gamma

numFreqs = length(freqRanges); %#ok<*NASGU>
fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',...
    [protocolType '_tapers_' num2str(tapers(2)) '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz_v2.mat']);
if exist(fileName, 'file')
    load(fileName,'energyData','badElecs','badHighPriorityElecs') %#ok<*LOAD>
else
    [fftData,energyData,energyDataTF,badHighPriorityElecs,badElecs] = ...
        getData_SFORIProtocols(protocolType,gridType,timingParamters,tapers,freqRanges);
    save(fileName,'fftData','energyData','energyDataTF','freqRanges','badHighPriorityElecs','badElecs')
end

if SSVEPAnalysisMethod == 2
    for iRef =1:2
        energyData.dataBL{iRef}(:,:,2,:) = energyData.dataBL_trialAvg{iRef}(:,:,2,:);
        energyData.dataST{iRef}(:,:,2,:) = energyData.dataST_trialAvg{iRef}(:,:,2,:);
        energyData.dataBL_maxGamma{iRef}(:,:,2,:) = energyData.dataBL_trialAvg_maxGamma{iRef}(:,:,2,:);
        energyData.dataST_maxGamma{iRef}(:,:,2,:) = energyData.dataST_trialAvg_maxGamma{iRef}(:,:,2,:);
        
        energyData.analysisDataBL{iRef}(1,3) = energyData.analysisDataBL_trialAvg{iRef}(1,3);
        energyData.analysisDataST{iRef}(1,3) = energyData.analysisDataST_trialAvg{iRef}(1,3);
        energyData.analysisDataBL{iRef}(1,4) = energyData.analysisDataBL_trialAvg{iRef}(1,4);
        energyData.analysisDataST{iRef}(1,4) = energyData.analysisDataST_trialAvg{iRef}(1,4);
        
        energyData.analysisDataBL_maxGamma{iRef}(1,3) = energyData.analysisDataBL_trialAvg_maxGamma{iRef}(1,3);
        energyData.analysisDataST_maxGamma{iRef}(1,3) = energyData.analysisDataST_trialAvg_maxGamma{iRef}(1,3);
        energyData.analysisDataBL_maxGamma{iRef}(1,4) = energyData.analysisDataBL_trialAvg_maxGamma{iRef}(1,4);
        energyData.analysisDataST_maxGamma{iRef}(1,4) = energyData.analysisDataST_trialAvg_maxGamma{iRef}(1,4);
    end
end

% remove Bad Electrodes- converting the data for bad Elecs to NaN
subjectIdsWithRefAdjacentElecArtifacts = 12:28; 
declaredBadElectrodes = [8 9 10 11 43 44]; %  13 47 52 15 50 54

if removeBadElectrodeData
    for iSub = 1:length(subjectIdx)
        for iRef = 1:2
            clear badElecsTMP
            if any(iSub == subjectIdsWithRefAdjacentElecArtifacts)
                badElecsTMP = union(badElecs{iRef}{subjectIdx(iSub)},declaredBadElectrodes); % removes the bad artifact electrodes
            else
                badElecsTMP = badElecs{iRef}{subjectIdx(iSub)};
            end
            
            if exist('erpData','var')
                % removing ERP data for Bad Electrodes
                erpData.dataBL{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
                erpData.dataST{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
                erpData.analysisData_BL{iRef}(subjectIdx(iSub),:,badElecsTMP) = NaN;
                erpData.analysisData_ST{iRef}(subjectIdx(iSub),:,badElecsTMP) = NaN;
            end
            
            % removing Energy data (PSD & Power) for Bad Electrodes
            energyData.dataBL{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            energyData.dataST{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            energyData.dataBL_maxGamma{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            energyData.dataST_maxGamma{iRef}(subjectIdx(iSub),badElecsTMP,:,:) = NaN;
            
            for iFreqRanges = 1: length(freqRanges)
                energyData.analysisDataBL{iRef}{iFreqRanges}(subjectIdx(iSub),:,badElecsTMP) = NaN;
                energyData.analysisDataST{iRef}{iFreqRanges}(subjectIdx(iSub),:,badElecsTMP) = NaN;
                energyData.analysisDataBL_maxGamma{iRef}{iFreqRanges}(subjectIdx(iSub),:,badElecsTMP) = NaN;
                energyData.analysisDataST_maxGamma{iRef}{iFreqRanges}(subjectIdx(iSub),:,badElecsTMP) = NaN;

            end
        end
    end
end

nanFlag = 'omitnan';

% Plots
hFig1 = figure(1); 
set(hFig1,'units','normalized','outerPosition',[0 0 1 1]);
hPlot1 = getPlotHandles(3,2,[0.1 0.09, 0.25 0.8],0.02,0.005,0);
hPlot2 = getPlotHandles(2,2,[0.42 0.14, 0.24 0.7],0.06,0.1,0);
hPlot3 = getPlotHandles(2,2,[0.73 0.14, 0.24 0.7],0.06,0.1,0);

% hPlot4 = getPlotHandles(2,2,[0.75 0.55, 0.2 0.4],0.02,0.04,0);
% hPlot5 = getPlotHandles(2,2,[0.75 0.07, 0.2 0.4],0.02,0.04,0);

fontSizeLarge = 14; tickPlotLength = [0.025 0];
showMode = 'dots';
% Cap Layout & Ref Scheme related Info
capLayout = {'actiCap64'};
cL_Unipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
chanlocs_Unipolar = cL_Unipolar.chanlocs;

cL_Bipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
bL = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat'])); %#ok<*NASGU>
chanlocs_Bipolar = cL_Bipolar.eloc;

electrodeList_Unipolar = getElectrodeList('actiCap64','unipolar',1);
electrodeList_Bipolar = getElectrodeList('actiCap64','bipolar',1);
elecUnipolarList =  [24 29 57 61 26 31 58 63];
elecBipolarList = [93 94 101 96 97 102];

neuralMeasures = [1 2 4]; % Neural Measures 1:Alpha, 2: Slow Gamma, 3: Fast Gamma, 4: SSVEP 32 Hz;
colormap(jet);
colorAxis_alpha = [-2 2];
colorAxis_gamma = [-1 1.5];
if SSVEPAnalysisMethod == 1
    colorAxis_ssvep = [-1 10];
elseif SSVEPAnalysisMethod == 2
    colorAxis_ssvep = [-1 20];
end
colors = {'k','r','c'};
lineWidth = 1.2;

% Main Loop for Topoplots
refType = 1;

for i=1:2 % 1- all SF-Ori conditions, 2- max Gamma SF-Ori condition
    switch i
        case 1
            BLPower = energyData.analysisDataBL;
            STPower = energyData.analysisDataST;
        case 2
            BLPower = energyData.analysisDataBL_maxGamma;
            STPower = energyData.analysisDataST_maxGamma;
    end
    
   
    for j = 1: length(neuralMeasures) % 1- alpha, 2- gamma, 3- slow gamma, 4- fast gamma, 5- SSVEP
        if j==1
            BLPowerTopoTMP = squeeze(BLPower{1,refType}{1,neuralMeasures(j)}(:,1,:));
            STPowerTopoTMP = squeeze(STPower{1,refType}{1,neuralMeasures(j)}(:,1,:));
            colorRange = colorAxis_alpha; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
        elseif j==2 
            BLPowerTopoTMP = squeeze(BLPower{1,refType}{1,neuralMeasures(j)}(:,1,:));
            STPowerTopoTMP = squeeze(STPower{1,refType}{1,neuralMeasures(j)}(:,1,:));
            colorRange = colorAxis_gamma; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
        elseif j==3
            BLPowerTopoTMP = squeeze(BLPower{1,refType}{1,neuralMeasures(j)}(:,2,:));
            STPowerTopoTMP = squeeze(STPower{1,refType}{1,neuralMeasures(j)}(:,2,:));
            colorRange = colorAxis_ssvep; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
        end
        
        topoPlotDataTMP = 10*(squeeze(mean(log10(STPowerTopoTMP),1,nanFlag)) - squeeze(mean(log10(BLPowerTopoTMP),1,nanFlag)));
        subplot(hPlot1(j,i)); cla; hold on;
        topoplot(topoPlotDataTMP,chanLocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataTMP); 
        caxis(colorRange); cBar = colorbar;
        
        if j==3
            cTicks = [colorRange(1) colorRange(2)/2 colorRange(2)]; 
        else
            cTicks = [colorRange(1) 0 colorRange(2)]; cBar = colorbar;
        end
        tickPlotLength = get(hPlot1(1,1),'TickLength'); fontSize = 14;
        set(cBar,'Ticks',cTicks,'tickLength',4*tickPlotLength(1),'TickDir','out','fontSize',fontSize);
        if i==2 && j==3
            cBar.Label.String ='\Delta Power (dB)'; cBar.Label.FontSize = 14;
        end
        topoplot([],chanLocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecs);
    end
end

elecList = elecUnipolarList;
% for iRef= 1:2
%     switch iRef
%         case 1; elecList = elecUnipolarList;
%         case 2; elecList = elecBipolarList;
%     end
    for i=1:2 % 1- all SF-Ori conditions, 2- max Gamma SF-Ori condition
        switch i
            case 1
                BLPSD = energyData.dataBL;
                STPSD = energyData.dataST;
            case 2
                BLPSD = energyData.dataBL_maxGamma;
                STPSD = energyData.dataST_maxGamma;
        end
        
        for iTF = 1:2
            BLpsdTMP = squeeze(mean(squeeze(BLPSD{1,refType}(:,elecList,iTF,:)),2,nanFlag));
            STpsdTMP = squeeze(mean(squeeze(STPSD{1,refType}(:,elecList,iTF,:)),2,nanFlag));
            psdBLTMP = squeeze(mean(log10(BLpsdTMP),1,nanFlag));
            psdSTTMP = squeeze(mean(log10(STpsdTMP),1,nanFlag));
            deltapsdTMP = 10*(squeeze(mean(log10(STpsdTMP),1,nanFlag)) - squeeze(mean(log10(BLpsdTMP),1,nanFlag)));
            if iTF== 1
                subplot(hPlot2(refType,i))
                yyaxis left
                plot(hPlot2(refType,i),energyData.freqVals,psdBLTMP,'-g','LineWidth',lineWidth); hold (hPlot2(refType,i),'on')
                plot(hPlot2(refType,i),energyData.freqVals,psdSTTMP,'-k','LineWidth',lineWidth);
%                 ylim([-4 4])
                yyaxis right
                plot(hPlot2(refType,i),energyData.freqVals,deltapsdTMP,'b','LineWidth',lineWidth);
%                 ylim([-4 4])
            elseif iTF==2
                subplot(hPlot3(refType,i))
                yyaxis left
                plot(hPlot3(refType,i),energyData.freqVals,psdBLTMP,'-g','LineWidth',lineWidth); hold (hPlot3(refType,i),'on')
                plot(hPlot3(refType,i),energyData.freqVals,psdSTTMP,'-k','LineWidth',lineWidth);
                yyaxis right
                plot(hPlot3(refType,i),energyData.freqVals,deltapsdTMP,'b','LineWidth',lineWidth);
            end
        end
    end
% end

% for iRef= 1:2
%     switch iRef
%         case 1; elecList = elecUnipolarList;
%         case 2; elecList = elecBipolarList;
%     end
    for i=1:2 % 1- all SF-Ori conditions, 2- max Gamma SF-Ori condition
        switch i
            case 1
                BLPower = energyData.analysisDataBL;
                STPower = energyData.analysisDataST;
            case 2
                BLPower = energyData.analysisDataBL_maxGamma;
                STPower = energyData.analysisDataST_maxGamma;
        end
        
        for iTF = 1:2
            for j = 1:length(neuralMeasures)
                if j==3
                    BLPowerTMP = squeeze(mean(squeeze(BLPower{1,refType}{1,neuralMeasures(j)}(:,2,elecList)),2,nanFlag));
                    STPowerTMP = squeeze(mean(squeeze(STPower{1,refType}{1,neuralMeasures(j)}(:,2,elecList)),2,nanFlag));
                else
                    BLPowerTMP = squeeze(mean(squeeze(BLPower{1,refType}{1,neuralMeasures(j)}(:,iTF,elecList)),2,nanFlag));
                    STPowerTMP = squeeze(mean(squeeze(STPower{1,refType}{1,neuralMeasures(j)}(:,iTF,elecList)),2,nanFlag));
                end
                
                deltaPowerTMP = 10*(log10(STPowerTMP) - log10(BLPowerTMP));
                mDeltaPowerTMP = mean(deltaPowerTMP,1,nanFlag);
                semDeltaPowerTMP = std(deltaPowerTMP,[],1,nanFlag)./sqrt(size(deltaPowerTMP,1));
                
                mBars(j) = mDeltaPowerTMP; %#ok<*AGROW>
                errorBars(j) = semDeltaPowerTMP;
                
                if iTF== 1
                    if j==3
                    else
                        subplot(hPlot2(refType+1,i)); hold(hPlot2(refType+1,i),'on')
                        barPlot = bar(j,mDeltaPowerTMP);
                        barPlot.FaceColor = colors{j};
                    end

                    
                elseif iTF== 2
                    subplot(hPlot3(refType+1,i)); hold(hPlot3(refType+1,i),'on')
                    barPlot = bar(j,mDeltaPowerTMP);
                    barPlot.FaceColor = colors{j};
                end

            end
            if iTF== 1
            errorbar(hPlot2(refType+1,i),1:length(mBars)-1,mBars(1:end-1),errorBars(1:end-1),'.','color','k');
            elseif iTF== 2
            errorbar(hPlot3(refType+1,i),1:length(mBars),mBars,errorBars,'.','color','k');
            end
        end
    end
% end

fontSize = 14;
title(hPlot1(1,1),'all SF-Ori','fontSize',fontSize)
title(hPlot1(1,2),'Max Gamma SF-Ori','fontSize',fontSize)

neuralMeasuresLabels{1} = {'alpha' '(8-12 Hz)'};
neuralMeasuresLabels{2} = {'Gamma' [' (' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) ' Hz)']};
neuralMeasuresLabels{3} = {'SSVEP' '(32 Hz)'};

for i=1:3
annotation('textbox',[0.02 0.76-(i-1)*0.27 0.07 0.0252],'EdgeColor','none','HorizontalAlignment','center','String',neuralMeasuresLabels{i},'fontSize',16);
end  




for i= 1:3
    for j = 1:2
        set(hPlot1(i,j),'fontSize',fontSize)
    end
end

title(hPlot2(1,1),'all SF-Ori','fontSize',fontSize)
title(hPlot2(1,2),'Max Gamma SF-Ori','fontSize',fontSize)

title(hPlot3(1,1),'all SF-Ori','fontSize',fontSize)
title(hPlot3(1,2),'Max Gamma SF-Ori','fontSize',fontSize)

if SSVEPAnalysisMethod ==1
    yLims1 = [-4 4];
    yLims2 = [-4 11];
elseif SSVEPAnalysisMethod ==2
    yLims1 = [-4 4];
    yLims2 = [-6 25];
end

for i=1:2
subplot(hPlot2(1,i))
yyaxis left; ylim(yLims1); xlim([0 100]);ylabel(hPlot2(1,1),{'log_1_0 [power (\muV^2)]' });
set(gca,'XColor','k', 'YColor','k','XTick',[0 50 100],'YTick',[-4 0 4],'fontSize',fontSize,'box','off','tickLength',4*tickPlotLength,'TickDir','out')
yyaxis right; ylim(yLims1); xlim([0 100]);ylabel(hPlot2(1,1),{ '\Delta Power (dB)'});
set(gca,'XColor','k', 'YColor','b', 'XTick',[0 50 100],'YTick',[-4 0 4],'fontSize',fontSize,'box','off','tickLength',4*tickPlotLength,'TickDir','out')
end

for i=1:2
subplot(hPlot3(1,i))
yyaxis left; ylim(yLims2); xlim([0 100]); ylabel(hPlot3(1,1),{'log_1_0 [power (\muV^2)]' });
set(gca,'XColor','k', 'YColor','k','XTick',[0 50 100],'YTick',[-4 0 4 8 10],'fontSize',fontSize,'box','off','tickLength',4*tickPlotLength,'TickDir','out')
yyaxis right; ylim(yLims2); xlim([0 100]);ylabel(hPlot3(1,1),{ '\Delta Power (dB)'});
set(gca,'XColor','k', 'YColor','b', 'XTick',[0 50 100],'YTick',[-4 0 4 8 10],'fontSize',fontSize,'box','off','tickLength',4*tickPlotLength,'TickDir','out')
end


linkaxes(hPlot2(2,1:2)); ylim(hPlot2(2,1),[-3 2]);
linkaxes(hPlot3(2,1:2)); ylim(hPlot3(2,1),[-3 11]);

for i=1:2
    set(hPlot2(1,i),'box','off','fontSize',fontSize)
    set(hPlot3(1,i),'box','off','fontSize',fontSize)
    set(hPlot2(2,i),'box','off','fontSize',fontSize,'YTick',[-3  0 2],'tickLength',4*tickPlotLength,'TickDir','out')
    set(hPlot3(2,i),'box','off','fontSize',fontSize,'YTick',[-3 0 3 6 9],'tickLength',4*tickPlotLength,'TickDir','out')
    set(hPlot3(2,i),'box','off','fontSize',fontSize)
    xline(hPlot2(1,i),8,'k','LineWidth',lineWidth); xline(hPlot2(1,i),12,'k','LineWidth',lineWidth)
    xline(hPlot2(1,i),freqRanges{2}(1),'r','LineWidth',lineWidth); xline(hPlot2(1,i),freqRanges{2}(2),'-r','LineWidth',lineWidth)
    xline(hPlot3(1,i),8,'k','LineWidth',lineWidth); xline(hPlot3(1,i),12,'k','LineWidth',lineWidth)
    xline(hPlot3(1,i),freqRanges{2}(1),'r','LineWidth',lineWidth); xline(hPlot3(1,i),freqRanges{2}(2),'-r','LineWidth',lineWidth)
    xline(hPlot3(1,i),32,'c','LineWidth',lineWidth);
    yline(hPlot2(1,i),0,'--k','LineWidth',lineWidth)
    yline(hPlot3(1,i),0,'--k','LineWidth',lineWidth)
end


xlabel(hPlot2(1,1),'Frequency (Hz)');
xlabel(hPlot3(1,1),'Frequency (Hz)');
ylabel(hPlot2(2,1),'\Delta Power (dB)');
ylabel(hPlot3(2,1),'\Delta Power (dB)');


Datalabels = {'alpha','gamma'}; 
Datalabels2 = {'alpha','gamma','SSVEP'}; 


for i=1:2
set(hPlot2(2,i),'xTick',1:2,'xTickLabel',Datalabels,'XTickLabelRotation',30);
set(hPlot3(2,i),'xTick',1:3,'xTickLabel',Datalabels2,'XTickLabelRotation',30);
end

annotation('textbox',[0.001 0.85 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','A','fontWeight','bold','fontSize',18);
annotation('textbox',[0.34 0.85 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','B','fontWeight','bold','fontSize',18);
annotation('textbox',[0.34 0.4 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','C','fontWeight','bold','fontSize',18);
annotation('textbox',[0.64 0.85 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','D','fontWeight','bold','fontSize',18);
annotation('textbox',[0.64 0.4 0.1 0.09],'EdgeColor','none','HorizontalAlignment','center','String','E','fontWeight','bold','fontSize',18);

if SSVEPAnalysisMethod == 1
    ssvepMethod = 'SSVEP_SingleTrial';
elseif SSVEPAnalysisMethod == 2
    ssvepMethod = 'SSVEP_trialAvg';
end

saveFolder = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\Figures\SF-Ori\');
figName = fullfile(saveFolder,['allSubjects_N_' num2str(length(subjectIdx)) '_' protocolType '_tapers_',num2str(tapers(2)) '_' ssvepMethod...
    '_TG_' num2str(freqRanges{2}(1)) '-' num2str(freqRanges{2}(2)) 'Hz'...
    '_SG_' num2str(freqRanges{5}(1)) '-' num2str(freqRanges{5}(2)) 'Hz'...
    '_FG_' num2str(freqRanges{6}(1)) '-' num2str(freqRanges{6}(2)) 'Hz']);

saveas(hFig1,[figName 'v4.fig'])
print(hFig1,[figName 'v4.tif'],'-dtiff','-r600')


end