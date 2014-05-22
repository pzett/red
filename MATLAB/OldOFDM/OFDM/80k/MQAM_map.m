function [ mconst,mconst_ts ] = MQAM_map(bit_stream,L,gb_length,ts_length, levels, Nc, A)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

if(mod(L,2*levels) ~= 0)
    bit_stream = [bit_stream zeros(1,2*levels-mod(L,2*levels))];
    L = length(bit_stream);
end

symbol2=ones(1,1);
mx2=[]; my2=[];
x2=0;
y2=0;
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
    
    x2=xi*symbol2;
    y2=yi*symbol2;
    
    mx2=[mx2 x2];
    my2=[my2 y2];
end

mconst = mx2 + 1i*my2; %resulting constellation

if(mod(length(mconst),Nc) ~= 0)
    mconst = [mconst (1+1i)*ones(Nc-mod(length(mconst),Nc),1)']; %fill with symbols till Nc
end

mconst_ts = mconst(gb_length+1:gb_length+ts_length); %save training sequence constellation

end

