function rescaled_data = rescale_data(data,limits)
% This function rescales the data between -limits to +limits
data_min = min(min(data));
data_max = max(max(data));
slim = [data_min data_max];
dx=diff(slim);
rescaled_data = limits*((data - slim(1))/dx*2-1);

end

