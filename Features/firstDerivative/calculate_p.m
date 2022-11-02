function [p] = calculate_p(PPGmod,PPGbeat,y,opt_params,algorithmName,freq)
% input:
% PPGmod            ...     PPG beat modeled by kernels
% PPGbeat           ...     beat of PPG signal that is to be decomposed
% y                 ...     shapes of kernels based on optimized parameters
% opt_params        ...     optimized parameters of the kernels
% algorithmName     ...     algorithm that was used for the decomposition
% freq              ...     sampling frequency of input signal
%
% outputs:
% p                 ...     maximum of first derivative

%% exceptions
if(any(isnan(PPGmod)))
    p = NaN;
    return
end

%% calculate p
first_deriv = deriv1(PPGmod);
p = max(first_deriv); % find p

end