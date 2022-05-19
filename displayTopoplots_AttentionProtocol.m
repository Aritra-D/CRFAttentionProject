function displayTopoplots_AttentionProtocol(protocolType,analysisMethodFlag,subjectIdx,timeEpoch,eotCodeIdx,removeBadElectrodeData,topoplot_style,colorMap)

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

% Plots
hFig1 = figure(1); colormap(colorMap)
set(hFig1,'units','normalized','outerPosition',[0 0 1 1]);
hPlot1 = getPlotHandles(5,3,[0.1 0.05, 0.5 0.85],0.02,0.04,0);

hFig2 = figure(2); colormap(colorMap)
set(hFig2,'units','normalized','outerPosition',[0 0 1 1]);
hPlot2 = getPlotHandles(4,3,[0.1 0.05, 0.5 0.85],0.04,0.04,0);

nanFlag = 'omitnan';

cLimsRaw1 = [-1 2];
cLimsRaw2 = [-1 2];
cLimsRaw3 = [-1 2];

cLimsDiff1 = [-1 2];
cLimsDiff2 = [-1 2];
cLimsDiff3 = [-1 2];

rhythmIdx = [1 5 6];
fontSizeLarge = 14; tickLengthMedium = [0.025 0];

showMode = 'dots';
showElecsUnipolarLeft = [24 29 57 61]; %[24 26 29 30 31 57 58 61 62 63];%[93 94 101 102 96 97 111 107 112];
showElecsUnipolarRight = [26 31 58 63];
showElecsBipolarLeft = [93 94 101];
showElecsBipolarRight = [96 97 102];

capLayout = {'actiCap64'};
% Get the electrode list
% clear cL bL chanlocs iElec electrodeList

cL_Unipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
chanlocs_Unipolar = cL_Unipolar.chanlocs;

cL_Bipolar = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
bL = load(fullfile(pwd,'programs\ProgramsMAP','Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat'])); %#ok<*NASGU>
chanlocs_Bipolar = cL_Bipolar.eloc;

if strcmp(timeEpoch,'StimOnset')
    analysisData = energyData.analysisDataST;
elseif strcmp(timeEpoch,'PreTarget')
    analysisData = energyData.analysisDataTG;
end

for iRhythm = 1:3
    clear topoPlotDataLeft topoPlotDataRight topoPlotDiff
    switch iRhythm
        case 1; cLimsTopoRaw = cLimsRaw1; cLimsTopoDiff = cLimsDiff1;
        case 2; cLimsTopoRaw = cLimsRaw2; cLimsTopoDiff = cLimsDiff2;
        case 3; cLimsTopoRaw = cLimsRaw3; cLimsTopoDiff = cLimsDiff3;
    end
topoPlotDataLeft = squeeze(mean(log10(analysisData{1}{1,rhythmIdx(iRhythm)}(subjectIdx,:,eotCodeIdx,2,1)),1,nanFlag));
topoPlotDataRight = squeeze(mean(log10(analysisData{1}{1,rhythmIdx(iRhythm)}(subjectIdx,:,eotCodeIdx,1,1)),1,nanFlag));
topoPlotDiff = 10*(topoPlotDataLeft-topoPlotDataRight);

figure(1)
subplot(hPlot1(iRhythm,1)); cla; hold on;
topoplot_murty(topoPlotDataLeft,chanlocs_Unipolar,'electrodes','on','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataLeft); caxis(cLimsTopoRaw); colorbar
topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarRight); 

subplot(hPlot1(iRhythm,2)); cla; hold on;
topoplot_murty(topoPlotDataRight,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataRight); caxis(cLimsTopoRaw); colorbar
topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarLeft);

subplot(hPlot1(iRhythm,3)); cla; hold on;
topoplot_murty(topoPlotDiff,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDiff); caxis(cLimsTopoDiff); colorbar
topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',[showElecsUnipolarLeft showElecsUnipolarRight]);

