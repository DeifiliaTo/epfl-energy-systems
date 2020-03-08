function q_year = q_plus_year (deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q_people, Q_el_year, heat_switch)
% Calculation of Q+ over all the time intervals
% Eqn (1.4):
% If Q_th >= 0, add Qth(t) to sum. Otherwise, add 0

    % template matrix to use for constants
    z = ones(length(T_ext),1);
    
    % calculate heat load and demand for each time step
    heat_load   = arrayfun(@Qth, deltaT*z, Ath*z, kth*z, T_int*z, T_ext, k_sun*z, ith, q_people, Q_el_year, heat_switch);
    heat_demand = arrayfun(@Qth_plus, heat_load);
    
    % sum the demand over the whole year
    q_year = sum(heat_demand);
    
end
