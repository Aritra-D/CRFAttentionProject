% Spectral Analysis of EEG signals for Contrast 
% Conditions for Monkey Microelectrode Data
% who performed GRF Protocol for stimuli centred on the RF of
% microelectrode grid

clear; close all; %clc

blRange = [-0.25 0]; stRange = [0.25 0.5];
a=1; e=1; s = 1; f = 1; t= 1; % o =1; % Stimulus Parameters

freqLims = [0 100];

plotPos = [0.1 0.1 0.85 0.85]; plotGap = 0.1;

% Data Loading
indexList = [473]; %[];
[expDates,protocolNames,stimType] = getAllProtocols('kesari','Microelectrode');
folderSourceString='H:'; subjectName = 'kesari';gridType = 'Microelectrode';
load(fullfile(folderSourceString,'programs','DataMap','ReceptiveFieldData',[subjectName,'MicroelectrodeRFData.mat']));
electrodeNumLists{1} = [highRMSElectrodes]; % Electrodes of Interest
% electrodeNumLists{2} = [29 28 60 61]; % Electrodes of Interest

% for i=1:length(indexList)
i=1;
%     subjectName = subjectNames{indexList(i)};
    expDate = expDates{indexList(i)};
    protocolName = protocolNames{indexList(i)};
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','parameterCombinations.mat'));    
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','LFP','lfpInfo.mat'));           
    

        Fs=2000;  
%         blRange = [-0.25 0]; stRange = [0.25 0.5];
        N = round(Fs*diff(blRange)); ysbl = Fs*(0:1/N:1-1/N);
        N = round(Fs*diff(stRange)); ysst = Fs*(0:1/N:1-1/N);        
        blPos = find(timeVals>=blRange(1),1) + (1:N);
        stPos = find(timeVals>=stRange(1),1) + (1:N);
        blPostf = find(timeVals>=blRange(1),1) + (1:N);
        stPostf = find(timeVals>=stRange(1),1) + (1:N);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%
     figure(i)
     [plotHandlesPSD,~,plotPosPSD] = getPlotHandles((length(cValsUnique))/4,(length(cValsUnique))/2,plotPos,plotGap,plotGap,0);
     
     figure(i+length(indexList)); colormap jet; %figure(i+numel(indexList));
     [plotHandlesBasePower,~,plotPosBasePower] = getPlotHandles((length(cValsUnique))/4,(length(cValsUnique))/2,plotPos,plotGap,plotGap,0);
%      
%      figure(i+numel(indexList)); colormap jet;
%      plotHandlesTF = getPlotHandles((length(cValsUnique))/4,(length(cValsUnique))/2,plotPos,plotGap,plotGap,0);
     
%      figure(i+2*numel(indexList));
     
     electrodeNumList = electrodeNumLists{1}; % Right Side
    
     AlphaRange = [8 12]; BetaRange = [16 30]; GammaRange = [30 80]; SSVEPRange = 2*tValsUnique(t);
     
     
     for c=[7,8];%1:length(cValsUnique)
         
         analogData = [];
         clear analogDataElecwise
         clear goodPos      
         
         analogDataElecwise = cell(length(cValsUnique),length(oValsUnique),length(electrodeNumList));
            for iOri = 1:length(oValsUnique) 
                goodPos = parameterCombinations{a,e,s,f,iOri,c,t};
                
                for j = 1:length(electrodeNumList) % Rigtht side 
                    disp(num2str([iOri j]));
                    elecNum = electrodeNumList(j);
                    electrodeData = load(fullfile(folderSourceString,'data',subjectName...
                        ,gridType,expDate,protocolName,'segmentedData','LFP',['elec' num2str(elecNum) '.mat']));
                    analogDataElecwise{c,iOri,j} = electrodeData.analogData(goodPos,:);
                    analogData = cat(1,analogData,electrodeData.analogData(goodPos,:));
                end
            end                      
               clear dataMean sizeDTA dataToAnalyseBLMatrix dataToAnalyseBLCorrected
                
                dataMean = mean(analogData(:,blPos),2);
                sizeDTA = size(analogData,2);
                dataToAnalyseBLMatrix = repmat(dataMean,1,sizeDTA);
                dataToAnalyseBLCorrected = analogData;% - dataToAnalyseBLMatrix;
%                 erpData = mean(dataToAnalyseBLCorrected,1);   %You get one value for Raw EEG amplitude for all 2048 Time Points 
                
     end
     
           
        params.tapers = [1 1]; %(where K is less than or equal to 2TW-1)
        params.pad = -1;
        params.Fs = Fs;
        params.fpass = freqLims;
        params.trialave = 1; 
        
    for c=[7,8];
        
       
        
        
        
