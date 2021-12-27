function displayResultsCommonProtocolsMonkeyEEG(subjectName,expDate,folderSourceString,gridType,analysisType)

if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='Microelectrode';      end
% if ~exist('gridLayout','var');          gridLayout=6;                   end

% [subjectNames_all,expDates_all,protocolNames_all,~,~,~] = allCommonProtocolsHumanEEG;
% protocolIDs = find(strcmp(subjectName,subjectNames_all)& strcmp(expDate,expDates_all)); % only SubjectName is
% used because protocols have different exp dates; ideally it should use
% both SubjectName and expDate as all protocols should be recorded in a
% single session
% protocolIDs are arranged as 1- Eyes Open, 2- Eyes Closed, 3- SF-Ori

% expDates = expDates_all(protocolIDs);
% protocolNames = protocolNames_all(protocolIDs);

for iRefScheme = 1:2
    % Display Properties
    hFig = figure(iRefScheme);
    set(hFig,'units','normalized','outerposition',[0 0 1 1])
    hPlotsFig.hPlot1 = getPlotHandles(2,1,[0.1 0.1 0.3 0.8],0.01,0.01,1);
    hPlotsFig.hPlot2 = getPlotHandles(4,5,[0.5 0.1 0.45 0.8],0.01,0.01,1); linkaxes
    
    %% display PSDs for Eyes-open and Eyes-Closed Protocol
