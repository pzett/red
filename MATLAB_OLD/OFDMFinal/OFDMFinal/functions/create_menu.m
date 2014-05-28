function [ file ] = create_menu(use_menu,pilot,code,intlv)
%Author : Red Group - Francisco Rosario (frosario@kth.se)
% Create menu for choosing file.
if(pilot && (code || intlv ) )
    error('Pilots can not be used in junction with channel coding or scrambler.');
end

if(use_menu);
    choice = menu('Choose an option for TX','Random','File');
    if(choice==0) error('You must choose something !'); end;
    file=choice-1;
else
    file = 0;
end

end

