function [phihat ref]= phase_estimation(r, b_train_qam)

size_b=size(b_train_qam);

arg_sum=0;
ref=0;
%estimate the phase shift based on known train sequence

for i=1:size_b(2)
    
    x=(r(i))*(conj(b_train_qam(i)));
   
    
   % ref=(ref+abs(r(i))/abs(b_train_qam(i)))/size_b(2);
    argx=angle(x);
    
    arg_sum=arg_sum+argx;
    aux=abs(r(i))/abs(b_train_qam(i));
    ref=ref+aux;
    
end

ref=ref/size_b(2);

phihat=arg_sum/size_b(2);

end