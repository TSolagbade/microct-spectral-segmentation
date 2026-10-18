%% Demo Pipeline: Automated Segmentation and Multi-Energy Spectral PCA
% This synthetic demonstration validates the end-to-end computational pipeline 
% using simulated multi-energy micro-CT slices containing tissue-matrix 
% attenuation overlap (delta_mu ~ 0).

clear; clc; close all;
addpath('src');

fprintf('1. Generating synthetic multi-energy slice stack (40 to 120 kV)...\n');
rows = 512; cols = 512; channels = 4;
simulated_stack = zeros(rows, cols, channels);

% Define coordinate grid
[X, Y] = meshgrid(1:cols, 1:rows);
center_x = 256; center_y = 256;
radius_resin = 200;
radius_insect = 60;

resin_mask = ((X - center_x).^2 + (Y - center_y).^2) <= radius_resin^2;
insect_mask = ((X - center_x).^2 + (Y - center_y).^2) <= radius_insect^2;
air_roi = ~resin_mask;

% Energy channel base attenuations (simulating delta_mu ~ 0)
energy_levels = [40, 70, 90, 120];
for c = 1:channels
    base_resin = 11000 - (c * 200);
    base_tissue = base_resin + 15; % Near-identical attenuation
    
    slice_c = zeros(rows, cols);
    slice_c(resin_mask) = base_resin + 50 * randn(sum(resin_mask(:)), 1);
    slice_c(insect_mask) = base_tissue + 45 * randn(sum(insect_mask(:)), 1);
    slice_c(air_roi) = 150 + 10 * randn(sum(air_roi(:)), 1);
    
    simulated_stack(:, :, c) = slice_c;
end

fprintf('2. Executing baseline air-drift calibration...\n');
calibrated_stack = zeros(size(simulated_stack));
air_ref_baseline = 150.0;
air_sample_mask = false(rows, cols);
air_sample_mask(10:40, 10:40) = true;

for c = 1:channels
    calibrated_stack(:, :, c) = air_drift_calibration(simulated_stack(:, :, c), air_sample_mask, air_ref_baseline);
end

fprintf('3. Performing automated circular masking and Dynamic KDE mode suppression...\n');
representative_slice = calibrated_stack(:, :, 3); % 90 kV channel
[segmented_cuticle, identified_mode, masked_slice] = dynamic_kde_segmentation(representative_slice, 2000, 0.90);
fprintf('   -> Identified Bulk Matrix Peak: %.2f A.U.\n', identified_mode);

fprintf('4. Running Multi-Energy Spectral PCA unmixing...\n');
[pc1_slice, variance_explained, ~] = spectral_pca_unmixing(calibrated_stack, resin_mask);
fprintf('   -> Variance explained by PC1: %.2f%%\n', variance_explained(1));

fprintf('\nPipeline executed successfully.\n');
