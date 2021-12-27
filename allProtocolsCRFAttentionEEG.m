function [subjectNames,expDates,protocolNames,stimType,deviceName,capLayout] = allProtocolsCRFAttentionEEG

%% Recorded in Rig 4: Stim type 2: Sampling Rate: 1000 Hz, timeStartFromBaseLineList(2) = -1.148; deltaTList(2) = 2.048;
clear index; index=1; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '221015'; protocolNames{index} = 'SRC_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=2; deviceName{index} = 'BP'; subjectNames{index} = 'MD'; expDates{index} = '160116'; protocolNames{index} = 'SRC_0001'; capLayout{index} = 'brainCap64'; stimType{index} = 2;

%% Recorded in RIG 2: Stim type 4: timeStartFromBaseLineList(4) = -0.8192;deltaTList(4)=1.6384; % in seconds- with fs as 2500samp/sec you get 4096 samples with this 
clear index; index=3; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '020416'; protocolNames{index} = 'SRC_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=4; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '020416'; protocolNames{index} = 'SRC_0002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=5; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '020416'; protocolNames{index} = 'SRC_0003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=6; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '020416'; protocolNames{index} = 'SRC_0004'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=7; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '100416'; protocolNames{index} = 'SRC_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=8; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '100416'; protocolNames{index} = 'SRC_0002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=9; deviceName{index} = 'BP'; subjectNames{index} = 'SM'; expDates{index} = '230516'; protocolNames{index} = 'SRC_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=10; deviceName{index} = 'BP'; subjectNames{index} = 'SM'; expDates{index} = '230516'; protocolNames{index} = 'SRC_0002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=11; deviceName{index} = 'BP'; subjectNames{index} = 'SM'; expDates{index} = '230516'; protocolNames{index} = 'SRC_0003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=12; deviceName{index} = 'BP'; subjectNames{index} = 'SS'; expDates{index} = '260516'; protocolNames{index} = 'GRF_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=13; deviceName{index} = 'BP'; subjectNames{index} = 'SS'; expDates{index} = '260516'; protocolNames{index} = 'GRF_0002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=14; deviceName{index} = 'BP'; subjectNames{index} = 'SS'; expDates{index} = '260516'; protocolNames{index} = 'GRF_0003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=15; deviceName{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '270516'; protocolNames{index} = 'GRF_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=16; deviceName{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '270516'; protocolNames{index} = 'GRF_0002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=17; deviceName{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '270516'; protocolNames{index} = 'GRF_0003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=18; deviceName{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '050616'; protocolNames{index} = 'GRF_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=19; deviceName{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '050616'; protocolNames{index} = 'GRF_0002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=20; deviceName{index} = 'BP'; subjectNames{index} = 'AK'; expDates{index} = '080616'; protocolNames{index} = 'GRF_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=21; deviceName{index} = 'BP'; subjectNames{index} = 'AK'; expDates{index} = '080616'; protocolNames{index} = 'GRF_0002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=22; deviceName{index} = 'BP'; subjectNames{index} = 'DJ'; expDates{index} = '140616'; protocolNames{index} = 'GRF_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=23; deviceName{index} = 'BP'; subjectNames{index} = 'DJ'; expDates{index} = '140616'; protocolNames{index} = 'GRF_0002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=24; deviceName{index} = 'BP'; subjectNames{index} = 'DJ'; expDates{index} = '140616'; protocolNames{index} = 'GRF_0003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=25; deviceName{index} = 'BP'; subjectNames{index} = 'MD'; expDates{index} = '160616'; protocolNames{index} = 'GRF_0001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=26; deviceName{index} = 'BP'; subjectNames{index} = 'MD'; expDates{index} = '160616'; protocolNames{index} = 'GRF_0002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=27; deviceName{index} = 'BP'; subjectNames{index} = 'MD'; expDates{index} = '160616'; protocolNames{index} = 'GRF_0003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=28; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '140916'; protocolNames{index} = 'GRF_0003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

%% Preliminary Data Recorded in RIG 2 in 2021 after Covid-19 lockdown: Stim type 4; RiG 2 shifted back from CNS to PRL: timeStartFromBaseLineList(4) = -0.848;deltaTList(4)=2.048; % in seconds- with fs as 1000 samples/sec you get 2048 samples with this 

clear index; index=29; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '200121'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=30; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '200121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=31; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '220121'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=32; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '220121'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=33; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '280121'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=34; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '280121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=35; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '280121'; protocolNames{index} = 'SRC_002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=36; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '280121'; protocolNames{index} = 'SRC_003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=37; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '290121'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=38; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=39; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=40; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=41; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=42; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=43; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=44; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=45; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=46; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=47; deviceName{index} = 'BP'; subjectNames{index} = 'Aritra'; expDates{index} = '120221'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=48; deviceName{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '150221'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=49; deviceName{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '150221'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=50; deviceName{index} = 'BP'; subjectNames{index} = 'test'; expDates{index} = '150221'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=51; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=52; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=53; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=54; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=55; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=56; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=57; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=58; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=59; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=60; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '260221'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=61; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '030321'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=62; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '030321'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=63; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '030321'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=64; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '030321'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=65; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '030321'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=66; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '030321'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=67; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '030321'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=68; deviceName{index} = 'BP'; subjectNames{index} = 'SVP'; expDates{index} = '030321'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=69; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open  
clear index; index=70; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=71; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=72; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=73; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % azi = 2, ele = 2, diameter = 2;
clear index; index=74; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % azi = 3, ele = 3, diameter = 3;
clear index; index=75; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % azi = 4, ele = 4, diameter = 4;
clear index; index=76; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % azi = 5, ele = 5, diameter = 5;
clear index; index=77; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % azi = 6, ele = 6, diameter = 6;
clear index; index=78; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % azi = 7, ele = 7, diameter = 7;
clear index; index=79; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % azi = 8, ele = 8, diameter = 8;
clear index; index=80; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % azi = 6.5, ele = 0, diameter = 6.5;
clear index; index=81; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % azi = 8.5, ele = 0, diameter = 8.5;
clear index; index=82; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % 
clear index; index=83; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '120421'; protocolNames{index} = 'GRF_015'; capLayout{index} = 'actiCap64'; stimType{index} = 4; %

clear index; index=84; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '080721'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=85; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '080721'; protocolNames{index} = 'SRC_002'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 
clear index; index=86; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '080721'; protocolNames{index} = 'SRC_003'; capLayout{index} = 'actiCap64'; stimType{index} = 2; 

clear index; index=87; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 
clear index; index=88; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 
clear index; index=89; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 
clear index; index=90; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 
clear index; index=91; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 
clear index; index=92; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 
clear index; index=93; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 
clear index; index=94; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 
clear index; index=95; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 
clear index; index=96; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '120821'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; 

%% Recorded in RIG 2, Phase 1, Common & Mapping Protocols: Stim type 4: timeStartFromBaseLineList(4) = -0.848;deltaTList(4)=2.048; % in seconds- with fs as 1000 samples/sec you get 2048 samples with this 

clear index; index=97; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=98; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=99; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=100; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=101; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=102; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=103; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=104; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=105; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=106; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=107; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=108; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '060921'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8

clear index; index=109; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=110; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=111; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=112; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=113; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=114; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=115; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=116; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=117; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=118; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=119; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=120; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8
clear index; index=121; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Horizontal 8; Stim: 3000ms, interStim: 1500ms
clear index; index=122; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '070921'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Diagonal   8; Stim: 3000ms, interStim: 1500ms

clear index; index=123; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=124; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=125; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=126; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=127; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=128; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=129; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=130; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=131; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=132; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=133; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=134; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8
clear index; index=135; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Horizontal 8; Stim: 3000ms, interStim: 1500ms 
clear index; index=136; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '160921'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Diagonal   8; Stim: 3000ms, interStim: 1500ms

clear index; index=137; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=138; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=139; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=140; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=141; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=142; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=143; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=144; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=145; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=146; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=147; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6; 1st correct trial was run on without fixation mode; used fixOn.timeMS as fixate.timeMS; bad trials due to eye outside fixation window, if any, will be removed by findBadTrialsWithEEG later
clear index; index=148; deviceName{index} = 'BP'; subjectNames{index} = 'SA'; expDates{index} = '210921'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8

clear index; index=149; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=150; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=151; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=152; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=153; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=154; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=155; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=156; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=157; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=158; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=159; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=160; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8
clear index; index=161; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Horizontal 8; Stim: 3000ms, interStim: 1500ms 
clear index; index=162; deviceName{index} = 'BP'; subjectNames{index} = 'SB'; expDates{index} = '280921'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Diagonal   8; Stim: 3000ms, interStim: 1500ms

clear index; index=163; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=164; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=165; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=166; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=167; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=168; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=169; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=170; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=171; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=172; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=173; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=174; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8
clear index; index=175; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Horizontal 8; Stim: 3000ms, interStim: 1500ms 
clear index; index=176; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '290921'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Diagonal   8; Stim: 3000ms, interStim: 1500ms

clear index; index=177; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=178; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=179; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=180; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=181; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=182; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=183; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=184; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=185; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=186; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=187; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=188; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8
clear index; index=189; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Horizontal 8; Stim: 3000ms, interStim: 1500ms 
clear index; index=190; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '011021'; protocolNames{index} = 'GRF_015'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Diagonal   8; Stim: 3000ms, interStim: 1500ms

clear index; index=191; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=192; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=193; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=194; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=195; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=196; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=197; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=198; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=199; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=200; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=201; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=202; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8
clear index; index=203; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Horizontal 8; Stim: 3000ms, interStim: 1500ms 
clear index; index=204; deviceName{index} = 'BP'; subjectNames{index} = 'DG'; expDates{index} = '051021'; protocolNames{index} = 'GRF_015'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Diagonal   8; Stim: 3000ms, interStim: 1500ms

clear index; index=205; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=206; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=207; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=208; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=209; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=210; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=211; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=212; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=213; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=214; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=215; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=216; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8
clear index; index=217; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Horizontal 8; Stim: 3000ms, interStim: 1500ms 
clear index; index=218; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '061021'; protocolNames{index} = 'GRF_015'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Diagonal   8; Stim: 3000ms, interStim: 1500ms

clear index; index=219; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=220; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=221; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=222; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=223; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=224; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=225; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=226; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=227; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=228; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=229; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=230; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8
clear index; index=231; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Horizontal 8; Stim: 3000ms, interStim: 1500ms 
clear index; index=232; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '071021'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Diagonal   8; Stim: 3000ms, interStim: 1500ms

clear index; index=233; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_001'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Open
clear index; index=234; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_002'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Eyes Closed
clear index; index=235; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_003'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI
clear index; index=236; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_004'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % SF-ORI Continuous
clear index; index=237; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_005'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 2
clear index; index=238; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_006'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 4
clear index; index=239; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_007'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 6
clear index; index=240; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_008'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Diagonal 8
clear index; index=241; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_009'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 2
clear index; index=242; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_010'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 4
clear index; index=243; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_011'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 6
clear index; index=244; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_012'; capLayout{index} = 'actiCap64'; stimType{index} = 4; % Mapping Horizontal 8
clear index; index=245; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_013'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Horizontal 8; Stim: 3000ms, interStim: 1500ms 
clear index; index=246; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '111021'; protocolNames{index} = 'GRF_014'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Mapping Diagonal   8; Stim: 3000ms, interStim: 1500ms

%% Recorded in RIG 2, Phase 2, Attention Protocol SRC-Long: Stim type 7: timeStartFromBaseLineList(7) = -1.5;deltaTList(7)=3.072; % in seconds- with fs as 1000 samples/sec you get 3072 samples with this 
clear index; index=247; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '101121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available

clear index; index=248; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '161121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG

clear index; index=249; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '171121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available
clear index; index=250; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '171121'; protocolNames{index} = 'SRC_002'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG

clear index; index=251; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '241121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available

clear index; index=252; deviceName{index} = 'BP'; subjectNames{index} = 'NM'; expDates{index} = '261121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG

clear index; index=253; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '261121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available

clear index; index=254; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '291121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available

clear index; index=255; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '301121'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available

clear index; index=256; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '011221'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available
clear index; index=257; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '011221'; protocolNames{index} = 'SRC_002'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available
clear index; index=258; deviceName{index} = 'BP'; subjectNames{index} = 'AD'; expDates{index} = '011221'; protocolNames{index} = 'SRC_003'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available

clear index; index=259; deviceName{index} = 'BP'; subjectNames{index} = 'NN'; expDates{index} = '011221'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior; Only LL File available

clear index; index=260; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '021221'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=261; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '021221'; protocolNames{index} = 'SRC_002'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=262; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '021221'; protocolNames{index} = 'SRC_003'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=263; deviceName{index} = 'BP'; subjectNames{index} = 'SP'; expDates{index} = '021221'; protocolNames{index} = 'SRC_004'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG

clear index; index=264; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '031221'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=265; deviceName{index} = 'BP'; subjectNames{index} = 'SK'; expDates{index} = '031221'; protocolNames{index} = 'SRC_002'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG

clear index; index=266; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '041221'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=267; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '041221'; protocolNames{index} = 'SRC_002'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=268; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '041221'; protocolNames{index} = 'SRC_003'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=269; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '041221'; protocolNames{index} = 'SRC_004'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=270; deviceName{index} = 'BP'; subjectNames{index} = 'AB'; expDates{index} = '041221'; protocolNames{index} = 'SRC_005'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG

clear index; index=271; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '081221'; protocolNames{index} = 'SRC_001'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=272; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '081221'; protocolNames{index} = 'SRC_002'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG
clear index; index=273; deviceName{index} = 'BP'; subjectNames{index} = 'LK'; expDates{index} = '081221'; protocolNames{index} = 'SRC_003'; capLayout{index} = 'actiCap64'; stimType{index} = 7; % Behavior + EEG

end