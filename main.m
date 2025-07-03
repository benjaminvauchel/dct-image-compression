clear all
close all

%% =======================================================================
%% Part 1: DCT Testing with Simple Vectors
%% =======================================================================

% Test DCT with constant vector
constant_vector = 20 * ones(1, 8);
dct_constant = my_dct(constant_vector);

% Test DCT with arithmetic sequence
arithmetic_sequence = 0:4:28;
dct_arithmetic = my_dct(arithmetic_sequence);

% Test DCT with random vector
random_vector = [62 5 17 5 83 7 28 25];
dct_random = my_dct(random_vector);

%% =======================================================================
%% Part 2: 1D DCT Image Compression
%% =======================================================================

%% Image Selection and Loading
[filename, filepath] = uigetfile('*.jpg', 'Choose image to compress');
if isequal(filename, 0) || isequal(filepath, 0)
    disp('User cancelled file selection.');
    return;
end

% Load and save image to observe compression effects
original_image = imread(strcat(filepath, filename));
compressed_filename = strcat(filepath, "compressed_", filename);
imwrite(original_image, compressed_filename);

% Note: Image size reduction from 357 KB to 150 KB (2.38x reduction)
% This compression occurs due to:
% 1. Loss of metadata (camera info, EXIF data)
% 2. Resolution changes (72 dpi to 96 dpi)
% 3. MATLAB's imwrite optimization

%% Image Preprocessing
target_size = [464, 720];
resized_image = imresize(original_image, target_size);
figure; imshow(resized_image); title('Resized Image');

%% 1D DCT Calculation and Frequency Spectrum Display
inverted_image = double(255 - resized_image);
dct_coefficients = zeros(size(inverted_image));

% Apply DCT to each row
for row = 1:size(inverted_image, 1)
    dct_coefficients(row, :) = my_dct(inverted_image(row, :));
end

% Display frequency spectrum
frequency_spectrum = 10 * abs(dct_coefficients);
frequency_spectrum = 255 - uint8(frequency_spectrum);
figure; imshow(frequency_spectrum); title('1D DCT Frequency Spectrum');

%% Quantization and Inverse DCT
quantization_factor = 5;
quantized_dct = round(dct_coefficients / quantization_factor);

% Inverse DCT calculation
reconstructed_image = zeros(size(quantized_dct));
cosine_weights = ones(1, size(quantized_dct, 2));
cosine_weights(1) = 1/sqrt(2);

for row = 1:size(quantized_dct, 1)
    for col = 1:size(quantized_dct, 2)
        pixel_sum = 0;
        for freq_idx = 1:size(quantized_dct, 2)
            pixel_sum = pixel_sum + cosine_weights(freq_idx) * ...
                       quantized_dct(row, freq_idx) * ...
                       cos((2*col - 1) * (freq_idx - 1) * pi / (2 * size(quantized_dct, 2)));
        end
        reconstructed_image(row, col) = pixel_sum;
    end
end

% Display reconstructed image
final_image_1d = 255 - uint8(quantization_factor * reconstructed_image);
figure; imshow(final_image_1d); title('1D DCT Reconstructed Image');

%% =======================================================================
%% Part 3: 2D DCT Image Compression
%% =======================================================================

%% DCT and Quantization Matrix Setup
block_size = 8;
cosine_weights = ones(1, block_size);
cosine_weights(1) = 1/sqrt(2);

% DCT transformation matrix
dct_matrix = zeros(block_size);
for i = 1:block_size
    for j = 1:block_size
        dct_matrix(i, j) = cosine_weights(i) / 2 * cos((i-1) * (2*j-1) * pi / 16);
    end
end
dct_matrix_transpose = dct_matrix';

% Standard JPEG quantization matrix
jpeg_quantization_matrix = [
    16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56;
    14 17 22 29 61 87 80 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 103 121 120 101;
    72 92 95 98 112 100 103 90
];

%% 2D DCT Compression with Different Quality Factors
quality_factors = [1, 5, 50];

