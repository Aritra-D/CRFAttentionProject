function plotFigures_MappingProtocols_HumanEEG(protocolType,...
    SSVEPAnalysisMethod,removeBadElectrodeData,subjectIdx,topoplot_style)

close all;

if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

tapers = [1 1];

timingParamters.blRange = [-0.5 0];
timingParamters.stRange = [0.25 0.75];
timingParamters.erpRange = [0 0.25];

freqRanges{1} = [8 12];    % alpha
freqRanges{2} = [20 66];   % gamma
freqRanges{3} = [24 24];   % SSVEP Left Stim
freqRanges{4} = [32 32];   % SSVEP Right Stim
freqRanges{5} = [20 34];   % Slow Gamma
freqRanges{6} = [36 66];   % Fast Gamma
freqRanges{7} = [102 250]; % High Gamma

numFreqs = length(freqRanges); %#ok<*NASGU>

fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',[protocolType '_tapers_' num2str(tapers(2)) '.mat']);
if exist(fileName, 'file')
    load(fileName,'energyData','badElecs','badHighPriorityElecs') %#ok<*LOAD>
else
    [fftData,energyData,energyDataTF,badHighPriorityElecs,badElecs] = ...
        getData_MappingProtocols(protocolType,gridType,timingParamters,tapers,freqRanges);
    save(fileName,'fftData','energyData','energyDataTF','badHighPriorityElecs','badElecs')
end

% Shift to power computed 
if SSVEPAnalysisMethod == 2
    for iRef =1:2
        energyData.analysisDataBL{iRef}(1,3) = energyData.analysisDataBL_trialAvg{iRef}(1,3);
        energyData.analysisDataST{iRef}(1,3) = energyData.analysisDataST_trialAvg{iRef}(1,3);
        energyData.analysisDataBL{iRef}(1,4) = energyData.analysisDataBL_trialAvg{iRef}(1,4);
        energyData.analysisDataST{iRef}(1,4) = energyData.analysisDataST_trialAvg{iRef}(1,4);
    end
end

% remove Bad Electrodes- converting the data for bad Elecs to NaN
if removeBadElectrodeData
    for iSub = 1:length(subjectIdx)
        for iProt = 1:4
            for iRef = 1:2
                clear badElecsTMP
                badElecsTMP = badElecs{iRef}{subjectIdx(iSub),iProt};
                
                if exist('erpData','var')
                    % removing ERP data for Bad Electrodes
                    erpData.dataBL{iRef}(subjectIdx(iSub),iProt,badElecsTMP,:,:) = NaN;
                    erpData.dataST{iRef}(subjectIdx(iSub),iProt,badElecsTMP,:,:) = NaN;
                    erpData.analysisData_BL{iRef}(subjectIdx(iSub),iProt,:,badElecsTMP) = NaN;
                    erpData.analysisData_ST{iRef}(subjectIdx(iSub),iProt,:,badElecsTMP) = NaN;
                end
                
                % removing Energy data (PSD & Power) for Bad Electrodes
                energyData.dataBL{iRef}(subjectIdx(iSub),iProt,badElecsTMP,:,:) = NaN;
                energyData.dataST{iRef}(subjectIdx(iSub),iProt,badElecsTMP,:,:) = NaN;
                
                for iFreqRanges = 1: length(freqRanges)
                    energyData.analysisDataBL{iRef}{iFreqRanges}(subjectIdx(iSub),iProt,:,badElecsTMP) = NaN;
                    energyData.analysisDataST{iRef}{iFreqRanges}(subjectIdx(iSub),iProt,:,badElecsTMP) = NaN;
                end
            end
        end
    end
end

nanFlag = 'omitnan';

% Plotting
% Display Properties
hFig = figure(1);
set(hFig,'units','normalized','outerposition',[0 0 1 1])
hPlot1 = getPlotHandles(5,4,[0.07 0.1 0.47 0.85],0.01,0.03,1); % Topoplots for alpha
hPlot2 = getPlotHandles(3,3,[0.59 0.1 0.4 0.85],0.04,0.06,1);
    
