figure;hold on;grid on;
N = 1000:2000:0.5e6;
 set(gca,'FontSize',16) 
rate_eq = zeros(length(N),1);
levels_p = 3:4;
color = distinguishable_colors(length(levels_p));
for(q=1:length(levels_p))
    for(k=1:length(N))
        rate_eq(k)= N(k)/(n_sym*(gb_length+ts_length+gb_end_l+N(k)/(2*levels_p(q)))/fs);
    end
    plot(N/8000,rate_eq/1000,'Color',color(q,:),'LineWidth',1.5);
    
    
end
title('Rate vs Size vs Constellation')
xlabel('Size of transmission (kB)'); ylabel('Achieved Rate (kbps)');
leg = [[num2str(2.^(2*levels_p(1))),('-QAM ')] ; [num2str(2.^(2*levels_p(2))),('-QAM')]];
legend(leg,'Location','Best');



rate_point = (Nb)/(n_sym*(gb_length+ts_length+gb_end_l+(Nb)/(2*levels))/fs);
plot(Nb/8000,rate_point/1000,'ro')
str = sprintf('(%.1f kB,%.1f kbps)',Nb/8000,rate_point/1000);
text(Nb/8000,rate_point/1000,str,'VerticalAlignment','top', ...
    'HorizontalAlignment','left','BackgroundColor',[.7 .9 .7],'FontSize',16);

rate_point = (Nb)/(n_sym*(gb_length+ts_length+gb_end_l+(Nb)/(2*(levels+1)))/fs);
plot(Nb/8000,rate_point/1000,'ro')
str = sprintf('(%.1f kB,%.1f kbps)',Nb/8000,rate_point/1000);
text(Nb/8000,rate_point/1000,str,'VerticalAlignment','top', ...
    'HorizontalAlignment','left','BackgroundColor',[255 127 80]/256,'FontSize',16);

line([0 max(N) / 8000],[32 32],'LineWidth',3.2,'Color',[0 100 0]/256,'LineStyle','--',...
    'Tag','128 kbps');
