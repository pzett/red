function [chain]=markovsource(alpha,beta,N)
if nargin<3
    N=2000;
end
if  nargin<2
alpha=0.2; %transition state 0 to 1
beta=0.2;  %transition  state 1 to 0
end

%%
M=[beta/(alpha+beta),alpha/(alpha+beta)];

%%
P=[1-alpha alpha; beta 1-beta]; % one-step transition matrix
state=0;  %initial state
 %if rand(1)<=0.5
 %    state=0
 %else
 %    state=1
 %end
chain=zeros(1,N);
chain(1)=state;

Tn=P; %Next state matrix
for i=2:N
  flip=rand(1); %Outcome
  switch state %select current state
     case 0 
       if flip<=P(1,2)   %if the outcome is alpha or less 
         state=xor(1,state); % switch state from 0 to 1 (alpha)
        
       else
         
           % Stay in the same state (0) -> 1-alpha
       end
       
     case 1
      if flip<=P(2,1)   %if the outcome is beta or less from 1 to 0
         state=xor(1,state); % switch state from 0 to 1 ->beta
               
      else
        
          %Stay in the same state (1) --> 1-beta
      end
  end
 
  chain(i)=state;
  Tn=Tn*P;   %update transition probabilities T(n)=T(n-1)*P
             %T(i)=P^i for i=2,...,N
  %% Maths 
  %  T(n) =  [ t11*p11 + t12*p21, t11*p12 + t12*p22]
  %          [ t21*p11 + t22*p21, t21*p12 + t22*p22] 
  
  %       =  [ t11 - t12*(b - 1), b*t12 - t11*(a - 1)]
  %          [ t21 - t22*(b - 1), b*t22 - t21*(a - 1)] 
   
end
%stem(chain)
  

