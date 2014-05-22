function [ file ] = create_menu( use_menu )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if(use_menu);
    choice = menu('Choose an option for TX','Random','File');
    if(choice==0) error('You must choose something !'); end;
    file=choice-1;
else
    file = 0;
end

end