colormap(jet);
neuralMeasures = [1 5 6 3 4]; % Neural Measures 1:Alpha, 2: Slow Gamma, 3: Fast Gamma, 4: SSVEP 24 Hz; 4: SSVEP 32 Hz;
colorAxis_alpha = [-2 2];
colorAxis_gamma = [-2 2];
if SSVEPAnalysisMethod == 1
    colorAxis_ssvep = [-1 3];
elseif SSVEPAnalysisMethod == 2
    colorAxis_ssvep = [-1 10];
end

% Cap Layout & Ref Scheme related Info
capLayout = {'actiCap64'};
cL_Unipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
chanlocs_Unipolar = cL_Unipolar.chanlocs;

cL_Bipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
bL = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat'])); %#ok<*NASGU>
chanlocs_Bipolar = cL_Bipolar.eloc;

electrodeList_Unipolar = getElectrodeList('actiCap64','unipolar',1);
electrodeList_Bipolar = getElectrodeList('actiCap64','bipolar',1);

highPriorityUnipolarElectrodes = getHighPriorityElectrodes('actiCap64');
highPriorityBipolarElectrodes = [93 94 101 102 96 97 111 107 112];

elecUnipolarList = [24 29 57 61 26 31 58 63];
elecList_Unipolar_Left = [24 29 57 61];
elecList_Unipolar_Right = [26 31 58 63];

elecBipolarList = [93 94 101 96 97 102];
elecList_Bipolar_Left = [93 94 101];
elecList_Bipolar_Right = [96 97 102];

% Main Loop for Topoplots
for i= 1:5 % Neural Measures 1:Alpha, 2: Slow Gamma, 3: Fast Gamma, 4: SSVEP 24 Hz; 4: SSVEP 32 Hz;
    for j= 1:4 % 1: Eccentricity 2 deg, 2: Ecc 4 deg, 3: Ecc 6 deg, 4: Ecc 8 deg
        clear BLpower STPower topoPlotDataTMP
        if i== 1
            BLPower = squeeze(energyData.analysisDataBL{1,1}{1,neuralMeasures(i)}(:,j,1,:));
            STPower = squeeze(energyData.analysisDataST{1,1}{1,neuralMeasures(i)}(:,j,1,:));
            colorRange = colorAxis_alpha; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
        elseif i==2 || i==3
            BLPower = squeeze(energyData.analysisDataBL{1,2}{1,neuralMeasures(i)}(:,j,1,:));
            STPower = squeeze(energyData.analysisDataST{1,2}{1,neuralMeasures(i)}(:,j,1,:));
            colorRange = colorAxis_gamma; chanLocs = chanlocs_Bipolar; showElecs = elecBipolarList;
        elseif i==4 || i==5
            BLPower = squeeze(energyData.analysisDataBL{1,1}{1,neuralMeasures(i)}(:,j,2,:));
            STPower = squeeze(energyData.analysisDataST{1,1}{1,neuralMeasures(i)}(:,j,2,:));
            colorRange = colorAxis_ssvep; chanLocs = chanlocs_Unipolar; showElecs = elecUnipolarList;
        end
        topoPlotDataTMP = 10*(squeeze(mean(log10(STPower),1,nanFlag)) - squeeze(mean(log10(BLPower),1,nanFlag)));
        subplot(hPlot1(i,j)); cla; hold on;
        topoplot_murty(topoPlotDataTMP,chanLocs,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataTMP); caxis(colorRange);colorbar;
        topoplot_murty([],chanLocs,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecs);
    end
end

fontSize = 12;
strList = {'2 ','4 ','6 ','8 '};
for j=1:4
title(hPlot1(1,j),[strList{j} char(176)],'fontSize', fontSize)
end

neuralMeasuresLabels{1} = {'alpha' '(8-12 Hz)'};
neuralMeasuresLabels{2} = {'Slow Gamma' '(20-34 Hz)'};
neuralMeasuresLabels{3} = {'Fast Gamma' '(36-66 Hz)'};
neuralMeasuresLabels{4} = {'SSVEP' '(24 Hz)'};
neuralMeasuresLabels{5} = {'SSVEP' '(32 Hz)'};

stimList = 2:2:8;
colors = {'k',[0.4940 0.1840 0.5560],'m','g','c'};

