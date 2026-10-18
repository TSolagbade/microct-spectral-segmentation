function [segmented_mask, resin_mode, masked_slice] = dynamic_kde_segmentation(slice_data, tolerance_window, radial_fraction)
% DYNAMIC_KDE_SEGMENTATION Performs automated circular spatial masking and
% dynamic Kernel Density Estimation (KDE) mode suppression on bulk resin matrix.
%
% Inputs:
%   slice_data         - 2D calibrated micro-CT slice matrix
%   tolerance_window   - Scalar tolerance band around matrix peak (e.g., 2000 A.U.)
%   radial_fraction    - Fraction of image radius to preserve inside circular mask (default: 0.90)
%
% Outputs:
%   segmented_mask     - Logical mask of isolated inclusion features (cuticle/cavity)
%   resin_mode         - Dynamically identified bulk resin attenuation peak (A.U.)
%   masked_slice       - Slice matrix after container and mold boundary rejection

    if nargin < 2 || isempty(tolerance_window)
        tolerance_window = 2000;
    end
    if nargin < 3 || isempty(radial_fraction)
        radial_fraction = 0.90;
    end

    [rows, cols] = size(slice_data);
    center_y = rows / 2;
    center_x = cols / 2;
    radius = (min(rows, cols) / 2) * radial_fraction;
    
    % Step 1: Automated Circular Spatial Masking
    [X, Y] = meshgrid(1:cols, 1:rows);
    circle_mask = ((X - center_x).^2 + (Y - center_y).^2) <= (radius^2);
    
    masked_slice = double(slice_data);
    masked_slice(~circle_mask) = NaN;
    
    % Extract valid interior voxels excluding zero padding
    valid_voxels = masked_slice(circle_mask & ~isnan(masked_slice) & masked_slice > 0);
    
    % Step 2: Continuous Gaussian Kernel Density Estimation (KDE)
    % Subsample if voxel count exceeds 100,000 for computational efficiency
    if numel(valid_voxels) > 100000
        sample_voxels = valid_voxels(round(linspace(1, numel(valid_voxels), 100000)));
    else
        sample_voxels = valid_voxels;
    end
    
    eval_points = linspace(min(sample_voxels), max(sample_voxels), 1000);
    [f_pdf, xi] = ksdensity(sample_voxels, eval_points);
    
    % Step 3: Dynamic Bulk Resin Peak Identification
    [~, max_idx] = max(f_pdf);
    resin_mode = xi(max_idx);
    
    % Step 4: Dynamic Mode Suppression (Suppress Resin Window)
    % Features outside the bulk resin mode window represent inclusion tissues or voids
    resin_band = (slice_data >= (resin_mode - tolerance_window)) & ...
                 (slice_data <= (resin_mode + tolerance_window));
             
    segmented_mask = circle_mask & ~resin_band & (slice_data > 0);
end
