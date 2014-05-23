
function [phihat ref ref_re ref_im]= phase_estimation(r, b_train_qam)

size_b=size(b_train_qam);

arg_sum=0;
ref=0;
gama=0;
%estimate the phase shift based on known train sequence
ref_re = 0;
ref_im = 0;

for i=1:size_b(2)
    
    x=(r(i))*(conj(b_train_qam(i)));
   
    
   % ref=(ref+abs(r(i))/abs(b_train_qam(i)))/size_b(2);
    argx=angle(x);
    
    arg_sum=arg_sum+argx;
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

% gama = gama / size_b(2);
end