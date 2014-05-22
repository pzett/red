%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Script to compute errors in the transmission and plot constellation and
% errors.

if(file) % if file was transmitted
    file_data = mdem(ts_length*2*levels+1:end); % pick bits after training sequence.
    if(intlv);
        file_data = scramble(file_data'); demodulated = file_data'; %recover the original data
    end;
    if(code)
        file_data = LDPCdec(file_data,rate); demodulated = file_data; %decode using LDPC
    end
    test=[ts;data_sent]; % use data from transmitter to compute errors
    figure(8)
    demodulated = reshape ( demodulated , length(demodulated) , 1 );
    errors = sum(test(length(ts)+1:end) ~= demodulated(1:length(data_sent))); 
    BER = errors / length(test(length(ts)+1:end)) * 100
    plot(real(mconstdem(1:ts_length)),imag(mconstdem(1:ts_length)),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
    figure(6)
    plot(real(mconstdem(ts_length+1:length(test)/(2*levels))),imag(mconstdem(ts_length+1:length(test)/(2*levels))),'.'); grid on ; xlabel('I'); ylabel('Q'),title('Received Constellation after Rotation and Offset Correction');
    bitstobytesnew(demodulated); % reconstruct file and save output folder
    demodulated = demodulated';
    
else
    random_data =  mdem(length(ts)+1:end); % decoded data
    test=[ts;data_sent]; % sent data
    test_encoded=[ts;data_encoded]; % sent encoded data
    dem_enc = random_data(1:length(data_encoded));  % pick length
    dem_enc = reshape(dem_enc,length(dem_enc),1); % put in the right shape
    errors = sum(test_encoded(length(ts)+1:end) ~= dem_enc(1:end)); % compute errors
    
    if(intlv)
        random_data = scramble(random_data');
        dem_enc = random_data(1:length(data_encoded));
        dem_enc = reshape(double(dem_enc),length(dem_enc),1);
    end
    if(code)
        BER_BEFORE_DEC = errors / length(test_encoded(length(ts)+1:end)) * 100
        demodulated = LDPCdec(dem_enc,rate);
        demodulated = demodulated(1:length(test)-length(ts));
        errors = sum(test(length(ts)+1:end) ~= demodulated(1:end));
        BER_AFTER_DEC = errors / length(test(length(ts)+1:end)) * 100
    else
        test =[ts; data_sent]; %vector to compare with the decoded and compute BER
        demodulated=random_data';
        demodulated=demodulated(1:length(data_sent))';
        demodulated = reshape ( demodulated , length(demodulated) , 1);
        errors = sum(test(length(ts)+1:end) ~= demodulated(1:end));
        BER = errors / length(test(length(ts)+1:end)) * 100
    end
end



