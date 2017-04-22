% CRF Plots from Spiking Data

clear; close all;

blRange = [-0.25 0]; stRange = [0. 0.25];

a=1; e=1; s = 1; f = 1; t= 1;  % Stimulus Parameter Combinations

plotPos = [0.1 0.1 0.85 0.85]; plotGap = 0.1;

% Data Loading
indexList = [473]; %[];
[expDates,protocolNames,stimType] = getAllProtocols('kesari','Microelectrode');
folderSourceString='H:'; subjectName = 'kesari';gridType = 'Microelectrode';
% load(fullfile(folderSourceString,'programs','DataMap','ReceptiveFieldData',[subjectName,'MicroelectrodeRFDataSpikes.mat']));
highRMSElectrodes = [22 40 42 49 50 52 53 54 60 62 63 65 71 71 73 74 75 80 81 82 83 85 89 90 92 93 94];
electrodeNumLists{1} = highRMSElectrodes; % Electrodes of Interest

for i=1:length(indexList)

%     subjectName = subjectNames{indexList(i)};
    expDate = expDates{indexList(i)};
    protocolName = protocolNames{indexList(i)};
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'extractedData','parameterCombinations.mat'));
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','LFP','lfpInfo.mat'));  
    load(fullfile(folderSourceString,'data',subjectName,gridType,expDate,protocolName,'segmentedData','Spikes','spikeInfo.mat')); 
    
    
    
   

     
     electrodeNumList = electrodeNumLists{1};
     
     ChangeinMeanFiringRateAcrossContrasts=  cell(1,length(cValsUnique));
     
     for c=1:length(cValsUnique)
         

         clear spikeDataElecwise baselineFiringRate stimulusFiringRate
         clear neuralInfo
         clear goodPos
         clear psthVals xs
         clear ChangeinMeanFiringRate
         binWidthMS = 10;
         
         spikeDataElecwise = cell(length(oValsUnique),length(electrodeNumList));

            for iOri = 1:length(oValsUnique) 
                goodPos = parameterCombinations{a,e,s,f,iOri,c,t};
                
                for j = 1:length(electrodeNumList) % Rigtht side 
                    disp(num2str([c iOri j]));
                    elecNum = electrodeNumList(j);
                    electrodeData = load(fullfile(folderSourceString,'data',subjectName...
                        ,gridType,expDate,protocolName,'segmentedData','Spikes',['elec' num2str(elecNum) '_SID' num2str(SourceUnitID(i)) '.mat']));
                    spikeDataElecwise{iOri,j} = electrodeData.spikeData(goodPos);
                    [psthVals,xs] = getPSTH(electrodeData.spikeData(goodPos),binWidthMS,[timeVals(1) timeVals(end)]);
                    
                    blPos = find(xs>=blRange(1),1)+ (1:(diff(blRange))/(binWidthMS/1000));
                    stPos = find(xs>=stRange(1),1)+ (1:(diff(stRange))/(binWidthMS/1000));
    
                     baselineFiringRate(iOri,j) = mean(psthVals(blPos));
                     stimulusFiringRate(iOri,j) = mean(psthVals(stPos));
                end
                    
                    
                    
            end                      
               ChangeinMeanFiringRate = stimulusFiringRate-baselineFiringRate;
               ChangeinMeanFiringRateAcrossContrasts{c} = ChangeinMeanFiringRate;
                    
               figure(i)
               scaledxaxis = [log2(cValsUnique(2))-(log2(cValsUnique(3))-log2(cValsUnique(2))) log2(cValsUnique(2:end))];
               MeanChangeinFiringRateAcrossOriandElec(c) = mean(mean(ChangeinMeanFiringRateAcrossContrasts{1,c},1),2);
               SEMChangeinFiringRateAcrossElec(c) = std(mean(ChangeinMeanFiringRateAcrossContrasts{1,c},1))./sqrt(length(mean(ChangeinMeanFiringRateAcrossContrasts{1,c},1)));
               
                        
                        
                        
     end
     errorbar(scaledxaxis,(MeanChangeinFiringRateAcrossOriandElec),(SEMChangeinFiringRateAcrossElec),'ro','LineWidth',2); hold on;
%         paramStart = [1,1];
%         x = lsqcurvefit(@nakaRushton,paramStart,scaledxaxis,MeanChangeinFiringRateAcrossOriandElec);
%         
%         ydataprime = nakaRushton(x,scaledxaxis);
%         plot(scaledxaxis,ydataprime,'r-');hold on
%         legend('Actual','Estimated');
        
        ax = gca;
        ax.XTick = scaledxaxis;
        ax.XTickLabel = {'0','1.5','3.1','6.2', '12.5', '25', '50', '100'};
        xlabel('Contrast(%)'),ylabel('Change in Firing Rate (spikes/sec)');
        title(['Change in Firing Rate (Baseline vs. Stimulus) for Monkey: ',subjectName]);
        
        X = scaledxaxis';
        Y = MeanChangeinFiringRateAcrossOriandElec';
        
        
        % Curve Fitting
        fo = fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0,0],...
               'Upper',[Inf,max(X)],...
               'StartPoint',[0 0]);
        ft = fittype('a*(x^n/(x^n + b^n))','problem','n','options',fo);
        [curve2,gof2] = fit(X,Y,ft,'problem',2);
        plot(curve2,'r-');xlabel('Contrast(%)'),ylabel('Change in Firing Rate (spikes/sec)');
end