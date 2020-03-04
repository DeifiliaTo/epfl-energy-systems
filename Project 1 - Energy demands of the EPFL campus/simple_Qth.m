function [Qth_calculated] = simple_Qth(Ath,kth,T_int,Text,ksun,Irr,q_people,Q_elec,heat_switch)
if Text<16 && heat_switch == 1
    Qth_calculated = Ath*(kth*(T_int-Text)-ksun*Irr-q_people)-Q_elec;
else
    Qth_calculated = 0;
end
end

