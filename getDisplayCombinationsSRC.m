% This function returns a N dimentional cell array containing the stim
% numbers of a particular type of stimulus condition for the SRC protocol.
% No changes from the previous version used for microelectrode data

function parameterCombinations = getDisplayCombinationsSRC(folderOut,goodStimNums)

load(fullfile(folderOut,'stimResults.mat')); %#ok<*LOAD>

if newSRCFlag ==0
    
    % Five parameters are chosen:
    % 1. Contrast
    % 2. Temporal Frequency
    % 3. eotCodes
    % 4. Attention Location - 0 or 1
    % 5. Stimulus type - front padding or valid
    
    % Parameters index
    parameters{1} = 'contrastIndex';
    parameters{2} = 'temporalFreqIndex';
    parameters{3} = 'eotCodes';
    parameters{4} = 'attendLoc';
    parameters{5} = 'type0'; % % only 1 and 3, these values are same for type1 for goodStimNums
    
    % get Contrast
    cValsAll  = stimResults.contrastIndex;
    tValsAll  = stimResults.temporalFreqIndex;
    eValsAll  = stimResults.eotCodes;
    aValsAll  = stimResults.attendLoc;
    sValsAll  = stimResults.type0;

    cValsGood = cValsAll(goodStimNums);
    tValsGood = tValsAll(goodStimNums);
    eValsGood = eValsAll(goodStimNums);
    aValsGood = aValsAll(goodStimNums);
    sValsGood = sValsAll(goodStimNums);
    
    cValsUnique = unique(cValsGood); cLen = length(cValsUnique);
    tValsUnique = unique(tValsGood); tLen = length(tValsUnique);
    eValsUnique = unique(eValsGood); eLen = length(eValsUnique);
    aValsUnique = unique(aValsGood); aLen = length(aValsUnique);
    sValsUnique = unique(sValsGood); sLen = length(sValsUnique);
    
    % If more than one value, make another entry with all values
    if (cLen > 1);           cLen=cLen+1;                    end
    if (tLen > 1);           tLen=tLen+1;                    end
    if (eLen > 1);           eLen=eLen+1;                    end
    if (aLen > 1);           aLen=aLen+1;                    end
    if (sLen > 1);           sLen=sLen+1;                    end
    
    allPos = 1:length(goodStimNums);
    
    % display
    disp(['Number of unique contrasts: ' num2str(cLen)]);
    disp(['Number of unique TFs: ' num2str(tLen)]);
    disp(['Number of unique eotCodes: ' num2str(eLen)]);
    disp(['Number of unique attendLoc: ' num2str(aLen)]);
    disp(['Number of unique stimtypes: ' num2str(sLen)]);
    disp(['total combinations: ' num2str((cLen)*(tLen)*(eLen)*(aLen)*(sLen))]);
    
    for c=1:cLen
        if c==cLen
            cPos = allPos;
        else
            cPos = find(cValsGood == cValsUnique(c));
        end
        
        for t=1:tLen
            if t==tLen
                tPos = allPos;
            else
                tPos = find(tValsGood == tValsUnique(t));
            end
            
            for e=1:eLen
                if e==eLen
                    ePos = allPos;
                else
                    ePos = find(eValsGood == eValsUnique(e));
                end
                
                for a=1:aLen
                    if a==aLen
                        aPos = allPos;
                    else
                        aPos = find(aValsGood == aValsUnique(a));
                    end
                    
                    for s=1:sLen
                        if s==sLen
                            sPos = allPos;
                        else
                            sPos = find(sValsGood == sValsUnique(s));
                        end
                        
                        ctPos = intersect(cPos,tPos);
                        ctePos = intersect(ctPos,ePos);
                        cteaPos = intersect(ctePos,aPos);
                        parameterCombinations{c,t,e,a,s} = intersect(cteaPos,sPos); %#ok<*AGROW>
                    end
                end
            end
        end
    end
    
    % save
    save(fullfile(folderOut,'parameterCombinations.mat'),'parameters','parameterCombinations', ...
        'cValsUnique','tValsUnique','eValsUnique','aValsUnique','sValsUnique');
    
