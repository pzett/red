function [ output_args ] =demod_check( Hx,Hy,levels )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
th_x=0;th_y=0;
i_x=0;i_y=0;
mdem=[];
sym=[];
for n=1:levels
    if Hy > th_y
        sym = [sym 0];
        i_y=1;
    else
        sym = [sym 1];
        i_y=-1;
    end
    
    if Hx > th_x
        sym = [sym 0];
        i_x=1;
    else
        sym = [sym 1];
        i_x=-1;
    end
    th_y = th_y + i_y*(2^(levels-n));
    th_x =  th_x +i_x*(2^(levels-n));
end
mdem=[mdem fliplr(sym)]
end