%     for iProt = 1:2
%         folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDates{iProt},protocolNames{iProt});
%         folderLFP = fullfile(folderName,'segmentedData','LFP');
%         load(fullfile(folderLFP,'lfpInfo.mat')); %#ok<*LOAD>
%         
%         photoDiodeIDs = [20 21];
%         unipolarEEGChannelsStored = setdiff(analogChannelsStored,photoDiodeIDs);
%         EEGChannelsExcluded = [1 2 5 8 9 10 11 15 16];
%         EEGChannelsStored{1} = setdiff(unipolarEEGChannelsStored,EEGChannelsExcluded); % unipolar channels
%         
%         bipolarEEGChannelsStored(1,:) = [12 12 13 14 14 13 18 18 18];
%         bipolarEEGChannelsStored(2,:) = [ 4  3 12  6  7 14 13 17 19]; % bipolar channels
%         EEGChannelsStored{2} = bipolarEEGChannelsStored;
%         
%         %         for iElec = 1:length(EEG_ChannelsStored)
%         %             clear x
%         %             x = load(fullfile(folderLFP,['elec' num2str(EEG_ChannelsStored(iElec)) '.mat']));
%         %             data(iElec,:,:) = x.analogData;
%         %         end
%         for iElec = 1:size(EEGChannelsStored{iRefScheme},2)
%             clear x
%             if iRefScheme == 1
%                 clear x
%                 disp(['Processing electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(iElec))])
%                 x = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(iElec)) '.mat']));
%             elseif iRefScheme == 2
%                 clear x1 x2 x
%                 disp(['Processing bipolar electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) ' - ' num2str(EEGChannelsStored{iRefScheme}(2,iElec))])
%                 x1 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) '.mat']));
%                 x2 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(2,iElec)) '.mat']));
%                 x.analogData = x1.analogData-x2.analogData;
%             end
%             data(iElec,:,:) = x.analogData;
%         end
%         
%         mData = squeeze(mean(data,1)); % mean across electrodes
%         
%         T = 1.000;
%         Fs = round(1/(timeVals(2)-timeVals(1)));
%         freqLims = [0 100];
%         if strcmp(analysisType,'FFT')
%             freqVals = 0:1/T:Fs-1/T;
%             fftSignal = mean(log10(abs(fft(mData,[],2)))); % mean across trials
%             if iProt ==1
%                 plot(hPlotsFig.hPlot1(1),freqVals,fftSignal,'-g','LineWidth',1.5); hold(hPlotsFig.hPlot1(1),'on');
%             elseif iProt ==2
%                 plot(hPlotsFig.hPlot1(1),freqVals,fftSignal,'-k','LineWidth',1.5);
%             end
%         elseif strcmp(analysisType,'MT')
%         end
%     end
%     xlim(hPlotsFig.hPlot1(1),freqLims);
    
    %% display PSDs for SF-Ori Protocol
    
    folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDate,'GRF_001');
    folderExtract= fullfile(folderName,'extractedData');
    folderSegment= fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderName,'segmentedData','LFP');
    
            load(fullfile(folderLFP,'lfpInfo.mat')); %#ok<*LOAD>

        freqLims = [0 100];

            photoDiodeIDs = [];
        unipolarEEGChannelsStored = setdiff(analogChannelsStored,photoDiodeIDs);
        EEGChannelsExcluded = [];%[1 2 5 8 9 10 11 15 16];
        EEGChannelsStored{1} = setdiff(unipolarEEGChannelsStored,EEGChannelsExcluded); % unipolar channels
        
        bipolarEEGChannelsStored(1,:) = [4 3 4   6 8  8 10 ];
        bipolarEEGChannelsStored(2,:) = [3  6 5  7  10 9 11]; % bipolar channels
        EEGChannelsStored{2} = bipolarEEGChannelsStored;
    
    blRange = [-0.5 0];
    stRange = [0.25 0.75];
    Fs = round(1/(timeVals(2)-timeVals(1)));
    if round(diff(blRange)*Fs) ~= round(diff(stRange)*Fs)
        disp('baseline and stimulus ranges are not the same');
    else
        range = blRange;
        rangePos = round(diff(range)*Fs);
        blPos = find(timeVals>=blRange(1),1)+ (1:rangePos);
        stPos = find(timeVals>=stRange(1),1)+ (1:rangePos);
        if strcmp(analysisType,'FFT')
            xs = 0:1/diff(range):Fs-1/diff(range);
        end
    end
    
    [parameterCombinations,~,~,~,...
        fValsUnique,oValsUnique,~,tValsUnique] = loadParameterCombinations(folderExtract,[]); %#ok<*ASGLU>
    a=1; e=1; s=1; c =1; t=1;
    
    % Get bad trials
    badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
    if ~exist(badTrialFile,'file')
        disp('Bad trial file does not exist...');
        badTrials=[];
    else
        badTrials = loadBadTrials(badTrialFile);
        disp([num2str(length(badTrials)) ' bad trials']);
    end
    
    
    clear fftBL fftST mfftBL mfftST
    
    for iElec = 1:size(EEGChannelsStored{iRefScheme},2)
        clear x
        if iRefScheme == 1
            clear x
            disp(['Processing electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(iElec))])
            x = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(iElec)) '.mat']));
        elseif iRefScheme == 2
            clear x1 x2 x
            disp(['Processing bipolar electrode no. ' num2str(iElec) ': electrode ID: ' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) ' - ' num2str(EEGChannelsStored{iRefScheme}(2,iElec))])
            x1 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(1,iElec)) '.mat']));
            x2 = load(fullfile(folderLFP,['elec' num2str(EEGChannelsStored{iRefScheme}(2,iElec)) '.mat']));
            x.analogData = x1.analogData-x2.analogData;
        end
        
        % loop for parameter combinations
        for iSF = 1:length(fValsUnique)
            for iOri = 1:length(oValsUnique)
                clear goodPos
                goodPos = parameterCombinations{a,e,s,iSF,iOri,c,t};
                goodPos = setdiff(goodPos,badTrials);
                
                if isempty(goodPos)
                    disp(['No entries for this combination.. TF == ' num2str(iTF)]);
                else
                    if strcmp(analysisType,'FFT')
                        fftBL(iElec,iSF,iOri,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,blPos),[],2))))); %#ok<*NASGU,*AGROW>
                        fftST(iElec,iSF,iOri,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,stPos),[],2)))));
                    end
                end
            end
        end
    end
    
    fftBL_all{iRefScheme} = fftBL;
    fftST_all{iRefScheme} = fftST;
    
    %     figure(iRefScheme)
    mfftBL = squeeze(mean(mean(mean(fftBL,3),2),1)); % common Baseline across all TFs
    mfftST = squeeze(mean(fftST,1));
    colors = jet(length(oValsUnique));
    for iSF =1:length(fValsUnique)
        for iOri=1:length(oValsUnique)
            plot(hPlotsFig.hPlot2(iSF,iOri),xs,mfftBL,'-k','LineWidth',1.5); hold(hPlotsFig.hPlot2(iSF,iOri),'on');
            plot(hPlotsFig.hPlot2(iSF,iOri),xs,squeeze(mfftST(iSF,iOri,:)),'color',colors(iOri,:,:),'LineWidth',1.5);
            xlim(hPlotsFig.hPlot2(iSF,iOri),freqLims);
        end
    end
    
    mSF_fftST = squeeze(mean(mfftST,1));
    for iOri=1:length(oValsUnique)
        plot(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),xs,mfftBL,'-k','LineWidth',1.5); hold(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),'on');
        plot(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),xs,mSF_fftST(iOri,:),'color',[0.5 0 0.5],'LineWidth',1.5);
        xlim(hPlotsFig.hPlot2(length(fValsUnique)+1,iOri),freqLims);
    end
    
    mOri_fftST = squeeze(mean(mfftST,2));
    for iSF=1:length(fValsUnique)
        plot(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),xs,mfftBL,'-k','LineWidth',1.5); hold(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),'on');
        plot(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),xs,mOri_fftST(iSF,:),'color','m','LineWidth',1.5);
        xlim(hPlotsFig.hPlot2(iSF,length(oValsUnique)+1),freqLims);
    end
    
    mSF_Ori_fftST = squeeze(mean(mean(mfftST,2),1));
    plot(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),xs,mfftBL,'-k','LineWidth',1.5); hold(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),'on');
    plot(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),xs,mSF_Ori_fftST,'color',[ 0.9100 0.4100 0.1700],'LineWidth',1.5);
    xlim(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),freqLims);
    ylim(hPlotsFig.hPlot2(length(fValsUnique)+1,length(oValsUnique)+1),[1.5 4.5]);
    
    
    %% Setting Plot Labels, titles and Legends
    title(hPlotsFig.hPlot1(1),'Eyes Open vs. Eyes Closed')
    legend(hPlotsFig.hPlot1(1),'Eyes Open','Eyes Closed')
    
    oVals = {'0','45','90','135','all Ori'};
    sfVals = {'1 cpd', '2 cpd', '3 cpd','all SF'};
    
    for i= 1:length(oVals)
        title(hPlotsFig.hPlot2(1,i),oVals{i})
    end
    
    for i= 1:length(sfVals)
        ylabel(hPlotsFig.hPlot2(i,1),sfVals{i})
    end
end

end % end of main function
%%
function [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
    fValsUnique,oValsUnique,cValsUnique,tValsUnique] = loadParameterCombinations(folderExtract,sideChoice)

p = load(fullfile(folderExtract,'parameterCombinations.mat'));

if ~isfield(p,'parameterCombinations2') % Not a plaid stimulus
    load(fullfile(folderExtract,'parameterCombinations.mat'));
    
    if ~exist('sValsUnique','var');    sValsUnique=rValsUnique;             end
    if ~exist('cValsUnique','var');    cValsUnique=100;                     end
    if ~exist('tValsUnique','var');    tValsUnique=0;                       end
    
else
    [parameterCombinations,aValsUnique,eValsUnique,sValsUnique,...
        fValsUnique,oValsUnique,cValsUnique,tValsUnique] = makeCombinedParameterCombinations(folderExtract,sideChoice);
end

end

function badTrials = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
end
