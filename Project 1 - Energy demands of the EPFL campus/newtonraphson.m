function [kth, k_sun, i] = newtonraphson(kguess, tol, deltaT, Ath, T_int, T_ext, ith, q, f_el, Q_el_year, Q_th, heat_switch)

i = 0;    
% Finding masked values to calc for Irr, q, Q_el averages
mask = (T_ext > 15) & (T_ext < 17);
Irr_mask = ith.* mask;
q_mask = q .* mask;
Q_el_mask = Q_el_year .* mask;

Irr_mean = 0;
q_mean = 0;
Q_el_mean = 0;

num_points = length(nonzeros(mask));

% Calculate for mean of all the non-zero values
for i = 1:length(Irr_mask)
   if (mask(i) == 1)
       Irr_mean = Irr_mask(i) + Irr_mean;
       q_mean = q_mask(i) + q_mean;
       Q_el_mean = Q_el_mask(i) + Q_el_mean;    
   end
end

Irr_mean = Irr_mean / num_points;
q_mean = q_mean / num_points;
Q_el_mean = Q_el_mean / num_points;

% Define temperature
Tcut = 16;
% Define max number of iterations 
maxIter = 1e4;

% calculate k_sun value based on initial guess
knew = kguess;
k_sun = calc_k_sun (Ath, kguess, T_int, Tcut, Irr_mean, q_mean, f_el, Q_el_mean);

% Init f
f = 1;

% iterative loop
% While we haven't hit maxIter, and still have significant error, loop
while abs(f) > 1e-3 && i < maxIter
    i = i + 1;
    
    obj_fn = @(k_val) q_objective(deltaT, Ath, k_val, T_int, T_ext, k_sun, ith, q, Q_el_year, Q_th, heat_switch);
    
    %calculation of slope and value of objective function
    %dy = sum(deltaT*Ath*(T_int - T_ext));
    dy = (obj_fn(kguess+0.001)-obj_fn(kguess-0.001))/(2*0.001);
    f = obj_fn (kguess);
    
    % update value of k
    knew = kguess - f / dy;
    
    % update value of ksun based on NR solver
    [k_sun, residual] = calc_k_sun (Ath, knew, T_int, Tcut, Irr_mean, q_mean, f_el, Q_el_mean);
    
    kguess = knew;
    
    tol = f;
end

kth = knew;

end