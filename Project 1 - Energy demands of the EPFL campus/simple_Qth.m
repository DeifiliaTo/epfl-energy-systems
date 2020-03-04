function [Qth_calculated] = simple_Qth(Build.ground,Build.kth,T_int,Text,Build.ksun,Irr,q_people.year,p.elec.year.v)
if Text<16
Qth_calculated = Build.ground*(Build.kth*(T_int-Text)-Build.ksun*Irr-q_people.year)-p.elec.year.v;
else Qth_calculated = 0;
end
end

