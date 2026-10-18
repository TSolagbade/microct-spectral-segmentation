function calibrated_slice = air_drift_calibration(raw_slice, air_roi_mask, air_ref_intensity)
% AIR_DRIFT_CALIBRATION Applies additive baseline intensity calibration
% to normalize for scanner flux and detector thermal drift across scans.
%
% Formula:
%   I_cal = I_raw - (mean(I_air_current) - I_air_ref)
%
% Inputs:
%   raw_slice          - 2D matrix (16-bit or double) representing the reconstructed slice
%   air_roi_mask       - Logical binary mask defining a non-attenuating background air ROI
%   air_ref_intensity  - Scalar baseline air intensity from reference scan
%
% Outputs:
%   calibrated_slice   - Drift-corrected 2D slice in normalized Attenuation Units (A.U.)

    % Convert input slice to double precision for arithmetic
    raw_slice_dbl = double(raw_slice);
    
    % Compute mean intensity of background air in current scan
    air_pixels = raw_slice_dbl(air_roi_mask);
    current_air_mean = mean(air_pixels(:));
    
    % Compute additive drift offset
    delta_air = current_air_mean - air_ref_intensity;
    
    % Apply baseline correction
    calibrated_slice = raw_slice_dbl - delta_air;
    
    % Floor negative baseline values to zero
    calibrated_slice(calibrated_slice < 0) = 0;
end
