# DCT Image Compression

A MATLAB implementation of image compression using Discrete Cosine Transform (DCT) with both 1D and 2D approaches, including JPEG-style quantization and zigzag scanning patterns.

## Overview

This project demonstrates various aspects of DCT-based image compression:
- Custom DCT implementation for 1D signals
- 1D DCT compression applied row-wise to images
- 2D DCT compression using 8×8 blocks (JPEG)
- Quantization effects on image quality and file size
- Zigzag scanning pattern for frequency coefficient ordering

## 📌 Features

### DCT Analysis
- **Custom DCT Function**: Implementation of Type-II DCT for 1D signals

### Image Compression
- **1D DCT Compression**: Row-wise DCT application with quantization
- **2D DCT Compression**: Block-based compression using 8×8 DCT blocks
- **JPEG Quantization**: Standard JPEG quantization matrix implementation
- **Quality Factor Control**: Adjustable compression levels (1Q, 5Q, 50Q)

### Compression Analysis
- **File Size Reduction**: Automatic calculation of compression ratios
- **Quality Assessment**: Visual comparison of original vs. compressed images
- **Frequency Analysis**: Spectrum visualization showing compression effects

### Advanced Features
- **Zigzag Scanning**: Implementation of zigzag pattern for coefficient ordering
- **Interactive File Selection**: GUI-based image file selection
- **Batch Processing**: Multiple quality factor processing in single run

## File Structure

```
dct-image-compression/
├── README.md                    # This file
├── dct_image_compression.m      # Main compression script
└── my_dct.m                    # Custom DCT function
```

## Requirements

- MATLAB R2016b or later

## Usage

### Basic Usage

1. **Run the main script**:
   ```matlab
   run('dct_image_compression.m')
   ```

2. **Select an image** when prompted by the file dialog

3. **View results**: The script will generate and display:
   - Original and resized images
   - Frequency spectra for different compression levels
   - Reconstructed images with various quality factors
   - Compressed files saved automatically

### Using the DCT Function

```matlab
% Example: Compute DCT of a simple signal
signal = [1, 2, 3, 4, 5, 6, 7, 8];
dct_coefficients = my_dct(signal);

% Display results
disp('Original signal:');
disp(signal);
disp('DCT coefficients:');
disp(dct_coefficients');
```

### Quality Factor Selection

The script tests three quality factors:
- **1Q**: High quality, moderate compression
- **5Q**: Good quality, better compression
- **50Q**: Low quality, maximum compression

## Results

### Compression Performance Example

| Quality Factor | File Size Reduction | Visual Quality | Use Case |
|---------------|-------------------|----------------|----------|
| 1Q | 3.72× | Excellent | Archival, professional |
| 5Q | 4.15× | Good | Web, general use |
| 50Q | 39.7× | Poor | Thumbnails, previews |

### Key Findings

- **2D DCT outperforms 1D DCT**: 2D compression achieves 1.15× better compression than 1D
- **Quality-Size Trade-off**: Higher quantization dramatically reduces file size but introduces artifacts
- **Block Artifacts**: Severe quantization (50Q) produces visible 8×8 pixel blocks
- **Frequency Loss**: Higher compression removes high-frequency details first

## Technical Details

### DCT Implementation

The custom DCT function implements the Type-II DCT:

```
X(k) = (2/N) * C(k) * Σ[x(n) * cos((2n+1)*k*π/(2N))]
```

Where:
- `C(k) = 1/√2` for k=0
- `C(k) = 1` for k>0

### Quantization Process

1. **Forward DCT**: Transform 8×8 image blocks to frequency domain
2. **Quantization**: Divide coefficients by quantization matrix
3. **Rounding**: Round to nearest integer (lossy step)
4. **Inverse Process**: Multiply by quantization matrix and apply inverse DCT

### Zigzag Scanning

The zigzag pattern orders DCT coefficients from low to high frequency, enabling efficient encoding of the mostly-zero high-frequency coefficients.

## Examples

### Before and After Compression

**Original Image**: 357 KB
- **1Q Compression**: 131 KB (2.7× reduction)
- **5Q Compression**: 86 KB (4.2× reduction)  
- **50Q Compression**: 9 KB (39.7× reduction)

### Frequency Spectrum Changes

- **Low Quantization**: Preserves most frequency information
- **High Quantization**: Removes high-frequency details, creates blocky artifacts

## License

This project is provided for educational purposes. Feel free to use and modify for learning and research.

## Acknowledgments

- Based on DCT theory and JPEG compression standards
- Implements standard JPEG quantization matrices
- Educational project for understanding image compression fundamentals
