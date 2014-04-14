function [phihat]= offset_estimation(mconst, demconst)

size_b=length(demconst);

arg_sum=0;

%estimate the phase shift based on known train sequence

for i=1:size_b
    
   
    x=(mconst(i))*(conj(demconst(i)));
   
   argx=angle(x);
    
    arg_sum=arg_sum+argx;
    
    
    
end

phihat=arg_sum/size_b;


end
