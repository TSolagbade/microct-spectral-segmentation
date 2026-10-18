function [pc1_slice, variance_explained, score_cube] = spectral_pca_unmixing(energy_stack, spatial_mask)
% SPECTRAL_PCA_UNMIXING Decomposes multi-energy micro-CT acquisitions across
% energy channels to isolate coherent anatomical tissue contrast in PC1.
%
% Inputs:
%   energy_stack       - 3D matrix (Rows x Cols x Channels) representing multi-kV slices
%   spatial_mask       - (Optional) 2D logical mask restricting PCA to inclusion ROI
%
% Outputs:
%   pc1_slice          - 2D spatial projection of Principal Component 1 (PC1)
%   variance_explained - Vector containing percentage of variance explained per component
%   score_cube         - 3D matrix (Rows x Cols x Components) containing all PC score images

    [rows, cols, num_channels] = size(energy_stack);
    
    if nargin < 2 || isempty(spatial_mask)
        spatial_mask = true(rows, cols);
    end
    
    % Reshape spatial dimensions into 2D feature matrix (Observations x Channels)
    flat_data = reshape(double(energy_stack), [rows * cols, num_channels]);
    mask_flat = spatial_mask(:);
    
    roi_data = flat_data(mask_flat, :);
    
    % Mean center the multi-energy channels
    roi_mean = mean(roi_data, 1);
    roi_centered = roi_data - roi_mean;
    
    % Compute Cross-Channel Covariance Matrix and Singular Value Decomposition (SVD)
    [~, S, V] = svd(roi_centered, 'econ');
    
    % Calculate eigenvalue variances and percentage explained
    eigenvals = diag(S).^2 / (size(roi_centered, 1) - 1);
    variance_explained = (eigenvals / sum(eigenvals)) * 100;
    
    % Project full image matrix onto Principal Components
    full_centered = flat_data - roi_mean;
    scores = full_centered * V;
    
    % Reshape back to spatial 2D/3D grids
    score_cube = reshape(scores, [rows, cols, num_channels]);
    pc1_slice = score_cube(:, :, 1);
    
    % Normalize PC1 for visualization
    pc1_slice(~spatial_mask) = 0;
end