%         blPowerpooledElec = [];
%         [blPower,blFreq] = mtspectrumc(dataToAnalyseBLCorrected(:,blPostf)',params);
%         plot(blFreq,log(mean(blPower,2)),'b'); hold on;
%         [stPower,stFreq] = mtspectrumc(dataToAnalyseBLCorrected(:,stPostf)',params);
%         plot(stFreq,log(mean(stPower,2)),'r');
%         title(['Contrast: ' num2str(cValsUnique(c)) '%']);
%         xlabel('Frequency(Hz)'); ylabel('log10(Power)'); ylim([-1 10]);
%         legend('Baseline','Stimulus');
%         
%         figure(i+numel(indexList));
%         subplot(plotHandlesTF(c));
% %         movingwin = [0.25 0.025];
%         movingwin = [diff(blRange) 0.01]; % in seconds. Change i from 1 to 4.
%         [tfPower,tfTime,tfFreq] = mtspecgramc(dataToAnalyseBLCorrected',movingwin,params);
%         chPower = 10*(log10(tfPower)' - repmat(log10(blPower),1,size(tfPower,1)));
%         pcolor(tfTime+timeVals(1),tfFreq,(chPower)); shading interp; xlabel('Time Period (second)'); ylabel('Frequency')
%         title(['Contrast: ' num2str(cValsUnique(c)) '%']);
%         colorbar; caxis([-10 10]);
%         xlim([-0.5 0.75]); 
        
        clear blPower1 blFreq1 stPower1 stFreq1
        for iOri = 1:length(oValsUnique)
                for iElec = 1:size(analogDataElecwise,3)
                [blPower1(iOri,iElec,:),blFreq1] = mtspectrumc(squeeze(analogDataElecwise{c,iOri,iElec}(:,blPostf))',params);
        %          blPowerpooledElec = cat(2,blPowerpooledElec,blPower);
                [stPower1(iOri,iElec,:),stFreq1] = mtspectrumc(squeeze(analogDataElecwise{c,iOri,iElec}(:,stPostf))',params);
        %          stPowerpooledElec = cat(2,stPowerpooledElec,stPower);
                end
                figure(i);
                subplot(plotHandlesPSD(c));
                plot(blFreq1,squeeze(mean(log10(blPower1(iOri,:,:)),2)),'b'); 
                hold on;
                plot(stFreq1,squeeze(mean(log10(stPower1(iOri,:,:)),2)));
                title(['Contrast: ' num2str(cValsUnique(c)) '%']);
                xlabel('Frequency(Hz)'); ylabel('log10(Power)'); ylim([-1 5]);
                legend('Baseline','stimulus');
                drawnow;

                figure(i+length(indexList));
                subplot(plotHandlesBasePower(c));
                plot(blFreq1,(squeeze(mean(log10(stPower1(iOri,:,:)),2))...
                    -squeeze(mean(log10(blPower1(iOri,:,:)),2))));hold on;
                plot(blFreq1,0*(squeeze(mean(log10(stPower1(iOri,:,:)),2))...
                    -squeeze(mean(log10(blPower1(iOri,:,:)),2))))
                title(['Contrast: ' num2str(cValsUnique(c)) '%']);
                xlabel('Frequency(Hz)'); ylabel('Change in Power wrt to Baseline'); ylim([-0.5 1.2]);

                commonBaseline = mean(log10(blPower1(iOri,:,:)),1);
                SSVEPPos = find(blFreq1 == SSVEPRange);
                powerChangePerElectrode = 10*(squeeze(log10(stPower1(iOri,:,:))...
                    -commonBaseline));
                meanPowerChange = mean(powerChangePerElectrode,1);
                stdPowerChange = std(powerChangePerElectrode,[],1);%/sqrt(size(powerChangePerElectrode,1));
                powerChangeSSVEP(c,iOri,1) = meanPowerChange(SSVEPPos);
                powerChangeSSVEP(c,iOri,2) = stdPowerChange(SSVEPPos);

%                 powerChangeSSVEPAllElecs(c,iOri,:,:) = powerChangePerElectrode;




        %         figure(i+numel(indexList));
        %         subplot(plotHandlesTF(c));
        % %         movingwin = [0.25 0.025];
        %         movingwin = [diff(blRange) 0.01]; % in seconds. Change i from 1 to 4.
        %         [tfPower(iOri,iElec,:),tfTime(iOri,iElec,:),tfFreq(iOri,iElec,:)] = mtspecgramc(squeeze(analogDataElecwise{iOri,iElec}(:,blPostf))',movingwin,params);
        %         chPower = 10*(log10(squeeze(tfPower(iOri,iElec,:))') - repmat(log10(blPower1(iOri,iElec,:),1,size(tfPower(iOri,iElec,:),2))));
        %         pcolor(tfTime(iOri,iElec,:)+timeVals(1),tfFreq,(chPower)); shading interp; xlabel('Time Period (second)'); ylabel('Frequency')
        %         title(['Contrast: ' num2str(cValsUnique(c)) '%']);
        %         colorbar; caxis([-10 10]);
        %         xlim([-0.5 0.75]); 
        end      
%         AlphaPos = find(blFreq>=AlphaRange(1) & blFreq<=AlphaRange(2));
%         BetaPos = find(blFreq>=BetaRange(1) & blFreq<=BetaRange(2));
%         GammaPos = find(blFreq>=GammaRange(1) & blFreq<=GammaRange(2));
%         SSVEPPos = find(blFreq == SSVEPRange);
%         
% %         clear AlphaPowerChange BetaPowerChange GammaPowerChange
%         AlphaPowerMean = 10*log10((mean(stPower1(:,AlphaPos),2)./(mean(blPower1(:,AlphaPos),2))));
%         BetaPowerMean = 10*log10((mean(stPower1(:,BetaPos),2)./(mean(blPower1(:,BetaPos),2))));
%         GammaPowerMean = 10*log10((mean(stPower1(:,GammaPos),2)./(mean(blPower1(:,GammaPos),2))));
%         
%         AlphaPowerChangeElecWise(c) = mean(AlphaPowerMean,1);
%         semAlphaPowerChange(c) = std(AlphaPowerMean)/sqrt(length(AlphaPowerMean));
%         BetaPowerChangeElecWise(c) = mean(BetaPowerMean,1);
%         semBetaPowerChange(c) = std(BetaPowerMean)/sqrt(length(BetaPowerMean));
%         GammaPowerChangeElecWise(c) = mean(GammaPowerMean,1);
%         semGammaPowerChange(c) = std(GammaPowerMean)/sqrt(length(GammaPowerMean));
        
%         AlphaPowerChange(c) = 10*log10(mean((stPower(AlphaPos,:)),1))-10*log10(mean((blPower(AlphaPos,:)),1));
%         BetaPowerChange(c) = 10*log10(mean((stPower(BetaPos,:)),1))-10*log10(mean((blPower(BetaPos,:)),1));
%         GammaPowerChange(c) = 10*log10(mean((stPower(GammaPos,:)),1))-10*log10(mean((blPower(GammaPos,:)),1));
%         SSVEPPowerChange(c) = 10*log10(stPower(SSVEPPos))-10*log10(blPower(SSVEPPos));
%         
%         semAlphaPowerChange(c) = std((10*log10(stPower(AlphaPos,:))-10*log10(blPower(AlphaPos,:))))/sqrt(length(stPower(AlphaPos,:)));
%         semBetaPowerChange(c) = std((10*log10(stPower(BetaPos,:))-10*log10(blPower(BetaPos,:))))/sqrt(length(stPower(BetaPos,:)));
%         semGammaPowerChange(c) = std((10*log10(stPower(GammaPos,:))-10*log10(blPower(GammaPos,:))))/sqrt(length(stPower(GammaPos,:)));

%         powerChangeSSVEPCon(c) = {powerChangeSSVEP};
       
     end
     
     
%         figure(i+2*numel(indexList));
%         scaledxaxis = [log2(cValsUnique(2))-(log2(cValsUnique(3))-log2(cValsUnique(2))) log2(cValsUnique(2:end))];
% %         plot(scaledxaxis,AlphaPowerChange,'bo-','LineWidth',2); hold on;
% %         plot(scaledxaxis,BetaPowerChange,'ko-','LineWidth',2);
% %         plot(scaledxaxis,GammaPowerChange,'ro-','LineWidth',2);hold on;
%         
%         errorbar(scaledxaxis,AlphaPowerChangeElecWise,semAlphaPowerChange,'bo-','LineWidth',2); hold on;
%         errorbar(scaledxaxis,BetaPowerChangeElecWise,semBetaPowerChange,'ko-','LineWidth',2);
%         errorbar(scaledxaxis,GammaPowerChangeElecWise,semGammaPowerChange,'ro-','LineWidth',2); 
% %         plot(scaledxaxis,SSVEPPowerChange,'co-','LineWidth',2); hold on;
%         ax = gca;
%         ax.XTick = [scaledxaxis];
%         ax.XTickLabel = {'0','1.5','3.1','6.2', '12.5', '25', '50', '100'};
%         legend('Change in Alpha Power','Change in Beta Power','Change in Gamma Power ','change in SSVEP Power')
%         xlabel('Contrast(%)'),ylabel('Change in Power (decibel)');
%         title(['Change in Power at Alpha-Beta-Gamma for Monkey: ',subjectName]);
%         
    

        
%  end        