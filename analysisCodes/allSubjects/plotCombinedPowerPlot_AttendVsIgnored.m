function plotCombinedPowerPlot_AttendVsIgnored
close all;
statData = displayCombinedResults_AttendVsIgnored('SRC-Long',0,1:26,'PreTarget',1,1,1,'both','turbo');
statData2 = displayCombinedResults_AttendVsIgnored('SRC-Long',1,1:26,'PreTarget',1,1,1,'both','turbo');

preTarget{1} = statData;
preTarget{2} = statData2;
preTargetLabels{1} = 'Single_Trial';
preTargetLabels{2} = 'Trial-avg';

savefig('E:\preTarget.fig')
print('E:\preTarget.tif','-dtiff','-r600')

close all;
statData3 = displayCombinedResults_AttendVsIgnored('SRC-Long',0,1:26,'StimOnset',1,1,1,'both','turbo');
statData4 = displayCombinedResults_AttendVsIgnored('SRC-Long',1,1:26,'StimOnset',1,1,1,'both','turbo');

StimOnset{1} = statData3;
StimOnset{2} = statData4;
StimOnsetLabels{1} = 'Single_Trial';
StimOnsetLabels{2} = 'Trial-avg';

savefig('E:\StimOnset.fig')
print('E:\StimOnset.tif','-dtiff','-r600')

save('E:\statistics.mat','preTarget','preTargetLabels','StimOnset','StimOnsetLabels');

end