% Main Loop for delta power plots for different Neural measures

for iNeuralMeasure = 1:5
    for iPlot = 1:3
        clear BLpower STPower deltaPower
        if iNeuralMeasure== 1
            switch iPlot
                case 1; elecs = elecList_Unipolar_Left;
                case 2; elecs = elecList_Unipolar_Right;
                case 3; elecs = elecUnipolarList;
            end
            BLPower = squeeze(mean(energyData.analysisDataBL{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,1,elecs),4,nanFlag));
            STPower = squeeze(mean(energyData.analysisDataST{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,1,elecs),4,nanFlag));
            
            deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
            mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
            semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
            
            errorbar(hPlot2(iNeuralMeasure,iPlot),stimList,mDeltapower,semPower,...
                '-o','color',colors{1},'MarkerSize',10,'MarkerEdgeColor',...
                colors{1},'MarkerFaceColor',colors{1},...
                'LineWidth',1.5);
            
        elseif iNeuralMeasure == 2 || iNeuralMeasure == 3
            switch iPlot
                case 1; elecs = elecList_Bipolar_Left;
                case 2; elecs = elecList_Bipolar_Right;
                case 3; elecs = elecBipolarList;
            end
            BLPower = squeeze(mean(energyData.analysisDataBL{1,2}{1,neuralMeasures(iNeuralMeasure)}(:,:,1,elecs),4,nanFlag));
            STPower = squeeze(mean(energyData.analysisDataST{1,2}{1,neuralMeasures(iNeuralMeasure)}(:,:,1,elecs),4,nanFlag));
            
            deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
            mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
            semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
            

            errorbar(hPlot2(2,iPlot),stimList,mDeltapower,semPower,...
                '-o','color',colors{iNeuralMeasure},'MarkerSize',10,'MarkerEdgeColor',...
                colors{iNeuralMeasure},'MarkerFaceColor',colors{iNeuralMeasure},...
                'LineWidth',1.5); hold (hPlot2(2,iPlot),'on');
            
            
        elseif iNeuralMeasure == 4 || iNeuralMeasure == 5

            if iNeuralMeasure == 4 && iPlot == 1
                elecs = elecList_Unipolar_Right;
                BLPower = squeeze(mean(energyData.analysisDataBL{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,2,elecs),4,nanFlag));
                STPower = squeeze(mean(energyData.analysisDataST{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,2,elecs),4,nanFlag));
                deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
                mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
                semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
                
                errorbar(hPlot2(3,1),stimList,mDeltapower,semPower,...
                    '-o','color',colors{4},'MarkerSize',10,'MarkerEdgeColor',...
                    colors{4},'MarkerFaceColor',colors{4},...
                    'LineWidth',1.5); hold on;
                
            elseif iNeuralMeasure == 5 && iPlot == 2
                elecs = elecList_Unipolar_Left;
                BLPower = squeeze(mean(energyData.analysisDataBL{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,2,elecs),4,nanFlag));
                STPower = squeeze(mean(energyData.analysisDataST{1,1}{1,neuralMeasures(iNeuralMeasure)}(:,:,2,elecs),4,nanFlag));
                deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
                mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
                semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
                errorbar(hPlot2(3,2),stimList,mDeltapower,semPower,...
                    '-o','color',colors{5},'MarkerSize',10,'MarkerEdgeColor',...
                    colors{5},'MarkerFaceColor',colors{5},...
                    'LineWidth',1.5); hold on;

            elseif iNeuralMeasure == 5 && iPlot == 3
                elecs = elecList_Unipolar_Left;
                BLPower_Left = squeeze(energyData.analysisDataBL{1,1}{1,neuralMeasures(5)}(:,:,2,elecs));
                STPower_Left = squeeze(energyData.analysisDataST{1,1}{1,neuralMeasures(5)}(:,:,2,elecs));

                elecs = elecList_Unipolar_Right;
                BLPower_Right = squeeze(energyData.analysisDataBL{1,1}{1,neuralMeasures(4)}(:,:,2,elecs));
                STPower_Right = squeeze(energyData.analysisDataST{1,1}{1,neuralMeasures(4)}(:,:,2,elecs));
                
                BLPower_combined = cat(3,BLPower_Left,BLPower_Right);
                STPower_combined = cat(3,STPower_Left,STPower_Right);
                
                BLPower = squeeze(mean(BLPower_combined,3,nanFlag));
                STPower = squeeze(mean(STPower_combined,3,nanFlag));
                
                deltaPower = 10*(log10(STPower) - log10(BLPower)); % subjectWise
                mDeltapower = squeeze(mean(deltaPower,1,nanFlag)); % mean across subjects
                semPower = std(deltaPower,1,nanFlag)./sqrt(size(deltaPower,1)); % sem across subjects
                errorbar(hPlot2(3,3),stimList,mDeltapower,semPower,...
                    '--o','color',colors{5},'MarkerSize',10,'MarkerEdgeColor',...
                    colors{5},'MarkerFaceColor',colors{5},...
                    'LineWidth',1.5); hold on;
            end
        end
    end