if iRhythm == 2|| iRhythm == 3
    clear topoPlotDataLeft topoPlotDataRight topoPlotDiff
    topoPlotDataLeft = squeeze(mean(log10(analysisData{2}{1,rhythmIdx(iRhythm)}(subjectIdx,:,eotCodeIdx,2,1)),1,nanFlag));
    topoPlotDataRight = squeeze(mean(log10(analysisData{2}{1,rhythmIdx(iRhythm)}(subjectIdx,:,eotCodeIdx,1,1)),1,nanFlag));
    topoPlotDiff = 10*(topoPlotDataLeft-topoPlotDataRight);
    
    subplot(hPlot1(2+iRhythm,1)); cla; hold on;
    topoplot_murty(topoPlotDataLeft,chanlocs_Bipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataLeft); caxis(cLimsTopoRaw); colorbar
    topoplot_murty([],chanlocs_Bipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsBipolarRight);
    
    subplot(hPlot1(2+iRhythm,2)); cla; hold on;
    topoplot_murty(topoPlotDataRight,chanlocs_Bipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataRight); caxis(cLimsTopoRaw); colorbar
    topoplot_murty([],chanlocs_Bipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsBipolarLeft);
    
    subplot(hPlot1(2+iRhythm,3)); cla; hold on;
    topoplot_murty(topoPlotDiff,chanlocs_Bipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDiff); caxis(cLimsTopoDiff); colorbar
    topoplot_murty([],chanlocs_Bipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',[showElecsBipolarLeft showElecsBipolarRight]);
end
end

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


% SSVEP Topoplots (Figure 2)
rhythmIdx = [3 4];
if analysisMethodFlag
    cLimsSSVEPRaw = [-3 -1];
    cLimsSSVEPDiff = [-3 5];
else
    cLimsSSVEPRaw = [-2 1];
    cLimsSSVEPDiff = [-1 1];
end

for iRhythm = 1:2
    clear topoPlotDataLeft topoPlotDataRight topoPlotDiff
    
    topoPlotDataLeft = squeeze(mean(log10(analysisData{1}{1,rhythmIdx(iRhythm)}(subjectIdx,:,eotCodeIdx,2,2)),1,nanFlag));
    topoPlotDataRight = squeeze(mean(log10(analysisData{1}{1,rhythmIdx(iRhythm)}(subjectIdx,:,eotCodeIdx,1,3)),1,nanFlag));
    topoPlotDiff = 10*(topoPlotDataLeft-topoPlotDataRight);
    
    figure(2)
    subplot(hPlot2(iRhythm,1)); cla; hold on;
    topoplot_murty(topoPlotDataLeft,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataLeft); caxis(cLimsSSVEPRaw);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarRight);
    
    subplot(hPlot2(iRhythm,2)); cla; hold on;
    topoplot_murty(topoPlotDataRight,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataRight); caxis(cLimsSSVEPRaw);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarLeft);
    
    subplot(hPlot2(iRhythm,3)); cla; hold on;
    topoplot_murty(topoPlotDiff,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDiff); caxis(cLimsSSVEPDiff);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',[showElecsUnipolarLeft showElecsUnipolarRight]);
    
    clear topoPlotDataLeft topoPlotDataRight topoPlotDiff
    topoPlotDataLeft = squeeze(mean(log10(analysisData{1}{1,rhythmIdx(iRhythm)}(subjectIdx,:,eotCodeIdx,2,3)),1,nanFlag));
    topoPlotDataRight = squeeze(mean(log10(analysisData{1}{1,rhythmIdx(iRhythm)}(subjectIdx,:,eotCodeIdx,1,2)),1,nanFlag));
    topoPlotDiff = 10*(topoPlotDataLeft-topoPlotDataRight);
    
    subplot(hPlot2(iRhythm+2,1)); cla; hold on;
    topoplot_murty(topoPlotDataLeft,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataLeft); caxis(cLimsSSVEPRaw);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarRight);
    
    subplot(hPlot2(iRhythm+2,2)); cla; hold on;
    topoplot_murty(topoPlotDataRight,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDataRight); caxis(cLimsSSVEPRaw);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',showElecsUnipolarLeft);
    
    subplot(hPlot2(iRhythm+2,3)); cla; hold on;
    topoplot_murty(topoPlotDiff,chanlocs_Unipolar,'electrodes','off','style',topoplot_style,'drawaxis','off','nosedir','+X','emarkercolors',topoPlotDiff); caxis(cLimsSSVEPDiff);colorbar;
    topoplot_murty([],chanlocs_Unipolar,'electrodes','on','style','blank','drawaxis','off','nosedir','+X','plotchans',[showElecsUnipolarLeft showElecsUnipolarRight]);
end

annotation('textbox',[0.12 0.97 0.1 0.0241],'EdgeColor','none','String','Attend Left','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.18+ 0.115 0.97 0.1 0.0241],'EdgeColor','none','String','Attend Right','fontSize',14,'fontWeight','bold');
annotation('textbox',[0.33+ 0.115 0.97 0.3 0.0241],'EdgeColor','none','String','Attend Left - Attend Right','fontSize',14,'fontWeight','bold');

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

saveFolder = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\Figures\SRC-Attention\Topoplots');
figName1 = fullfile(saveFolder,[protocolType '_' subString  timeEpoch '_bandPower_', eotString '_tapers_' , num2str(tapers(2))]);
figName2 = fullfile(saveFolder,[protocolType '_' subString  timeEpoch '_SSVEP_', ssvepMethod,'_' eotString '_tapers_' , num2str(tapers(2))]);

if analysisMethodFlag
saveas(hFig1,[figName1 '.fig'])
print(hFig1,[figName1 '.tif'],'-dtiff','-r600')
end
saveas(hFig2,[figName2 '.fig'])
print(hFig2,[figName2 '.tif'],'-dtiff','-r600')
end
