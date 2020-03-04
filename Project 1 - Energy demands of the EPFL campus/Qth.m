% Helper function to calculate the heat demand 
% Equation (1.3)
% Calculation multiplies the time interval by the energy required, and
% energy provided by irradiation, electrical, and by people

function q = Qth(deltaT, Ath, kth, T_int, T_ext, k_sun, ith, q_people, Q_el_year, heat_switch, index)
    % Only perform calculation if the exterior temperature is < 16 degrees
    if (T_ext(index) < 16 && heat_switch(index) == 1)
        q = deltaT*(Ath*(kth*(T_int-T_ext(index))-k_sun*ith(index)-q_people(index))-Q_el_year(index));
    else
        q = 0;
end