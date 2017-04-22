fig=figure; 
hax=axes; 
x=0:0.1:10; 
hold on 
plot(x,sin(x)) 
SP=1; %your point goes here 
line([SP SP],get(hax,'YLim'),'Color',[1 0 0])