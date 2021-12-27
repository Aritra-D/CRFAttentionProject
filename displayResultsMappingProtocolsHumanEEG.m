function displayResultsMappingProtocolsHumanEEG(subjectName,expDate,folderSourceString,gridType,analysisType,tapers_MT,displayDeltaPSDFlag)

if ~exist('folderSourceString','var');  folderSourceString='E:\';        end
if ~exist('gridType','var');            gridType='Microelectrode';      end

close all;

[subjectNames_all,expDates_all,protocolNames_all,~,~,~] = allProtocolsCRFAttentionEEG;
protocolIDs = find(strcmp(subjectName,subjectNames_all)& strcmp(expDate,expDates_all)); % only SubjectName is

expDates = expDates_all(protocolIDs);
protocolNames = protocolNames_all(protocolIDs);


% Display Properties
hFig = figure();
set(hFig,'units','normalized','outerposition',[0 0 1 1])
hPlotsFig.hPlot1 = getPlotHandles(2,1,[0.7 0.1 0.25 0.8],0.01,0.01,1);
hPlotsFig.hPlot2 = getPlotHandles(4,7,[0.08 0.1 0.55 0.8],0.01,0.01,1); linkaxes

blRange = [-0.5 0];
stRange = [0.25 0.75];

for iRefScheme = 1:2
    %%
    clear fftBL fftST
    for iProt = 1:7
        clear lfpInfo folderName
        disp(['Processing data for Protocol: ' num2str(iProt) ' : expDate' expDates{iProt} ' : protocolName' protocolNames{iProt}])
        folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDates{iProt},protocolNames{iProt});
        folderExtract = fullfile(folderName,'extractedData');
        folderSegment= fullfile(folderName,'segmentedData');
        folderLFP = fullfile(folderName,'segmentedData','LFP');
        lfpInfo = load(fullfile(folderLFP,'lfpInfo.mat')); %#ok<*LOAD>
        
        Fs = round(1/(lfpInfo.timeVals(2)-lfpInfo.timeVals(1)));
        if round(diff(blRange)*Fs) ~= round(diff(stRange)*Fs)
            disp('baseline and stimulus ranges are not the same');
        else
            range = blRange;
            rangePos = round(diff(range)*Fs);
            blPos = find(lfpInfo.timeVals>=blRange(1),1)+ (1:rangePos);
            stPos = find(lfpInfo.timeVals>=stRange(1),1)+ (1:rangePos);
            if strcmp(analysisType,'FFT')
                freqVals = 0:1/diff(range):Fs-1/diff(range);
            end
        end
        
        photoDiodeIDs = [20 21];
        unipolarEEGChannelsStored = setdiff(lfpInfo.analogChannelsStored,photoDiodeIDs);
        
        if strcmp(subjectName,'Aritra')
            EEGChannelsExcluded = [1 3 5 6 10 11 14 15 19]; % Aritra:
            EEGChannelsStored{1} = setdiff(unipolarEEGChannelsStored,EEGChannelsExcluded);  % unipolar channels Aritra: %[2 12 13 4 16 17 18 7 8 9];
            bipolarEEGChannelsStored(1,:) = [16 16 17 18 18 17  8 8 8]; % Aritra
            bipolarEEGChannelsStored(2,:) = [12  2 16 13  4 18 17 7 9];% Aritra
            EEGChannelsStored{2} = bipolarEEGChannelsStored;
            
        elseif strcmp(subjectName,'SVP')
            EEGChannelsExcluded = [1 2 5 8 9 10 11 15 16]; % SVP
            EEGChannelsStored{1} = setdiff(unipolarEEGChannelsStored,EEGChannelsExcluded);  % unipolar channels SVP: %[3 4 6 7 12 13 14 7 8 9];
            
            bipolarEEGChannelsStored(1,:) = [12 12 13 14 14 13 18 18 18]; % SVP
            bipolarEEGChannelsStored(2,:) = [ 4  3 12  6  7 12 13 17 19];% ; % SVP
            EEGChannelsStored{2} = bipolarEEGChannelsStored;
        end
        
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
%         end
%         
        [parameterCombinations,parameterCombinations2,~,~,~,~,...
            sValsUnique,sValsUnique2,~,~,~,~,~,~,tValsUnique,tValsUnique2] = loadParameterCombinations(folderExtract); %#ok<*ASGLU>
        
        a1=1; a2=1; e1=1; e2=1; s1=1; s2=1; sf1=1; sf2=1;
        o1=1; o2=1; c1 =1; c2=1;
        tList=1:length(tValsUnique);
        
        % Get bad trials
        badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
        if ~exist(badTrialFile,'file')
            disp('Bad trial file does not exist...');
            badTrials=[];
        else
            badTrials = loadBadTrials(badTrialFile);
            disp([num2str(length(badTrials)) ' bad trials']);
        end
        
        % Main loop for data processing for different parameter
        % combinations
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
            for iTF = 1:length(tList)
                clear goodPos
                goodPos1 = parameterCombinations{a1,e1,s1,sf1,o1,c1,iTF};
                goodPos2 = parameterCombinations2{a2,e2,s2,sf2,o2,c2,iTF};
                goodPos = intersect(goodPos1,goodPos2);
                goodPos = setdiff(goodPos,badTrials);
                
                if isempty(goodPos)
                    disp(['No entries for this combination.. iProt == ' num2str(iProt) ' TF ==' num2str(iTF)]);
                else
                    if strcmp(analysisType,'FFT')
                        fftBL(iProt,iElec,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,blPos),[],2))))); %#ok<*NASGU,*AGROW>
                        fftST(iProt,iElec,iTF,:) = squeeze(conv2Log(mean(abs(fft(x.analogData(goodPos,stPos),[],2)))));
                    elseif strcmp(analysisType,'MT')
                        
                        % Set up params for MT
                        params.tapers   = tapers_MT;
                        params.pad      = -1;
                        params.Fs       = Fs;
                        params.fpass    = [0 250];
                        params.trialave = 1;
                        
                        [tmpEBL,freqValsBL] = mtspectrumc(x.analogData(goodPos,blPos)',params);
                        [tmpEST,freqValsST] = mtspectrumc(x.analogData(goodPos,stPos)',params);
                        if isequal(freqValsBL,freqValsST)
                            freqVals = freqValsST;
                        end
                        psdBL(iProt,iElec,iTF,:) = conv2Log(tmpEBL);
                        psdST(iProt,iElec,iTF,:) = conv2Log(tmpEST);
    

                                                
                    end
                end
            end
        end
    end
    
    if strcmp(analysisType,'FFT')
        fftBL_all{iRefScheme} = fftBL;
        fftST_all{iRefScheme} = fftST;
    elseif strcmp(analysisType,'MT')
        psdBL_all{iRefScheme} = psdBL;
        psdST_all{iRefScheme} = psdST;
    end
end

freqLims = [0 100];

colors = jet(7);
if strcmp(analysisType,'FFT')
    dataBL = fftBL_all;
    dataST = fftST_all;
elseif strcmp(analysisType,'MT')
    dataBL = psdBL_all;
    dataST = psdST_all;
end
% plotting 
for iRefScheme = 1:2
    for iProt = 1:7
%         yyaxis left % hPlotsFig.hPlot2(iRefScheme,iProt)
        plot(hPlotsFig.hPlot2(iRefScheme,iProt),freqVals,squeeze(mean(dataBL{iRefScheme}(iProt,:,1,:),2)),'-k','LineWidth', 1.5); hold (hPlotsFig.hPlot2(iRefScheme,iProt),'on')
        plot(hPlotsFig.hPlot2(iRefScheme,iProt),freqVals,squeeze(mean(dataST{iRefScheme}(iProt,:,1,:),2)),'color',colors(iProt,:,:),'LineWidth', 1.5);
        if strcmp(analysisType,'MT')&& displayDeltaPSDFlag
            plot(hPlotsFig.hPlot2(iRefScheme,iProt),freqVals,10*(squeeze(mean(dataST{iRefScheme}(iProt,:,1,:),2)-mean(dataBL{iRefScheme}(iProt,:,1,:),2))),'-b','LineWidth', 1.5);
        end
        xlim(hPlotsFig.hPlot2(iRefScheme,iProt),freqLims); ylim(hPlotsFig.hPlot2(iRefScheme,iProt),[1.8 4.2]);
        
%         yyaxis right 
%         yyaxis(hPlotsFig.hPlot2(iRefScheme,iProt),'right')
%         clear dffT
%         dffT_dB = 20*(squeeze(mean(fftST_all{iRefScheme}(iProt,:,1,:),2)) - squeeze(mean(fftBL_all{iRefScheme}(iProt,:,1,:),2)));
%         plot(hPlotsFig.hPlot2(iRefScheme,iProt),xs,dffT,'-b','LineWidth', 1.5);
        
        plot(hPlotsFig.hPlot2(iRefScheme+2,iProt),freqVals,squeeze(mean(dataBL{iRefScheme}(iProt,:,2,:),2)),'-k','LineWidth', 1.5);hold (hPlotsFig.hPlot2(iRefScheme+2,iProt),'on')
        plot(hPlotsFig.hPlot2(iRefScheme+2,iProt),freqVals,squeeze(mean(dataST{iRefScheme}(iProt,:,2,:),2)),'color',colors(iProt,:,:),'LineWidth', 1.5);
        if strcmp(analysisType,'MT')&& displayDeltaPSDFlag
            plot(hPlotsFig.hPlot2(iRefScheme+2,iProt),freqVals,10*(squeeze(mean(dataST{iRefScheme}(iProt,:,2,:),2)-mean(dataBL{iRefScheme}(iProt,:,2,:),2))),'-b','LineWidth', 1.5);
        end
        xlim(hPlotsFig.hPlot2(iRefScheme+2,iProt),freqLims); ylim(hPlotsFig.hPlot2(iRefScheme+2,iProt),[1.8 4.2]);
    end
end

rescaleData(hPlotsFig.hPlot2,0,100,getYLims(hPlotsFig.hPlot2),14);
% ylim(hPlotsFig.hPlot2(1,1),[1.5 4.2]);

for i=1:5
eccentricity(i) = (i+1)*sqrt(2);
radius(i) = i+1;
end
eccentricity(6) = 8.5;
eccentricity(7) = 6.5;
radius(6) = 4.2;
radius(7) = 3.2;

for iProt=1:7
    title(hPlotsFig.hPlot2(1,iProt),['e = ' num2str(eccentricity(iProt),2), char (176), ', r = ' num2str(radius(iProt)) char(176)],'fontSize',10)
end

ylabel(hPlotsFig.hPlot2(1,1),{'Unipolar FFT','static'})
ylabel(hPlotsFig.hPlot2(2,1),{'Bipolar FFT','static'})

ylabel(hPlotsFig.hPlot2(3,1),{'Unipolar FFT','Flicker'})
ylabel(hPlotsFig.hPlot2(4,1),{'Bipolar FFT','Flicker'})

xlabel(hPlotsFig.hPlot2(4,1),'Frequency (Hz)')

end


%% Accessory Functions
% function [analogChannelsStored,goodStimPos,timeVals,analogInputNums] = loadlfpInfo(folderLFP) %#ok<*STOUT>
% load(fullfile(folderLFP,'lfpInfo.mat'));
% if ~exist('analogInputNums','var')
%     analogInputNums=[];
% end
% end
% load Parameter combinations
function [parameterCombinations,parameterCombinations2,...
    aValsUnique,aValsUnique2,eValsUnique,eValsUnique2,...
    sValsUnique,sValsUnique2,fValsUnique,fValsUnique2,...
    oValsUnique,oValsUnique2,cValsUnique,cValsUnique2,...
    tValsUnique,tValsUnique2] = loadParameterCombinations(folderExtract)

load(fullfile(folderExtract,'parameterCombinations.mat')); %#ok<*LOAD>

if ~exist('sValsUnique','var');    sValsUnique = rValsUnique/3;         end
if ~exist('cValsUnique','var');    cValsUnique=[];                      end
if ~exist('tValsUnique','var');    tValsUnique=[];                      end
end


function badTrials = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
end

% get Y limits for an axis
function yLims = getYLims(plotHandles)

[numRows,numCols] = size(plotHandles);
% Initialize
yMin = inf;
yMax = -inf;

for row=1:numRows
    for column=1:numCols
        % get positions
        axis(plotHandles(row,column),'tight');
        tmpAxisVals = axis(plotHandles(row,column));
        if tmpAxisVals(3) < yMin
            yMin = tmpAxisVals(3);
        end
        if tmpAxisVals(4) > yMax
            yMax = tmpAxisVals(4);
        end
    end
end

yLims=[yMin yMax];
end

% Rescale data
function rescaleData(plotHandles,xMin,xMax,yLims,labelSize)

[numRows,numCols] = size(plotHandles);
% labelSize=14;
for i=1:numRows
    for j=1:numCols
        hold(plotHandles(i,j),'on');
        axis(plotHandles(i,j),[xMin xMax yLims]);
        if (i==numRows && rem(j,2)==1)
            if j==1
                set(plotHandles(i,j),'fontSize',labelSize);
            elseif j~=1
                set(plotHandles(i,j),'YTickLabel',[],'fontSize',labelSize);
            end
        elseif (rem(i,2)==0 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==0 && j~=1)
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==1 && j==1)
            set(plotHandles(i,j),'XTickLabel',[],'fontSize',labelSize);
        elseif (rem(i,2)==1 && j~=1)
            set(plotHandles(i,j),'XTickLabel',[],'YTickLabel',[],'fontSize',labelSize);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%