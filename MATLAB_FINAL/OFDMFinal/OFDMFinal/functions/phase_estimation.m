
function [phihat ref ref_re ref_im]= phase_estimation(r, b_train_qam)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Function to estimate phase using the received samples and the known
%training sequence. An average of the rotation and amplitude are computed.  

size_b=size(b_train_qam);
arg_sum=0; % variable that contains the sum of the phases
ref=0; % variables that contains the sum of the amplitudes
gama=0;

ref_re = 0; % estimate for I, if needed
ref_im = 0; % estimate for Q, if needed
%estimate the phase shift based on known train sequence
for i=1:size_b(2)
    %phase
    x=(r(i))*(conj(b_train_qam(i))); % see how much constellation is rotated.
    argx=angle(x); % take phase
    arg_sum=arg_sum+argx; % sum
    
    %amplitudes
    aux=abs(r(i))/abs(b_train_qam(i));
    ref=ref+aux;
    aux_re = abs(real(r(i))) / abs(real(b_train_qam(i)));
    aux_im = abs(imag(r(i))) / abs(imag(b_train_qam(i)));
    ref_re = ref_re + aux_re;
    ref_im = ref_im + aux_im;
    
end

ref=ref/size_b(2);
ref_re = ref_re / size_b(2);
ref_im = ref_im / size_b(2);
phihat=arg_sum/size_b(2);

end