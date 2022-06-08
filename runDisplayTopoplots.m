function runDisplayTopoplots(analysisType)

if strcmp(analysisType,'AttendedVsIgnored')

displayResults_AttendVsIgnored('SRC-Long',1,1:7,'StimOnset',1,1,1,'both','turbo')
displayResults_AttendVsIgnored('SRC-Long',1,8:26,'StimOnset',1,1,1,'both','turbo')
displayResults_AttendVsIgnored('SRC-Long',1,1:26,'StimOnset',1,1,1,'both','turbo')

displayResults_AttendVsIgnored('SRC-Long',1,1:7,'PreTarget',1,1,1,'both','turbo')
displayResults_AttendVsIgnored('SRC-Long',1,8:26,'PreTarget',1,1,1,'both','turbo')
displayResults_AttendVsIgnored('SRC-Long',1,1:26,'PreTarget',1,1,1,'both','turbo')

displayResults_AttendVsIgnored('SRC-Long',0,1:7,'StimOnset',1,1,1,'both','turbo')
displayResults_AttendVsIgnored('SRC-Long',0,8:26,'StimOnset',1,1,1,'both','turbo')
displayResults_AttendVsIgnored('SRC-Long',0,1:26,'StimOnset',1,1,1,'both','turbo')

displayResults_AttendVsIgnored('SRC-Long',0,1:7,'PreTarget',1,1,1,'both','turbo')
displayResults_AttendVsIgnored('SRC-Long',0,8:26,'PreTarget',1,1,1,'both','turbo')
displayResults_AttendVsIgnored('SRC-Long',0,1:26,'PreTarget',1,1,1,'both','turbo')

elseif strcmp(analysisType,'HitsVsMisses')

displayResults_HitsVsMisses('SRC-Long',1,1:7,'StimOnset',1,1,'both','turbo')
displayResults_HitsVsMisses('SRC-Long',1,8:26,'StimOnset',1,1,'both','turbo')
displayResults_HitsVsMisses('SRC-Long',1,1:26,'StimOnset',1,1,'both','turbo')

displayResults_HitsVsMisses('SRC-Long',1,1:7,'PreTarget',1,1,'both','turbo')
displayResults_HitsVsMisses('SRC-Long',1,8:26,'PreTarget',1,1,'both','turbo')
displayResults_HitsVsMisses('SRC-Long',1,1:26,'PreTarget',1,1,'both','turbo')

displayResults_HitsVsMisses('SRC-Long',0,1:7,'StimOnset',1,1,'both','turbo')
displayResults_HitsVsMisses('SRC-Long',0,8:26,'StimOnset',1,1,'both','turbo')
displayResults_HitsVsMisses('SRC-Long',0,1:26,'StimOnset',1,1,'both','turbo')

displayResults_HitsVsMisses('SRC-Long',0,1:7,'PreTarget',1,1,'both','turbo')
displayResults_HitsVsMisses('SRC-Long',0,8:26,'PreTarget',1,1,'both','turbo')
displayResults_HitsVsMisses('SRC-Long',0,1:26,'PreTarget',1,1,'both','turbo')

end

end