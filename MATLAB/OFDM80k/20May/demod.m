function [demconst]= demodulate(bit_stream,levels,A)


L=length(bit_stream);
mx=[];
my=[];
for n=0:2*levels:L-2*levels
    bit=[];
    xi=0;
    yi=0;
    
    for m= 1:2:2*levels
        if bit_stream(n+m)==0      
            xi=xi+A*(2^((m-1)/2));
            
        else
            xi=xi-A*(2^((m-1)/2));
            
        end
        if bit_stream(n+m+1)==0
            yi=yi+A*(2^((m-1)/2));
            
        else
            yi=yi-A*(2^((m-1)/2));
            
        end
    end
    
    x=xi;
    y=yi;
    
    mx=[mx x];
    my=[my y];
    
    
end

demconst = mx + my*1i;

end


