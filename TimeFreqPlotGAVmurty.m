% Spectral Analysis of EEG signals for six Contrast Conditions for subjects 
% who performed GRF Protocol for all the spatial location of stimuli

clear; clc; close all;

electrodeNumLists{1} = [31 32 63 64]; % Electrodes of Interest(Right)      31 (O2),32(PO10),63(PO4),64(PO8)
electrodeNumLists{2} = [29 28 60 61]; % Electrodes of Interest(Left) 

blRange = [-0.5 0]; stRange = [0 0.5];
a=1; e=1; s = 1; f = 1; o =1; t= 1;

freqLims = [0 100];
figPSD = figure;
plotPos = [0.1 0.1 0.85 0.85]; plotGap = 0.1;

% indexList = [23 26];
% [subjectNames,expDates,protocolNames,stimType,deviceName,capLayout] = allProtocolsCRFAttentionEEG;
folderSourceString='H:'; gridType = 'EEG';
% 

% plotHandlesPSD = getPlotHandles(length(cValsUnique)/3,length(cValsUnique)/2,plotPos,plotGap,plotGap,0);
% figTF = figure; colormap jet;
% plotHandlesTF = getPlotHandles(length(cValsUnique)/3,length(cValsUnique)/2,plotPos,plotGap,plotGap,0);

i=1;
% for i=1:length(indexList)
    subjectName = 'PM';%subjectNames{indexList(i)};
    expDate = '291215';%expDates{indexList(i)};
    protocolName = 'GAV_0001';%protocolNames{indexList(i)};
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','parameterCombinations.mat'));    
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','LFP','lfpInfo.mat'));           
    
%     blPos = (timeVals>blPeriod(1) & timeVals<=blPeriod(2));
%     erpPos = (timeVals>erpPeriod(1) & timeVals<=erpPeriod(2)); 
        Fs=2500;  
%         blRange = [-0.25 0]; stRange = [0.25 0.5];
        N = round(Fs*diff(blRange)); ysbl = Fs*(0:1/N:1-1/N);
        N = round(Fs*diff(stRange)); ysst = Fs*(0:1/N:1-1/N);        
        blPos = find(timeVals>=blRange(1),1) + (1:N);
        stPos = find(timeVals>=stRange(1),1) + (1:N);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%
     figure(i)
     plotHandlesPSD = getPlotHandles(length(cValsUnique)/3,length(cValsUnique)/3,plotPos,plotGap,plotGap,0);
     electrodeNumList = electrodeNumLists{1}; % Right Side
    
     AlphaRange = [8 12]; BetaRange = [16 30]; GammaRange = [30 80];
     AlphaPos = find(ysbl>=AlphaRange(1) & ysbl<=AlphaRange(2));
     BetaPos = find(ysbl>=BetaRange(1) & ysbl<=BetaRange(2));
     GammaPos = find(ysbl>=GammaRange(1) & ysbl<=GammaRange(2));
     
     for c=1:length(cValsUnique)
        clear goodPos
      
        goodPos = parameterCombinations{a,e,s,f,o,c,t};
       
         analogData = [];
            for j = 1:length(electrodeNumList) % Rigth side
                    elecNum = electrodeNumList(j);
                    electrodeData = load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','LFP',['elec' num2str(elecNum) '.mat']));
                    analogData = cat(1,analogData,electrodeData.analogData(goodPos,:));
            end
       
               clear dataMean sizeDTA dataToAnalyseBLMatrix dataToAnalyseBLCorrected
                
                dataMean = mean(analogData(:,blPos),2);
                sizeDTA = size(analogData,2);
                dataToAnalyseBLMatrix = repmat(dataMean,1,sizeDTA);
                dataToAnalyseBLCorrected = analogData;% - dataToAnalyseBLMatrix;
