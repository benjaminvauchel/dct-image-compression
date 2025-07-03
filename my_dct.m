function dct_coefficients = my_dct(input_signal)
    % MY_DCT Computes the Discrete Cosine Transform (DCT) of a 1D signal
    %
    % Syntax:
    %   dct_coefficients = my_dct(input_signal)
    %
    % Input:
    %   input_signal - Vector containing N values corresponding to f(n)
    %                  where n = 0, 1, ..., N-1
    %
    % Output:
    %   dct_coefficients - Vector containing N DCT coefficients
    %
    % Description:
    %   This function implements the Type-II DCT (most common DCT variant)
    %   using the formula:
    %   X(k) = (2/N) * C(k) * sum(x(n) * cos((2n+1)*k*pi/(2N)))
    %   where C(k) = 1/sqrt(2) for k=0, and C(k) = 1 for k>0

    signal_length = length(input_signal);
    dct_coefficients = zeros(signal_length, 1);

    % C(0) = 1/sqrt(2), C(k) = 1 for k > 0
    normalization_coefficients = ones(signal_length, 1);
    normalization_coefficients(1) = 1/sqrt(2);
    
    for frequency_index = 0:(signal_length - 1)
        coefficient_sum = 0;
        
        for time_index = 0:(signal_length - 1)
            cosine_term = cos((2 * time_index + 1) * frequency_index * pi / (2 * signal_length));
            coefficient_sum = coefficient_sum + input_signal(time_index + 1) * cosine_term;
        end
        
        dct_coefficients(frequency_index + 1) = (2 / signal_length) * normalization_coefficients(frequency_index + 1) * coefficient_sum;
    end
end