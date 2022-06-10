function displayPhotoDiodeData_SRCLongProtocol(protocolType,analysisTypeFlag,analysisMethodFlag,SubjectNum,AttendLoc)
% close all;
if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='EEG';      end

tapers = [1 1];

timingParamters.blRange = [-1.000 0];
timingParamters.stRange = [0.250 1.250];
timingParamters.tgRange = [-1.000 0];
timingParamters.erpRange = [0 0.250];

freqRanges{1} = [24 24];  % SSVEP Left Stim
freqRanges{2} = [32 32];  % SSVEP Right Stim
numFreqs = length(freqRanges); %#ok<*NASGU>

fileName = fullfile(folderSourceString,'Projects\Aritra_AttentionEEGProject\savedData\',['photoDiodeData_' protocolType '_tapers_' num2str(tapers(2)) '.mat']);
if exist(fileName, 'file')
    load(fileName) %#ok<*LOAD>
else
    [erpData,fftData,energyData] = ...
        getDataPhotoDiodes_SRCLongProtocols(protocolType,gridType,timingParamters,tapers,freqRanges);
    save(fileName,'erpData','fftData','energyData')
end

hFig = figure(AttendLoc);
set(hFig,'units','normalized','outerposition',[0 0 1 1])
hPlotsFig.hPlot1 = getPlotHandles(3,2,[0.06 0.65 0.3 0.3],0.01,0.01,1); linkaxes(hPlotsFig.hPlot1)
hPlotsFig.hPlot2 = getPlotHandles(3,2,[0.06 0.08 0.3 0.5],0.01,0.01,1);linkaxes(hPlotsFig.hPlot2)

hPlotsFig.hPlot3 = getPlotHandles(3,2,[0.4 0.65 0.3 0.3],0.01,0.01,1); linkaxes(hPlotsFig.hPlot3)
hPlotsFig.hPlot4 = getPlotHandles(3,2,[0.4 0.08 0.3 0.5],0.01,0.01,1);linkaxes(hPlotsFig.hPlot4)

hPlotsFig.hPlot5 = getPlotHandles(3,2,[0.75 0.54 0.2 0.4],0.01,0.01,1);linkaxes(hPlotsFig.hPlot5)
hPlotsFig.hPlot6 = getPlotHandles(3,2,[0.75 0.08 0.2 0.4],0.01,0.01,1);linkaxes(hPlotsFig.hPlot6)

if analysisTypeFlag
    
    clear energyData.dataBL energyData.dataST energyData.dataTG
    clear energyData.analysisDataBL energyData.analysisDataST energyData.analysisDataTG
    energyData.dataBL = energyData.dataBL_trialAvg;
    energyData.dataST = energyData.dataST_trialAvg;
    energyData.dataTG = energyData.dataTG_trialAvg;
    
    energyData.analysisDataBL = energyData.analysisDataBL_trialAvg;
    energyData.analysisDataST = energyData.analysisDataST_trialAvg;
    energyData.analysisDataBL = energyData.analysisDataTG_trialAvg;

end

if analysisMethodFlag
        clear energyData.dataBL energyData.dataST energyData.dataTG energyData.freqVals
    energyData.dataBL = fftData.dataBL;
    energyData.dataST = fftData.dataST;
    energyData.dataTG = fftData.dataTG;
    energyData.freqVals = fftData.freqVals;
end

for iTF = 1:3
    erpData_stimOn_Left = squeeze(mean(mean(mean(erpData.dataST(SubjectNum,1,:,AttendLoc,iTF,:),3),2),1));
    erpData_stimOn_Right = squeeze(mean(mean(mean(erpData.dataST(SubjectNum,2,:,AttendLoc,iTF,:),3),2),1));
    erpData_targetOn_Left = squeeze(mean(mean(mean(erpData.dataTG(SubjectNum,1,:,AttendLoc,iTF,:),3),2),1));
    erpData_targetOn_Right = squeeze(mean(mean(mean(erpData.dataTG(SubjectNum,2,:,AttendLoc,iTF,:),3),2),1));

    psdDataBL_stimOn_Left = squeeze(mean(mean(mean(energyData.dataBL(SubjectNum,1,:,AttendLoc,iTF,:),3),2),1));
    psdDataBL_stimOn_Right = squeeze(mean(mean(mean(energyData.dataBL(SubjectNum,2,:,AttendLoc,iTF,:),3),2),1));
    psdDataST_stimOn_Left = squeeze(mean(mean(mean(energyData.dataST(SubjectNum,1,:,AttendLoc,iTF,:),3),2),1));
    psdDataST_stimOn_Right = squeeze(mean(mean(mean(energyData.dataST(SubjectNum,2,:,AttendLoc,iTF,:),3),2),1));
    psdDataTG_targetOn_Left = squeeze(mean(mean(mean(energyData.dataTG(SubjectNum,1,:,AttendLoc,iTF,:),3),2),1));
    psdDataTG_targetOn_Right = squeeze(mean(mean(mean(energyData.dataTG(SubjectNum,2,:,AttendLoc,iTF,:),3),2),1));
    
    plot(hPlotsFig.hPlot1(iTF,1),erpData.timeVals,erpData_stimOn_Left,'b');
    plot(hPlotsFig.hPlot1(iTF,2),erpData.timeVals,erpData_stimOn_Right,'b');
    plot(hPlotsFig.hPlot3(iTF,1),erpData.timeVals,erpData_targetOn_Left,'b');
    plot(hPlotsFig.hPlot3(iTF,2),erpData.timeVals,erpData_targetOn_Right,'b');
    
    plot(hPlotsFig.hPlot2(iTF,1),energyData.freqVals,psdDataBL_stimOn_Left,'g');hold(hPlotsFig.hPlot2(iTF,1),'on')
    plot(hPlotsFig.hPlot2(iTF,2),energyData.freqVals,psdDataBL_stimOn_Right,'g');hold(hPlotsFig.hPlot2(iTF,2),'on')
    plot(hPlotsFig.hPlot4(iTF,1),energyData.freqVals,psdDataBL_stimOn_Left,'g');hold(hPlotsFig.hPlot4(iTF,1),'on')
    plot(hPlotsFig.hPlot4(iTF,2),energyData.freqVals,psdDataBL_stimOn_Right,'g');hold(hPlotsFig.hPlot4(iTF,2),'on')

    plot(hPlotsFig.hPlot2(iTF,1),energyData.freqVals,psdDataST_stimOn_Left,'k');
    plot(hPlotsFig.hPlot2(iTF,2),energyData.freqVals,psdDataST_stimOn_Right,'k');
    plot(hPlotsFig.hPlot4(iTF,1),energyData.freqVals,psdDataTG_targetOn_Left,'k');
    plot(hPlotsFig.hPlot4(iTF,2),energyData.freqVals,psdDataTG_targetOn_Right,'k');
end

title(hPlotsFig.hPlot1(1,1),'PDL');title(hPlotsFig.hPlot1(1,2),'PDR');
title(hPlotsFig.hPlot3(1,1),'PDL');title(hPlotsFig.hPlot3(1,2),'PDR');
title(hPlotsFig.hPlot5(1,1),'PDL');title(hPlotsFig.hPlot5(1,2),'PDR');
xlabel(hPlotsFig.hPlot1(3,1),'time (s)'); ylabel(hPlotsFig.hPlot1(3,1),'\mu V'); 
xlabel(hPlotsFig.hPlot3(3,1),'time (s)'); ylabel(hPlotsFig.hPlot3(3,1),'\mu V');

% legend

tickLengthPlot = 1.5*get(hPlotsFig.hPlot1(1,1),'TickLength');

set(hPlotsFig.hPlot1,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot2,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot3,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
set(hPlotsFig.hPlot4,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
% set(hPlotsFig.hPlot5,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)
% set(hPlotsFig.hPlot6,'box','off','TickDir','out','TickLength',tickLengthPlot,'fontSize',12)

rescaleData(hPlotsFig.hPlot1,-1.000,1.500,[-500 500],12);
rescaleData(hPlotsFig.hPlot3,-1.000,0,[-500 500],12);
rescaleData(hPlotsFig.hPlot2,0,100,[-5 5],12);
rescaleData(hPlotsFig.hPlot4,0,100,[-5 5],12);
% rescaleData(hPlotsFig.hPlot5,0,6,[-2 2],12);
% rescaleData(hPlotsFig.hPlot6,0,6,[-2 2],12);

% figName = fullfile(folderSourceString,[protocolType '_PhotoDiodeResults_Subject_' num2str(SubjectNum) '_analysisType',num2str(analysisTypeFlag) '_analysisMethod',num2str(analysisMethodFlag) '_tapers_' , num2str(tapers(2))]);
% saveas(hFig,[figName '.fig'])
% print(hFig,[figName '.tif'],'-dtiff','-r600')
end

function [erpData,fftData,energyData] = getDataPhotoDiodes_SRCLongProtocols(protocolType,gridType,timingParameters,tapers,freqRanges)

[subjectNames,expDates,protocolNames,dataFolderSourceString] = dataInformationSRCProtocols_HumanEEG(gridType,protocolType);

deviceName = 'BP';
capType = 'actiCap64';
numFreqs = length(freqRanges);
photoDiodeElecs = [65 66];

% Fixed indexing combinations
c = 1; s = 1; % Contrast and StimType Index are set as 1 for SRC-Long Protocols


for iSub = 1:size(subjectNames,1)
    clear powerValsBL powerValsST powerValsTG electrodeList
    clear powerValsBL_trialAvg powerValsST_trialAvg powerValsTG_trialAvg
    disp(['SUBJECT: ' num2str(iSub) ', EXPDATE:' num2str(expDates{iSub}) ', PROTOCOL:' num2str(protocolNames{iSub})])
    clear badTrials badElectrodes
    folderName = fullfile(dataFolderSourceString,'data',subjectNames{iSub},gridType,expDates{iSub},protocolNames{iSub});
    folderExtract= fullfile(folderName,'extractedData');
    folderSegment= fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderSegment,'LFP');
    
    % load LFP Info
    [~,timeVals,~,~] = loadlfpInfo(folderLFP);
    
    % Get Parameter Combinations for SRC-Long Protocols
    [parameterCombinations,cValsUnique,tValsUnique,eValsUnique,aValsUnique,sValsUnique]= ...
        loadParameterCombinations(folderExtract); %#ok<ASGLU>
    
    % timing related Information
    Fs = round(1/(timeVals(2)-timeVals(1)));
    if round(diff(timingParameters.blRange)*Fs) ~= round(diff(timingParameters.stRange)*Fs)
        disp('baseline and stimulus ranges are not the same');
    else
        range = timingParameters.blRange;
        erpRange = timingParameters.erpRange;
        rangePos = round(diff(range)*Fs);
        erpRangePos = round(diff(erpRange)*Fs);
        blPos = find(timeVals>=timingParameters.blRange(1),1)+ (1:rangePos);
        stPos = find(timeVals>=timingParameters.stRange(1),1)+ (1:rangePos);
        tgPos = find(timeVals>=timingParameters.tgRange(1),1)+ (1:rangePos);
        erpPos = find(timeVals>=timingParameters.erpRange(1),1)+ (1:erpRangePos);
        freqVals_fft = 0:1/diff(range):Fs-1/diff(range);
    end
    
    % Set up params for MT
    params.tapers   = tapers;
    params.pad      = -1;
    params.Fs       = Fs;
    params.fpass    = [0 250];
    params.trialave = 1;
    
    %         % Set up movingWindow parameters for time-frequency plot
    %         winSize = 0.1;
    %         winStep = 0.025;
    %         movingwin = [winSize winStep];
    
    % Electrode and trial related Information
    photoDiodeChannels = [65 66];
    electrodeList = photoDiodeElecs;
    
    % Get bad trials
    badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
    if ~exist(badTrialFile,'file')
        disp('Bad trial file does not exist...');
        badElecs = []; badTrials=[];
    else
        [badTrials,badElectrodes] = loadBadTrials(badTrialFile);
        badElecsAll = unique([badElectrodes.badImpedanceElecs; badElectrodes.noisyElecs; badElectrodes.flatPSDElecs; badElectrodes.flatPSDElecs]);
        disp([num2str(length(badTrials)) ' bad trials']);
    end
    
    % Main Loop
    for iElec = 1:length(electrodeList)
        clear x
        %                     disp(['Processing electrode no: ' num2str(electrodeList{iElec}{1})])
        if iElec == length(electrodeList)
            disp('Processed Photodiode Data')
        end
        x = load(fullfile(folderLFP,['elec' num2str(electrodeList(iElec)) '.mat']));
        for iEOTCode = 1: length(eValsUnique)
            for iAttendLoc = 1: length(aValsUnique)
                for iTF = 1: length(tValsUnique)
                    clear goodPos_stimOnset goodPos_targetOnset
                    goodPos_stimOnset = setdiff(parameterCombinations.stimOnset{c,iTF,iEOTCode,iAttendLoc,s},badTrials);
                    goodPos_targetOnset = setdiff(parameterCombinations.targetOnset{c,iTF,iEOTCode,iAttendLoc,s},badTrials);
                    
                    if isempty(goodPos_stimOnset)
                        disp('No entries for this combination..')
                    else
                        if iElec ==1
                            disp([iEOTCode iAttendLoc iTF length(goodPos_stimOnset)])
                            trialNums(iSub,iEOTCode,iAttendLoc,iTF) = length(goodPos_stimOnset);
                        end
                        
                        erp_stimOnset = mean(x.analogData.stimOnset(goodPos_stimOnset,:),1);
                        erp_targetOnset = mean(x.analogData.targetOnset(goodPos_targetOnset,:),1);
                        % Baseline Correction
                        erp_stimOnset = erp_stimOnset - repmat(mean(erp_stimOnset(:,blPos),2),1,size(erp_stimOnset,2));
                        erp_targetOnset = erp_targetOnset - repmat(mean(erp_targetOnset(:,blPos),2),1,size(erp_targetOnset,2));
                        
                        erpStim(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = erp_stimOnset;
                        erpTarget(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = erp_targetOnset;
                        RMSValsBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = rms(erp_stimOnset(blPos));
                        RMSValsERP_Stim(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = rms(erp_stimOnset(erpPos));
                        RMSValsERP_Target(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = rms(erp_targetOnset(erpPos));
                        
                        % Baseline Corrected analogData 
                        
                        % fft
                        
                        fftBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData.stimOnset(goodPos_stimOnset,blPos),[],2))))); %#ok<*NASGU,*AGROW>
                        fftST(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData.stimOnset(goodPos_stimOnset,stPos),[],2)))));
                        fftTG(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData.targetOnset(goodPos_targetOnset,tgPos),[],2)))));
                        
                        % Segmenting data according to timePos
                        dataBL = x.analogData.stimOnset(goodPos_stimOnset,blPos)';
                        dataStimOnset = x.analogData.stimOnset(goodPos_stimOnset,stPos)';
                        dataTargetOnset = x.analogData.targetOnset(goodPos_targetOnset,tgPos)';
                        
                        % power spectral density estimation
                        [tmpEBL,freqValsBL] = mtspectrumc(dataBL,params);
                        [tmpEST,freqValsST] = mtspectrumc(dataStimOnset,params);
                        [tmpETG,freqValsTG] = mtspectrumc(dataTargetOnset,params);
                        
                        if isequal(freqValsBL,freqValsST) && isequal(freqValsBL,freqValsTG)
                            freqVals = freqValsBL;
                        end
                        
                        psdBL(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEBL);
                        psdST(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEST);
                        psdTG(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpETG);
                        
                        for iFreqRange=1:2
                            powerValsBL{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEBL,freqVals,freqRanges{iFreqRange}));
                            powerValsST{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEST,freqVals,freqRanges{iFreqRange}));
                            powerValsTG{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpETG,freqVals,freqRanges{iFreqRange}));
                        end
                        % Segmenting data according to timePos
                        dataBL_avg = mean(x.analogData.stimOnset(goodPos_stimOnset,blPos),1)';
                        dataStimOnset_avg = mean(x.analogData.stimOnset(goodPos_stimOnset,stPos),1)';
                        dataTargetOnset_avg = mean(x.analogData.targetOnset(goodPos_targetOnset,tgPos),1)';
                        
                        % power spectral density estimation
                        [tmpEBL_avg,~] = mtspectrumc(dataBL_avg,params);
                        [tmpEST_avg,~] = mtspectrumc(dataStimOnset_avg,params);
                        [tmpETG_avg,~] = mtspectrumc(dataTargetOnset_avg,params);
                        
                        
                        psdBL_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEBL_avg);
                        psdST_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpEST_avg);
                        psdTG_trialAvg(iSub,iElec,iEOTCode,iAttendLoc,iTF,:) = conv2Log(tmpETG_avg);
                        
                        for iFreqRange=1:2
                            powerValsBL_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEBL_avg,freqVals,freqRanges{iFreqRange}));
                            powerValsST_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpEST_avg,freqVals,freqRanges{iFreqRange}));
                            powerValsTG_trialAvg{iFreqRange}(iSub,iElec,iEOTCode,iAttendLoc,iTF) = conv2Log(getMeanEnergyForAnalysis(tmpETG_avg,freqVals,freqRanges{iFreqRange}));
                        end
                    end
                end
            end
        end
    end
