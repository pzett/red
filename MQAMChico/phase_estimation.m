function phihat = phase_estimation(r, b_train_qam)

size_b=size(b_train_qam);

arg_sum=0;

%estimate the phase shift based on known train sequence

for i=1:size_b(2)
    
    x=(r(i))*(conj(b_train_qam(i)));
    
    argx=angle(x);
    
    arg_sum=arg_sum+argx;
    
end

phihat=arg_sum/size_b(2);

end