elseif newSRCFlag ==1
    
        % Five parameters are chosen:
    % 1. Contrast
    % 2. Temporal Frequency
    % 3. eotCodes
    % 4. Attention Location - 0 or 1
    % 5. Stimulus type - front padding for stimOnset and target for
    % targetOnset
    
    % Parameters index
    parameters{1} = 'contrastIndex';
    parameters{2} = 'temporalFreqIndex';
    parameters{3} = 'eotCodes';
    parameters{4} = 'attendLoc';
    parameters{5} = 'type0/type1'; % 3 for Frontpadding stimOnset and 2 for Target
    
    % get Contrast
    cValsAll  = stimResults.contrastIndex;
    tValsAll  = stimResults.temporalFreqIndex;
    eValsAll  = stimResults.eotCodes;
    aValsAll  = stimResults.attendLoc;
    sValsAll  = stimResults.type0;
    sVals2All = stimResults.type1;
    
    cValsGood.stimOnset = cValsAll(goodStimNums.stimOnset);
    tValsGood.stimOnset = tValsAll(goodStimNums.stimOnset);
    eValsGood.stimOnset = eValsAll(goodStimNums.stimOnset);
    aValsGood.stimOnset = aValsAll(goodStimNums.stimOnset);
    sValsGood.stimOnset = sValsAll(goodStimNums.stimOnset);
    
    cValsGood.targetOnset = cValsAll(goodStimNums.targetOnset);
    tValsGood.targetOnset = tValsAll(goodStimNums.targetOnset);
    eValsGood.targetOnset = eValsAll(goodStimNums.targetOnset);
    aValsGood.targetOnset = aValsAll(goodStimNums.targetOnset);
    sValsGood.targetOnset = sValsAll(goodStimNums.targetOnset);
    
    if unique(sVals2All(goodStimNums.targetOnset(find(sValsGood.targetOnset==1))))==2
        sValsGood.targetOnset(find(sValsGood.targetOnset==1)) = 2;
    else
        error('stimType code for Target on Side 1 (Left) do not match')
    end
        
    % Unique values are identical since the newSRC protocol presents one
    % stimuli per trial
    cValsUnique = unique(cValsGood.stimOnset); cLen = length(cValsUnique);
    tValsUnique = unique(tValsGood.stimOnset); tLen = length(tValsUnique);
    eValsUnique = unique(eValsGood.stimOnset); eLen = length(eValsUnique);
    aValsUnique = unique(aValsGood.stimOnset); aLen = length(aValsUnique);
    sValsUnique = unique(sValsGood.stimOnset); sLen = length(sValsUnique);
    
    % If more than one value, make another entry with all values
    if (cLen > 1);           cLen=cLen+1;                    end
    if (tLen > 1);           tLen=tLen+1;                    end
    if (eLen > 1);           eLen=eLen+1;                    end
    if (aLen > 1);           aLen=aLen+1;                    end
    if (sLen > 1);           sLen=sLen+1;                    end
    
    allPos.stimOnset = 1:length(goodStimNums.stimOnset);
    allPos.targetOnset = 1:length(goodStimNums.targetOnset);
    
    % display
    disp(['Number of unique contrasts: ' num2str(cLen)]);
    disp(['Number of unique TFs: ' num2str(tLen)]);
    disp(['Number of unique eotCodes: ' num2str(eLen)]);
    disp(['Number of unique attendLoc: ' num2str(aLen)]);
    disp(['Number of unique stimtypes: ' num2str(sLen)]);
    disp(['total combinations: ' num2str((cLen)*(tLen)*(eLen)*(aLen)*(sLen))]);
    
    % computing parameterCominations for stimOnset and targetOnset
    % separately
    for c=1:cLen
        if c==cLen
            cPos_s = allPos.stimOnset;
            cPos_t = allPos.targetOnset;
        else
            cPos_s = find(cValsGood.stimOnset == cValsUnique(c));
            cPos_t = find(cValsGood.targetOnset == cValsUnique(c));
        end
        
        for t=1:tLen
            if t==tLen
                tPos_s = allPos.stimOnset;
                tPos_t = allPos.targetOnset;
            else
                tPos_s = find(tValsGood.stimOnset == tValsUnique(t));
                tPos_t = find(tValsGood.targetOnset == tValsUnique(t));
            end
            
            for e=1:eLen
                if e==eLen
                    ePos_s = allPos.stimOnset;
                    ePos_t = allPos.targetOnset;
                else
                    ePos_s = find(eValsGood.stimOnset == eValsUnique(e));
                    ePos_t = find(eValsGood.targetOnset == eValsUnique(e));
                end
                
                for a=1:aLen
                    if a==aLen
                        aPos_s = allPos.stimOnset;
                        aPos_t = allPos.targetOnset;
                    else
                        aPos_s = find(aValsGood.stimOnset == aValsUnique(a));
                        aPos_t = find(aValsGood.targetOnset == aValsUnique(a));
                    end
                    
                    for s=1:sLen
                        if s==sLen
                            sPos_s = allPos.stimOnset;
                            sPos_t = allPos.targetOnset;
                        else
                            sPos_s = find(sValsGood.stimOnset == sValsUnique(s));
                            sPos_t = find(sValsGood.targetOnset == sValsUnique(s));
                        end
                        
                        ctPos_s = intersect(cPos_s,tPos_s);
                        ctePos_s = intersect(ctPos_s,ePos_s);
                        cteaPos_s = intersect(ctePos_s,aPos_s);
                        
                        ctPos_t = intersect(cPos_t,tPos_t);
                        ctePos_t = intersect(ctPos_t,ePos_t);
                        cteaPos_t = intersect(ctePos_t,aPos_t);
                        
                        parameterCombinations_stimOnset{c,t,e,a,s} = intersect(cteaPos_s,sPos_s); %#ok<*AGROW>
                        parameterCombinations_targetOnset{c,t,e,a,s} = intersect(cteaPos_t,sPos_t); %#ok<*AGROW>
                    end
                end
            end
        end
    end
    
    parameterCombinations.stimOnset = parameterCombinations_stimOnset;
    parameterCombinations.targetOnset = parameterCombinations_targetOnset;
    
    % save
    save(fullfile(folderOut,'parameterCombinations.mat'),'parameters','parameterCombinations', ...
        'cValsUnique','tValsUnique','eValsUnique','aValsUnique','sValsUnique');
end