a = 3; e = 3  ; s = 1; f = 1; o = 5; c = 5; t= 1; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
goodPos = parameterCombinations{a,e,s,f,o,c,t};

dataToAnalyse = analogData(goodPos,:);
blPeriod = [-0.2 0];
blPos = (timeVals>blPeriod(1) & timeVals<=blPeriod(2));
data = dataToAnalyse(:,blPos);
datamean = mean(data,2);
sizeDTA = size(dataToAnalyse,2);
dataToAnalyseBLMatrix = repmat(datamean,1,sizeDTA);
%dataToAnalyseBLMatrix = repmat(mean(dataToAnalyse(:,blPos),2),1,size(dataToAnalyse,2));
dataToAnalyseBLCorrected = dataToAnalyse - dataToAnalyseBLMatrix;

% figure (1);
% for iLoop = 1:size(dataToAnalyseBLCorrected,1)
%     plot(timeVals,dataToAnalyseBLCorrected(iLoop,:));
% %     hold on
%     pause;
% end

figure (2);
plot(timeVals,dataToAnalyseBLCorrected,'color',[0.5 0.5 0.5],'linewidth',1); hold on;
plot(timeVals,mean(dataToAnalyseBLCorrected,1),'color','k','linewidth',2); axis tight; hold off