%                 erpData = mean(dataToAnalyseBLCorrected,1);
                
        
        fftbl = abs(fft(dataToAnalyseBLCorrected(:,blPos),[],2));
        fftst = abs(fft(dataToAnalyseBLCorrected(:,stPos),[],2));
        
        AlphaPowerChange = (fftst(:,AlphaPos))./(fftbl(:,AlphaPos));
        BetaPowerChange = (fftst(:,BetaPos))./(fftbl(:,BetaPos));
        GammaPowerChange = (fftst(:,GammaPos))./(fftbl(:,GammaPos));
        
        MeanAlphaPowerChange(c)= log10(mean(mean(AlphaPowerChange,1),2));
        MeanBetaPowerChange(c)= log10(mean(mean(BetaPowerChange,1),2));
        MeanGammaPowerChange(c)= log10(mean(mean(GammaPowerChange,1),2));
        
        stdAlphaPowerChange(c) = log10(std(mean(AlphaPowerChange,1)));
        stdBetaPowerChange(c) = log10(std(mean(BetaPowerChange,1)));
        stdGammaPowerChange(c) = log10(std(mean(GammaPowerChange,1)));
        
%         ERPdata = mean(dataToAnalyseBLCorrected,1);
        subplot(plotHandlesPSD(c));
        plot(ysbl,log10(mean(fftbl)),'g');hold on;
        plot(ysst,log10(mean(fftst)),'r');
        legend('Baseline','Stimulus')
        xlabel('Frequency(Hz)'); ylabel('log_1_0 (Amplitude)');
        title(['Contrast = ',num2str(cValsUnique(c)), ' %']);
        xlim([0 100]); ylim([0 5]);
     end
%         
%         plot(timeVals,ERPdata);
%         xlim([-0.1 0.5])

%         hold(plotHandlesPSD,'on');
figure(i+2)
scaledxaxis = [log2(cValsUnique(2))-(log2(cValsUnique(3))-log2(cValsUnique(2))) log2(cValsUnique(2:end))];
plot(scaledxaxis,MeanAlphaPowerChange,'b-'); hold on;
plot(scaledxaxis,MeanBetaPowerChange,'k-');
plot(scaledxaxis,MeanGammaPowerChange,'r-'); hold off;

% errorbar(scaledxaxis,MeanAlphaPowerChange,stdAlphaPowerChange,'b-'); hold on;
% errorbar(scaledxaxis,MeanBetaPowerChange,stdBetaPowerChange,'k-');
% errorbar(scaledxaxis,MeanGammaPowerChange,stdGammaPowerChange,'r-'); hold off;

ax = gca;
ax.XTick = [scaledxaxis];
ax.XTickLabel = {'0','6.25', '12.5', '25', '50', '100'};
legend('Change in Alpha Power','Change in Beta Power','Change in Gamma Power')
xlabel('Contrast(%)'),ylabel('Change in Power at different Freq. Bands');
% end        

%         params.tapers = [1 1]; %(where K is less than or equal to 2TW-1)
%         params.pad = -1;
%         params.Fs = Fs;
%         params.fpass = freqLims;
%         params.trialave = 1; 
%         figure(figPSD); subplot(plotHandlesPSD(c));
%         [blPower,blFreq] = mtspectrumc(ERPdata(:,blPostf),params);
%         plot(blFreq,log(blPower),'b'); hold on;
%         [stPower,stFreq] = mtspectrumc(ERPdata(:,stPostf),params);
%         plot(stFreq,log(stPower),'r');
%         title(['Contrast: ' num2str(cValsUnique(c)) '%']);
%         xlabel('Frequency(Hz)'); ylabel('log10(Power)'); ylim([-14 4]);
%         legend('Baseline','Stimulus');
%         
%         figure(figTF); subplot(plotHandlesTF(c));
%         movingwin = [diff(blRange) 0.01]; % in seconds. Change i from 1 to 4.
%         [tfPower,tfTime,tfFreq] = mtspecgramc(ERPdata',movingwin,params);
%         chPower = 10*(log10(tfPower)' - repmat(log10(blPower),1,size(tfPower,1)));
%         pcolor(tfTime+timeVals(1),tfFreq,(chPower)); shading interp; xlabel('Time Period (second)'); ylabel('Frequency of LFP')
%         title(['Contrast: ' num2str(cValsUnique(c)) '%']);
%         colorbar;
%         xlim([-0.5 0.8]); caxis([-30 30]);
% end        