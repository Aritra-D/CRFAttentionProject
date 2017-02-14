meanPowerChange = mean(powerChangeSSVEPAllElecs,3);
stdPowerChange = std(powerChangeSSVEPAllElecs,[],3);%/sqrt(size(powerChangePerElectrode,1));

c=8;
figure;
errorbar(oValsUnique,meanPowerChange(c,:,1,SSVEPPos),2*stdPowerChange(c,:,1,SSVEPPos),'-or'); hold on;
plot(oValsUnique,repmat(mean(meanPowerChange(c,:,1,SSVEPPos),2),1,length(oValsUnique)),'--r');

c=8;
figure;
errorbar(oValsUnique,powerChangeSSVEP(c,:,1),2*powerChangeSSVEP(c,:,2),'-or'); hold on;
plot(oValsUnique,repmat(mean(powerChangeSSVEP(c,:,1),2),1,length(oValsUnique)),'--r');

