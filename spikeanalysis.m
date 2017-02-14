
hPlots = getPlotHandles(2,3,[0.1 0.1 0.8 0.8],0.05,0.05);
iRow = 1; iCol = 1;
for iOri = 1:6
    subplot(hPlots(iRow,iCol))
plot(stimulusFiringRate(iOri,:),'r'); hold on;
plot(baselineFiringRate(iOri,:),'k');

if iCol == 3; iRow = iRow + 1; iCol = 1; else iCol = iCol + 1; end;
end
