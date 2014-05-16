function [ data_output, len_data] = convencode( data_input,code_rate,inter )
%convencode: Variable rate convolutional encoder
%  data_input: data input
%  code_rate:k/n, e.g. String: '1/2', '2/3', '3/4','4/5'
%  Generator polynomials taken from 
%  Proakis,Salehi:Digital Communications pp.517-520 

switch code_rate
    case '0'
    flag=0;    
    data_output=data_input;
    len_data=length(data_output);  
    case '1/2'
       
    %1/2 Gen:[15,17]   dfree=6
    g=[ 1 1 0 1; ...  %15
        1 1 1 1 ];   %17
    k=1;    
    case '2/3' 
    %2/3 Gen:[27,75,72]    dfree=5
    g = [ 0 1 0 1 1 1;...    %27
          1 1 1 1 0 1;...    %75
          1 1 1 0 1 0];      %72
    k=2;
    case '3/4'
    %3/4 Gen:[13,25,61,47]   dfree=4
    g = [ 0 0 1 0 1 1;...   %13
          0 1 0 1 0 1;...   %25
          1 1 0 0 0 1;...   %61
          1 0 0 1 1 1 ];    %47
    k=3;
    case '4/5'
    %4/5 Gen:[237,274,156,255,337] dfree=3
    g = [ 1 0 0 1 1 1 1 1;...  %237
          1 0 1 1 1 1 0 0;...  %274
          0 1 1 0 1 1 1 0;...  %156
          1 0 1 0 1 1 0 1;...  %255
          1 1 0 1 1 1 1 1];    %337
    k=4;
    
    otherwise
        
    error('Invalid code rate');
    
end 
 
if(exist('flag')~=1)
    data_input=data_input';
    %  Check to see if extra zero-padding is necessary.
    if rem(length(data_input),k) > 0
      data_input=[data_input,zeros(size(1:k-rem(length(data_input),k)))];
    end
    n=length(data_input)/k;
    %  Determine l and n0.
    l=size(g,2)/k;
    n0=size(g,1);
    %  add extra zeros
    u=[zeros(size(1:(l-1)*k)),data_input,zeros(size(1:(l-1)*k))];
    %  Generate uu, a matrix whose columns are the contents of 
    %  conv. encoder at various clock cycles.
    u1=u(l*k:-1:1);
    for i=1:n+l-2
      u1=[u1,u((i+l)*k:-1:i*k+1)];
    end
    uu=reshape(u1,l*k,n+l-1);
    %  Determine the output
    data_output=reshape(rem(g*uu,2),1,n0*(l+n-1))';
    len_data=length(data_output);

    
end
    if(exist('inter'))
    data_output=interleaving(interleaving(data_output,9,11),9,11);
    end
end

