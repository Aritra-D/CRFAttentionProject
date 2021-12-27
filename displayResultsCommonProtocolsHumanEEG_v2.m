function displayResultsCommonProtocolsHumanEEG_v2(subjectName,expDate,protocolIDs,gridType,folderSourceString,analysisType,tapers_MT,plotPSDFlag,plotdPSDFlag)

if ~exist('folderSourceString','var');  folderSourceString='E:\';       end
if ~exist('gridType','var');            gridType='Microelectrode';      end
% if ~exist('gridLayout','var');          gridLayout=2;                   end

close all; % close any open figure in MATLAB

[~,expDates_all,protocolNames_all,~,deviceNames,capLayouts] = allCommonProtocolsHumanEEG;

% protocolIDs are arranged as
% 1- Eyes Open,
% 2- Eyes Closed,
% 3- SF-Ori GRF Protocol
expDates = expDates_all(protocolIDs);
protocolNames = protocolNames_all(protocolIDs);
deviceName = deviceNames(protocolIDs(end));
capLayout = capLayouts(protocolIDs(end));

% freq Ranges for power estimation in freq Bands
freqRanges{1} = [8 12]; % alpha
freqRanges{2} = [20 34]; % slow gamma
freqRanges{3} = [36 66]; % fast gamma
freqRanges{4} = [20 66]; % slow+ fast gamma
freqRanges{5} = [104 248]; % hi-gamma
freqRanges{6} = [32 32];  % SSVEP
numFreqs = length(freqRanges);
freqLims = [0 100];

% SF-Ori GRF Protocol
for iRefScheme = 2:2
    
    folderName = fullfile(folderSourceString,'data',subjectName,gridType,expDates{3},protocolNames{3});
    folderExtract= fullfile(folderName,'extractedData');
    folderSegment= fullfile(folderName,'segmentedData');
    folderLFP = fullfile(folderName,'segmentedData','LFP');
    load(fullfile(folderLFP,'lfpInfo.mat')); %#ok<*LOAD>
    
    % load Parameter Combinations for SF-Ori Protocols
    [parameterCombinations,~,~,~,fValsUnique,oValsUnique,~,tValsUnique] = loadParameterCombinations(folderExtract,[]);
    
    % Display Properties
    hFig = figure(iRefScheme);
    set(hFig,'units','normalized','outerposition',[0 0 1 1])
    hPlotsFig.hPlot1 = getPlotHandles(2,1,[0.1 0.1 0.3 0.8],0.01,0.06,1);
    hPlotsFig.hPlot2 = getPlotHandles(length(fValsUnique)+1,length(oValsUnique)+1,[0.5 0.1 0.45 0.8],0.01,0.01,1); linkaxes(hPlotsFig.hPlot2)
    
    % For topoplots
    cLimsTopo = [-1 3];
    showMode = 'dots'; showElecs = [93 94 101 102 96 97 111 107 112];
    
    %Get the electrode list
    clear cL bL chanlocs iElec electrodeList
    switch iRefScheme
        case 1 % unipolar
            refType = 'unipolar';
            cL = load(fullfile(pwd,'\Programs\ProgramsMAP\Montages','Layouts',capLayout{1},[capLayout{1} '.mat']));
            chanlocs = cL.chanlocs;
            for iElec = 1:length(chanlocs)
                electrodeList{iElec}{1} = iElec;
            end
        case 2 % bipolar
            refType = 'bipolar';
            cL = load(fullfile(pwd,'\Programs\ProgramsMAP\Montages','Layouts',capLayout{1},['bipolarChanlocs' capLayout{1} '.mat']));
            bL = load(fullfile(pwd,'\Programs\ProgramsMAP\Montages','Layouts',capLayout{1},['bipChInfo' capLayout{1} '.mat']));
            chanlocs = cL.eloc;
            for iElec = 1:length(chanlocs)
                electrodeList{iElec}{1} = bL.bipolarLocs(iElec,:);
            end
    end
    
    % Baseline & Stimulus timing Information
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
    end
    
    a=1; e=1; s=1; c =1; t=1;
    
    % Get bad trials
    badTrialFile = fullfile(folderSegment,'badTrials_v5.mat');
    if ~exist(badTrialFile,'file')
        disp('Bad trial file does not exist...');
        badElecs = []; badTrials=[];
    else
        [badTrials,badElecs] = loadBadTrials(badTrialFile);
        badImpedanceElecs = badElecs.badImpedanceElecs;
        noisyElecs = badElecs.noisyElecs;
        flatPSDElecs = badElecs.flatPSDElecs;
        declaredBadElecs = badElecs.declaredBadElectrodes;
        allBadElecs = unique([badImpedanceElecs;noisyElecs;flatPSDElecs;declaredBadElecs])';
        
        disp([num2str(length(badTrials)) ' bad trials']);
        disp([num2str(length(allBadElecs)) ' bad elecs']);
    end

    capType = 'actiCap64';
    electrodeListVis = getElectrodeList(capType,refType);
    clear goodSideFlag
    for iSide = 1:length(electrodeListVis)
        clear goodElecFlag
        for iBipElec = 1:length(electrodeListVis{iSide})
            goodElecFlag(iBipElec) = ~any(ismember(electrodeListVis{iSide}{iBipElec},allBadElecs)); %#ok<*AGROW>
        end
        if any(goodElecFlag) 
            goodSideFlag(iSide) = true; 
        else
            goodSideFlag(iSide) = false; 
        end
    end

end

end

% Accessory Functions
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

function [badTrials,badElecs] = loadBadTrials(badTrialFile) %#ok<*STOUT>
load(badTrialFile);
end

% Draw lines for timeTange or FreqRange
function displayRange(plotHandles,range,yLims,colorName,lineStyle)
[nX,nY] = size(plotHandles);
% yLims = getYLims(plotHandles);
if ~exist('lineStyle','var')
    lineStyle = 'solid-solid';
end
yVals = yLims(1):(yLims(2)-yLims(1))/100:yLims(2);
xVals1 = range(1) + zeros(1,length(yVals));
xVals2 = range(2) + zeros(1,length(yVals));

for i=1:nX
    for j=1:nY
        hold(plotHandles(i,j),'on');
        if strcmp(lineStyle,'solid-solid')
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineWidth',1.5);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineWidth',1.5);
        elseif strcmp(lineStyle,'dash-dash')
            plot(plotHandles(i,j),xVals1,yVals,'color',colorName,'LineStyle','--','LineWidth',1.5);
            plot(plotHandles(i,j),xVals2,yVals,'color',colorName,'LineStyle','--','LineWidth',1.5);
        end
    end
end
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


% Get MeanEnergy for different frequency bands
function eValue = getMeanEnergyForAnalysis(mEnergy,freq,freqRange)

posToAverage = intersect(find(freq>=freqRange(1)),find(freq<=freqRange(2)));
eValue   = sum(mEnergy(posToAverage));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
