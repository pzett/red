function [ decoder_output,len_data] = convdecode( channel_output,code_rate,inter )
%CONVDECODE Viterbi decoding for convolutional code with variable rate
%  input: data input
%  code_rate:k/n, e.g. String: '1/2', '2/3', '3/4','4/5'
%  Generator polynomials taken from 
%  Proakis,Salehi:Digital Communications pp.517-520 
  if(exist('inter'))
    channel_output=deinterleaving(deinterleaving(channel_output,9,11),9,11);
    end
switch code_rate
    case '0'
    flag=0; 
    case '1/2'
    %1/2 Gen:[15,17]   dfree=6
    G=[ 1 1 0 1; ...  %15
        1 1 1 1 ];   %17
    k=1;    
    case '2/3' 
    %2/3 Gen:[27,75,72]    dfree=5
    G = [ 0 1 0 1 1 1;...    %27
          1 1 1 1 0 1;...    %75
          1 1 1 0 1 0];      %72
    k=2;
    case '3/4'
    %3/4 Gen:[13,25,61,47]   dfree=4
    G = [ 0 0 1 0 1 1;...   %13
          0 1 0 1 0 1;...   %25
          1 1 0 0 0 1;...   %61
          1 0 0 1 1 1 ];    %47
    k=3;
    case '4/5'
    %4/5 Gen:[237,274,156,255,337] dfree=3
    G = [ 1 0 0 1 1 1 1 1;...  %237
          1 0 1 1 1 1 0 0;...  %274
          0 1 1 0 1 1 1 0;...  %156
          1 0 1 0 1 1 0 1;...  %255
          1 1 0 1 1 1 1 1];    %337
    k=4;
    
    otherwise
        
    error('Invalid code rate');
    
end
if(exist('flag')~=1)
    n=size(G,1);
    L=size(G,2)/k;
    number_of_states=2^((L-1)*k);
    %  Generate state transition matrix, output matrix, and input matrix.
    for j=0:number_of_states-1
      for l=0:2^k-1
        [next_state,memory_contents]=nxt_stat(j,l,L,k);
        input(j+1,next_state+1)=l;
        branch_output=rem(memory_contents*G',2);
        nextstate(j+1,l+1)=next_state;
        output(j+1,l+1)=bin2deci(branch_output);
      end
    end
    state_metric=zeros(number_of_states,2);
    depth_of_trellis=ceil(length(channel_output)/n);
    channel_output_matrix=reshape(channel_output,n,depth_of_trellis);
    survivor_state=zeros(number_of_states,depth_of_trellis+1);
    %  Start decoding of non-tail channel outputs.
    for i=1:depth_of_trellis-L+1
      flag=zeros(1,number_of_states);
      if i <= L
        step=2^((L-i)*k);
      else
        step=1;
      end
      for j=0:step:number_of_states-1
        for l=0:2^k-1
          branch_metric=0;
          binary_output=deci2bin(output(j+1,l+1),n);
          for ll=1:n
            branch_metric=branch_metric+metric(channel_output_matrix(ll,i),binary_output(ll));
          end
          if((state_metric(nextstate(j+1,l+1)+1,2) > state_metric(j+1,1)...
            +branch_metric) || flag(nextstate(j+1,l+1)+1)==0)
            state_metric(nextstate(j+1,l+1)+1,2) = state_metric(j+1,1)+branch_metric;
            survivor_state(nextstate(j+1,l+1)+1,i+1)=j;
            flag(nextstate(j+1,l+1)+1)=1;
          end
        end
      end
      state_metric=state_metric(:,2:-1:1);
    end
    %  Start decoding of the tail channel-outputs.
    for i=depth_of_trellis-L+2:depth_of_trellis
      flag=zeros(1,number_of_states);
      last_stop=number_of_states/(2^((i-depth_of_trellis+L-2)*k));
      for j=0:last_stop-1
          branch_metric=0;
          binary_output=deci2bin(output(j+1,1),n);
          for ll=1:n
            branch_metric=branch_metric+metric(channel_output_matrix(ll,i),binary_output(ll));
          end
          if((state_metric(nextstate(j+1,1)+1,2) > state_metric(j+1,1)...
            +branch_metric) || flag(nextstate(j+1,1)+1)==0)
            state_metric(nextstate(j+1,1)+1,2) = state_metric(j+1,1)+branch_metric;
            survivor_state(nextstate(j+1,1)+1,i+1)=j;
            flag(nextstate(j+1,1)+1)=1;
          end
      end
      state_metric=state_metric(:,2:-1:1);
    end
    %  Generate the decoder output from the optimal path.
    state_sequence=zeros(1,depth_of_trellis+1);
    state_sequence(1,depth_of_trellis)=survivor_state(1,depth_of_trellis+1);
    for i=1:depth_of_trellis
      state_sequence(1,depth_of_trellis-i+1)=survivor_state((state_sequence(1,depth_of_trellis+2-i)...
      +1),depth_of_trellis-i+2);
    end
    decodeder_output_matrix=zeros(k,depth_of_trellis-L+1);
    for i=1:depth_of_trellis-L+1
      dec_output_deci=input(state_sequence(1,i)+1,state_sequence(1,i+1)+1);
      dec_output_bin=deci2bin(dec_output_deci,k);
      decoder_output_matrix(:,i)=dec_output_bin(k:-1:1)';
    end
    decoder_output=reshape(decoder_output_matrix,1,k*(depth_of_trellis-L+1));
    cumulated_metric=state_metric(1,1);
    
else
    decoder_output=channel_output;
end
len_data=length(decoder_output);
