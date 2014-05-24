H = commsrc.pn('GenPoly',       [20 17 0], ...
              'InitialStates', [1 1 1 zeros(1,5) 1 1 zeros(1,9) 1],   ...
              'CurrentStates', [1 1 1 zeros(1,5) 1 1 zeros(1,9) 1],   ...
              'Mask',          [zeros(1,19) 1] );
              
L = 6144;

set(H, 'NumBitsOut', L);
PN = generate(H);

fileID = fopen('scrambler.txt','w');
fprintf(fileID,'%d\n',L);
for(k=1:length(PN))
    fprintf(fileID,'%d\n',PN(k));
end

fclose(fileID);