for quality_factor = quality_factors
    scaled_quantization = quality_factor * jpeg_quantization_matrix;
    
    % Initialize result matrices
    dct_blocks = zeros(size(inverted_image));
    quantized_blocks = zeros(size(inverted_image));
    reconstructed_blocks = zeros(size(inverted_image));
    
    % Process image in 8x8 blocks
    for row = 1:block_size:size(inverted_image, 1)
        for col = 1:block_size:size(inverted_image, 2)
            % Extract current block
            current_block = inverted_image(row:row+7, col:col+7);
            
            % Apply 2D DCT
            dct_block = dct_matrix * current_block * dct_matrix_transpose;
            dct_blocks(row:row+7, col:col+7) = dct_block;
            
            % Quantize DCT coefficients
            quantized_block = round(dct_block ./ scaled_quantization);
            quantized_blocks(row:row+7, col:col+7) = quantized_block;
            
            % Reconstruct block (inverse quantization and inverse DCT)
            dequantized_block = quantized_block .* scaled_quantization;
            reconstructed_block = dct_matrix_transpose * dequantized_block * dct_matrix;
            reconstructed_blocks(row:row+7, col:col+7) = reconstructed_block;
        end
    end
    
    % Display quantized frequency spectrum
    spectrum_display = 100 * abs(quantized_blocks);
    spectrum_display = 255 - uint8(spectrum_display);
    figure; imshow(spectrum_display);
    title(sprintf('8x8 DCT Frequency Spectrum (Quality Factor: %dQ)', quality_factor));
    
    % Display reconstructed image
    final_image_2d = 255 - uint8(reconstructed_blocks);
    figure; imshow(final_image_2d);
    title(sprintf('2D DCT Reconstructed Image (Quality Factor: %dQ)', quality_factor));
    
    % Save compressed image
    output_filename = sprintf('%scompressed_DCT2D_%dQ_%s', filepath, quality_factor, filename);
    imwrite(final_image_2d, output_filename);
end

%{
Compression Quality Analysis:

* Quality Factor 1Q: Very similar to original image
  File size reduced by 3.72x (357 KB → 131 KB)
  Excellent visual quality preservation

* Quality Factor 5Q: Slightly different from 1Q
  Higher contrast appearance, but still acceptable quality
  File size reduced by 4.15x (357 KB → 86 KB)
  Good balance between quality and compression

* Quality Factor 50Q: Severe quality degradation
  Visible 8x8 pixel blocks with only 4 gray levels
  Appearance similar to heavily downsampled image
  File size reduced by 39.7x (357 KB → 9 KB)
  Extreme compression with poor visual quality

Frequency Spectrum Analysis:
Higher quantization factors result in whiter spectra, indicating
loss of high-frequency information. 50Q shows mostly white pixels.

2D DCT consistently outperforms 1D DCT compression:
2D 1Q compressed file is 1.15x smaller than 1D compressed file.
%}

%% =======================================================================
%% Part 4: Zigzag Scanning Pattern
%% =======================================================================

function zigzag_indices = generate_zigzag_pattern(matrix_size)
    % Generate zigzag scanning pattern for square matrix
    % Input: matrix_size - size of square matrix
    % Output: zigzag_indices - 2xN matrix with row,col indices
    
    [rows, cols] = size(zeros(matrix_size));
    zigzag_indices = zeros(2, rows * cols);
    
    current_row = 1;
    current_col = 1;
    index = 0;
    going_up = false;
    
    while current_row <= rows && current_col <= cols
        index = index + 1;
        zigzag_indices(:, index) = [current_row; current_col];
        
        % Handle boundary conditions
        if current_row == 1 || current_row == rows
            if current_col == cols
                current_row = current_row + 1;
            else
                current_col = current_col + 1;
            end
            index = index + 1;
            zigzag_indices(:, index) = [current_row; current_col];
        elseif current_col == 1 || current_col == cols
            if current_row == rows
                current_col = current_col + 1;
            else
                current_row = current_row + 1;
            end
            index = index + 1;
            zigzag_indices(:, index) = [current_row; current_col];
        end
        
        % Determine scanning direction
        if current_row == 1 || current_col == cols
            going_up = false;  % Move down-left
        elseif current_col == 1 || current_row == rows
            going_up = true;   % Move up-right
        end
        
        % Move in the determined direction
        if going_up
            current_row = current_row - 1;
            current_col = current_col + 1;
        else
            current_row = current_row + 1;
            current_col = current_col - 1;
        end
    end
end

% Generate and visualize zigzag pattern for 10x10 matrix
matrix_size = 10;
zigzag_pattern = generate_zigzag_pattern(matrix_size);

% Plot zigzag pattern
figure;
plot(zigzag_pattern(2, :), zigzag_pattern(1, :), 'LineWidth', 2);
axis ij;
set(gca, 'XAxisLocation', 'top');
title(sprintf('Zigzag Scanning Pattern for %dx%d Matrix', matrix_size, matrix_size));
ylabel('Height [pixels]');
xlabel('Width [pixels]');
grid on;