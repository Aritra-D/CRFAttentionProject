clear; clc

X = 0.1:0.1:10;
A = 5; B = 5;

wblPDFFcn = @(X,A,B)((B/A)*((X/A).^(B-1))).*((exp(-(X/A).^B)));

Y = wblPDFFcn(X,A,B); %plot(X,Y);
YFit = wblcdf(X,A,B);
plot(X,YFit,'r');

msePDFFunction = @(YData,XData,params)(sum((YData - wblPDFFcn(XData,params(1),params(2))).^2));
opts = optimset('TolX',1e-6,'TolFun',1e-6,'MaxIter',5000,...
    'Display','off','LargeScale','off','MaxFunEvals',5000);
params = fminsearch(@(params)msePDFFunction(Y,X,params),[0 0]);

YFit2 = wblcdf(X,params(1),params(2));
hold on; plot(X,YFit2,'g');

% parmhat = wblfit(Y);
% plot(X,wblFcn(X,parmhat(1),parmhat(2)),'b');
% YFit2 = wblpdf(X,parmhat(1),parmhat(2));
% plot(X,YFit2,'g');
%%
wblCDFFcn = @(X,A,B)(1-(exp(-((X/A).^B))));
Z = wblCDFFcn(X,A,B); plot(X,Z)
mseCDFFunction = @(YData,XData,params)(sum((YData - wblCDFFcn(XData,params(1),params(2))).^2));
opts = optimset('TolX',1e-6,'TolFun',1e-6,'MaxIter',5000,...
    'Display','off','LargeScale','off','MaxFunEvals',5000);
params = fminsearch(@(params)mseCDFFunction(Z,X,params),[0.5 0.5]);

YFit3 = wblCDFFcn(X,params(1),params(2));
hold on; plot(X,YFit3,'g');