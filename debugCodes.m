


for tf = 1:3
    count_correct =0;
    count_failed = 0;
    for a = 1:2
        count_correct =0;
        count_failed = 0;
        for i = 1:length(targetInfo)
            if targetInfo(i).attendLoc == a-1 && targetInfo(i).eotCode ==0 && targetInfo(i).temporalFreqIndex == tf-1
                count_correct = count_correct+1;
            elseif targetInfo(i).attendLoc == a-1 && targetInfo(i).eotCode ==2 && targetInfo(i).temporalFreqIndex == tf-1
                count_failed = count_failed+1;
            end
        end
        percentCorrect = count_correct/(count_correct+count_failed);
        disp(['percent correct for tf:' num2str(tf) ', a:' num2str(a) ', = ' num2str(count_correct) '/'  num2str(count_correct+count_failed) ' = ' num2str(percentCorrect)])
    end
end

eotCode = {'0','2'};
tempFreq = {'0','1','2'};
attendLoc = {'0','1'};

eotCodes{1} = find([targetInfo(:).eotCode]==0);
eotCodes{2} = find([targetInfo(:).eotCode]==2);

tempFreq{1} = find([targetInfo(:).temporalFreqIndex]==0);
tempFreq{2} = find([targetInfo(:).temporalFreqIndex]==1);
tempFreq{3} = find([targetInfo(:).temporalFreqIndex]==2);

attendLoc{1} = find([targetInfo(:).attendLoc]==0);
attendLoc{2} = find([targetInfo(:).attendLoc]==1);

for e =1:2
    for tf =1:3
        for a=1:2
            clear trialIdx
            trialIdx = intersect(intersect(tempFreq{tf},attendLoc{a}),eotCodes{e});
            trialNums{e}{tf,a} = [targetInfo(trialIdx).trialNum];
        end
    end
end
    

a= [targetInfo(:).trialNum];
for i=1:length(tc)
    for j=1:length(a)
        if tc(i)==a(j)
        tc_Idx(i) = j
        end
    end
end