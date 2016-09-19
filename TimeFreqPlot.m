% Spectral Analysis of EEG signals for six Contrast Conditions for subjects 
% who performed GRF Protocol for all the spatial location of stimuli

clear; clc
% load('H:\data\MD\EEG\160616\GRF_0003\extractedData\parameterCombinations.mat');
% load('H:\data\MD\EEG\160616\GRF_0003\segmentedData\LFP\lfpInfo.mat');
% load('H:\data\MD\EEG\160616\GRF_0003\segmentedData\LFP\elec31.mat');

electrodeNumLists{1} = [31 32 63 64]; % Electrodes of Interest(Right)      31 (O2),32(PO10),63(PO4),64(PO8)
electrodeNumLists{2} = [29 28 60 61]; % Electrodes of Interest(Left) 

blPeriod = [-0.25 0]; erpPeriod = [0.25 0.5];
a=2; e=2; s = 1; f = 1; o =1; t= 1;

freqLims = [0 100];
figPSD = figure;
plotPos = [0.1 0.1 0.85 0.85]; plotGap = 0.1;

indexList = [23 26];
[subjectNames,expDates,protocolNames,stimType,deviceName,capLayout] = allProtocolsCRFAttentionEEG;
folderSourceString='H:'; gridType = 'EEG';


plotHandlesPSD = getPlotHandles(length(cValsUnique)/3,length(cValsUnique)/2,plotPos,plotGap,plotGap,0);
figTF = figure; colormap jet;
plotHandlesTF = getPlotHandles(length(cValsUnique)/3,length(cValsUnique)/2,plotPos,plotGap,plotGap,0);

for c=1:length(cValsUnique)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear goodPos
        try
            goodPos = parameterCombinations{a,e,s,f,o,c,t};
        catch err
            err  %#ok<NOPTS>
            dbstop in TimeFreqPlot at 21
        end

        clear dataToAnalyse
        dataToAnalyse = analogData(goodPos,:);

        clear blPos data datamean sizeDTA dataToAnalyseBLMatrix dataToAnalyseBLCorrected
        blPos = (timeVals>blPeriod(1) & timeVals<=blPeriod(2));
        data = dataToAnalyse(:,blPos);
        datamean = mean(data,2);
        sizeDTA = size(dataToAnalyse,2);
        dataToAnalyseBLMatrix = repmat(datamean,1,sizeDTA);
        %dataToAnalyseBLMatrix = repmat(mean(dataToAnalyse(:,blPos),2),1,size(dataToAnalyse,2));
        dataToAnalyseBLCorrected = dataToAnalyse - dataToAnalyseBLMatrix;
        ERPdata = mean(dataToAnalyseBLCorrected,1);
        
%         subplot(plotHandles(c));
%         plot(timeVals,ERPdata);
%         xlim([-0.1 0.5])

        Fs=1000;  
        blRange = [-0.25 0]; stRange = [0.25 0.5];
        N = round(Fs*diff(blRange)); ysbl = Fs*(0:1/N:1-1/N);
        N = round(Fs*diff(stRange)); ysst = Fs*(0:1/N:1-1/N);
        blPostf = find(timeVals>=blRange(1),1) + (1:N);
        stPostf = find(timeVals>=stRange(1),1) + (1:N);
        
        
        params.tapers = [1 1]; %(where K is less than or equal to 2TW-1)
        params.pad = -1;
        params.Fs = Fs;
        params.fpass = freqLims;
        params.trialave = 1; 
        figure(figPSD); subplot(plotHandlesPSD(c));
        [blPower,blFreq] = mtspectrumc(ERPdata(:,blPostf),params);
        plot(blFreq,log(blPower),'b'); hold on;
        [stPower,stFreq] = mtspectrumc(ERPdata(:,stPostf),params);
        plot(stFreq,log(stPower),'r');
        title(['Contrast: ' num2str(cValsUnique(c)) '%']);
        xlabel('Frequency(Hz)'); ylabel('log10(Power)'); ylim([-14 4]);
        legend('Baseline','Stimulus');
        
        figure(figTF); subplot(plotHandlesTF(c));
        movingwin = [diff(blRange) 0.01]; % in seconds. Change i from 1 to 4.
        [tfPower,tfTime,tfFreq] = mtspecgramc(ERPdata',movingwin,params);
        chPower = 10*(log10(tfPower)' - repmat(log10(blPower),1,size(tfPower,1)));
        pcolor(tfTime+timeVals(1),tfFreq,(chPower)); shading interp; xlabel('Time Period (second)'); ylabel('Frequency of LFP')
        title(['Contrast: ' num2str(cValsUnique(c)) '%']);
        colorbar;
        xlim([-0.5 0.8]); caxis([-30 30]);
end        