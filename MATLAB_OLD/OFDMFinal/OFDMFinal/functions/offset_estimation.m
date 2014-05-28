function [phihat ref2]= offset_estimation(mconst, demconst)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
%Compute offset. Function inspired in phase_estimation.

size_b=length(demconst);
arg_sum=0;
ref2=0;

%estimate the phase shift based on known train sequence
for i=1:size_b
    
    
    x=(mconst(i))*(conj(demconst(i)));
    
    argx=angle(x);
    
    arg_sum=arg_sum+argx;
    
    aux=abs(mconst(i))/abs(demconst(i));
    ref2=ref2+aux;
    
    
    
end

phihat=arg_sum/size_b;
ref2=ref2/size_b;


end