end

% Structuring data for all data
erpData.dataST = erpStim;
erpData.dataTG = erpTarget;
erpData.analysisData_BL = RMSValsBL;
erpData.analysisData_ST = RMSValsERP_Stim;
erpData.analysisData_TG = RMSValsERP_Target;
erpData.timeVals = timeVals;
erpData.trialNum = trialNums;

fftData.dataBL = fftBL;
fftData.dataST = fftST;
fftData.dataTG = fftTG;
fftData.freqVals = freqVals_fft;
fftData.trialNum = trialNums;

energyData.dataBL = psdBL;
energyData.dataST = psdST;
energyData.dataTG = psdTG;
energyData.dataBL_trialAvg = psdBL_trialAvg;
energyData.dataST_trialAvg = psdST_trialAvg;
energyData.dataTG_trialAvg = psdTG_trialAvg;
energyData.analysisDataBL = powerValsBL;
energyData.analysisDataST = powerValsST;
energyData.analysisDataTG = powerValsTG;
energyData.analysisDataBL_trialAvg = powerValsBL_trialAvg;
energyData.analysisDataST_trialAvg = powerValsST_trialAvg;
energyData.analysisDataTG_trialAvg = powerValsTG_trialAvg;
energyData.freqVals = freqVals;
energyData.trialNum = trialNums;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%  Accessory Functions  %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load LFP Info
function [analogChannelsStored,timeVals,goodStimPos,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
load(fullfile(folderLFP,'lfpInfo.mat'));
analogChannelsStored=sort(analogChannelsStored); %#ok<NODEF>
if ~exist('analogInputNums','var')
    analogInputNums=[];
end
end


% Get parameter combinations
function [parameterCombinations,cValsUnique,tValsUnique,eValsUnique,...
    aValsUnique,sValsUnique] = ...
    loadParameterCombinations(folderExtract)

load(fullfile(folderExtract,'parameterCombinations.mat')); %#ok<*LOAD>
end

% Get Bad Trials
function [badTrials,badElecs] = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
end

% Get Induced LFP data by subtracting trialaveraged ERP data from trialwise LFP Data
% function Y = removeERP(X)
% Y = X-repmat(mean(X,1),size(X,1),1);
% end

% Get MeanEnergy for different frequency bands
function eValue = getMeanEnergyForAnalysis(mEnergy,freq,freqRange)

posToAverage = intersect(find(freq>=freqRange(1)),find(freq<=freqRange(2)));
eValue   = sum(mEnergy(posToAverage));
end

% Rescale data
function rescaleData(plotHandles,xMin,xMax,yLims,labelSize)

[numRows,numCols] = size(plotHandles);
% labelSize=14;
for i=1:numRows
    for j=1:numCols
        hold(plotHandles(i,j),'on');
        axis(plotHandles(i,j),[xMin xMax yLims]);
        if (i==numRows && j==1)
                set(plotHandles(i,j),'fontSize',labelSize);
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


