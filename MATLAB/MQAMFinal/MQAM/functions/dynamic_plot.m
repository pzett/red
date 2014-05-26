scatterplot(mconstdem(ts_length+1:length(test)/(2*levels))); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
mc=mconstdem(ts_length+1:length(test)/(2*levels));
bl = 1000;



figure
pause
hold on;
grid on;
for(k=1:floor(length(mc)/bl))
    plot(real(mc((k-1)*bl+1:k*bl)),imag((mc((k-1)*bl+1:k*bl))),'.')
    pause(0.12)
end

hold off