end


% FSData = [-2.1 0.57 6.26];
% semFSData = [0 0 0];


tickLength = 2*get(hPlot2(1,1),'TickLength');
xTickLabels = {'2','4','6','8'};
set(hPlot2,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',12,'Xlim',[0 10],'xTick',2:2:8,'xTickLabel',xTickLabels,'XTickLabelRotation',0)
% set(hPlot2,'box','off','TickDir','out','TickLength',2*tickLength,'fontSize',14,'Xlim',[0 10],'xTick',2:2:8,'xTickLabel',xTickLabels,'XTickLabelRotation',0)

linkaxes(hPlot2(1,:)); ylim(hPlot2(1,1),[-4 0]);
linkaxes(hPlot2(2,:)); ylim(hPlot2(2,1),[-1.5 0.5]);
linkaxes(hPlot2(3,:)); ylim(hPlot2(3,1),[-2 10]);

xlabel(hPlot2(3,1),'azi/ele/diam (degree)')
ylabel(hPlot2(3,1),'Change in Power (dB)')

title(hPlot2(1,1),'Left Elecs');
title(hPlot2(1,2),'Right Elecs');
title(hPlot2(1,3),'Combined');

neuralMeasuresLabels{1} = {'alpha' '(8-12 Hz)'};
neuralMeasuresLabels{2} = {'Slow Gamma' '(20-34 Hz)'};
neuralMeasuresLabels{3} = {'Fast Gamma' '(36-66 Hz)'};
neuralMeasuresLabels{4} = {'SSVEP' '(24 Hz)'};
neuralMeasuresLabels{5} = {'SSVEP' '(32 Hz)'};

for i=1:5
annotation('textbox',[0.0 0.88-(i-1)*0.18 0.07 0.0252],'EdgeColor','none','HorizontalAlignment','center','String',neuralMeasuresLabels{i},'fontSize',12);
end  

for i= 1:5
    for j = 1:4
        set(hPlot1(i,j),'fontSize',12,'tickLength',2*tickLength,'TickDir','out')
    end
end

% title(hPlot1(1,1),'alpha (8-12 Hz)'); title(hPlot2(1,1),'alpha (8-12 Hz)')
% title(hPlot1(1,2),'gamma (20-66 Hz)'); title(hPlot2(1,2),'gamma (20-66 Hz)')
% title(hPlot1(1,3),'SSVEP'); title(hPlot2(1,3),'SSVEP')

% textH1 = getPlotHandles(1,1,[0.2 0.95 0.01 0.01]);
% textH2 = getPlotHandles(1,1,[0.7 0.95 0.01 0.01]);
% 
% 
% textString1 = 'Unipolar, N_S_U_B = 11,';
% 
% textString2 = 'Bipolar, N_S_U_B = 11';
% 
% set(textH1,'Visible','Off'); set(textH2,'Visible','Off')
% text(0.35,1.15,textString1,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH1);
% text(0.35,1.15,textString2,'unit','normalized','fontsize',18,'fontweight','bold','parent',textH2);

figName = fullfile(folderSourceString,[ 'allSubjects, N_11_',protocolType, num2str(tapers(2))]);
saveas(hFig,[figName '.fig'])
print(hFig,[figName '.tif'],'-dtiff','-r600')


    
    
end


