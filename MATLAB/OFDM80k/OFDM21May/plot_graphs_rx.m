figure
if(plotting)
    subplot(122)
    plot(real(mconstdem(ts_length+1:length(test)/(2*levels))),imag(mconstdem(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
    subplot(121)
    plot(real(decoded(ts_length+1:length(test)/(2*levels))),imag(decoded(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation');
    
    
end

% figure(5)
% hold on; grid on;
% subplot(122); hold on; grid on;
% for(k=ts_length:length(test)/(2*levels))
%     plot(real(mconstdem(k+1)),imag(mconstdem(k+1)),'Marker','.','MarkerEdgeColor',colors(mod(k-ts_length,Nc)+1,:),'LineStyle','none');
% end
% title('Received constellation in each subcarrier after correction'); xlabel('I'); ylabel('Q');
% subplot(121); hold on; grid on;
% for(k=ts_length:length(test)/(2*levels))
%
%     plot(real(decoded(k+1)),imag(decoded(k+1)),'Marker','.','MarkerEdgeColor',colors(mod(k-ts_length,Nc)+1,:),'LineStyle','none');
%
% end
% title('Received constellation in each subcarrier'); xlabel('I'); ylabel('Q');

figure
plot(real(mconstdem(ts_length+1:length(test)/(2*levels))),imag(mconstdem(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
ylim=get(gca,'ylim');
xlim=get(gca,'xlim');
str = sprintf('BER = %.3f',BER);
text(xlim(2),ylim(2),str,'BackgroundColor',[.7 .9 .7],'VerticalAlignment','top',...
    'HorizontalAlignment','right','FontSize',14); 
                             
if(plotting)
    figure
    subplot(211)
    demodulated = reshape(demodulated,length(demodulated),1); 
    stem(test(length(ts)+1:end) ~= demodulated(1:length(data_sent))); title('Errors in the transmission'); xlabel('Samples'); ylabel('Error');
    subplot(212)
    carrier_errors(test(length(ts)+1:end), demodulated(1:length(data_sent)),Nc);
end