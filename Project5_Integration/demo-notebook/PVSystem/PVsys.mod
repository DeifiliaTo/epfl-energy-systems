/*---------------------------------------------------------------------------------------------------------------------------------------
Course: Modelling and optimisation of energy systems course spring semester 2020
EPFL Campus energ system optimization
IPESE, EPFL
Author: Jordan Holweger (PVlab)

---------------------------------------------------------------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------------------------------------------------------------
Project Part5 case study model, to show some example of multi objective optimization using a PV system
---------------------------------------------------------------------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------------------------------------------------------------------
Generic Sets
---------------------------------------------------------------------------------------------------------------------------------------*/
param T;
set Time =1..T ordered; 											# time segments of the problem 
set N default {};												# number of PV configuration

/*---------------------------------------------------------------------------------------------------------------------------------------
Parameters
---------------------------------------------------------------------------------------------------------------------------------------*/
param ts default 900;										# optimization time step (default to 15min)

param G{Time,N};										# solar irradiation [W/m2] at each time step for the PV configuration N
param Amax{N};												# available  area for PV installation 

param p_load{Time};												# electrical demand of the building
param CF_pv default 0;								# fixed cost component for PV
param C_pv default 1000; # CHF/kW variable cost compoenent for PV
param CF_bat default 0; #fixed cost componnent for batery
param C_bat default 300; # CHF/kWh variable cost components for batery
param c_bat default 1e-6;
param eff_pv default 0.2;										# PV efficiency
param eff_bat default 0.9;										# batery charge and discharge efficiency
param CR_bat default 1;											# batery C rate 1kW/kWh
param alpha default 1;

param L default 25;														# system lifetime
param r default 0.03;														# interest rate
param t_imp{Time};
param t_exp{Time};
param t_max default 0;

/*---------------------------------------------------------------------------------------------------------------------------------------
Variables
---------------------------------------------------------------------------------------------------------------------------------------*/
# grid
var p_imp{Time}>=0;
var p_exp{Time} >=0;
var p_max >=0;

# pv
var p_pv{Time}>=0;
var p_cur{Time}>=0;

#batery
var p_dis{Time}>=0;
var p_cha{Time}>=0;
var E_bat{Time}>=0;
var b_CD{Time} binary;

#investment decision
var b_pv binary;
var b_bat binary;

var P_pv_cap{N}>=0;
var E_bat_cap>=0, <=50 ;

/*---------------------------------------------------------------------------------------------------------------------------------------
Constraints
---------------------------------------------------------------------------------------------------------------------------------------*/
subject to pwr_bal_cstr{t in Time}:
	p_imp[t] - p_exp[t]  + p_dis[t] - p_cha[t] +p_pv[t] -p_cur[t] = p_load[t];

subject to pv_gen_cstr{t in Time}:
	p_pv[t] = sum{n in N} ((P_pv_cap[n]*1000)*(G[t,n]/1000)); 

subject to pv_area_cstr{n in N}:
	b_pv * Amax[n]*eff_pv >= P_pv_cap[n];
	
subject to bat_invest_cstr:
	b_bat *1e6>=E_bat_cap;

subject to batt_bal_cstr{t in 1..T-1}:
	E_bat[t+1] = alpha *E_bat[t] + (eff_bat*p_cha[t+1]*ts)/3.6e6 - ((1/eff_bat)*p_dis[t+1]*ts)/3.6e6;

subject to batt_cha_cstr{t in Time}:
	p_cha[t] <= CR_bat*E_bat_cap*1000;

subject to batt_dis_cstr{t in Time}:
	p_dis[t] <= CR_bat*E_bat_cap*1000;

subject to batt_init:
	E_bat[1] = 0.5*E_bat_cap;

subject to batt_fin:
	E_bat[T] = 0.5*E_bat_cap;

subject to batt_size_cstr{t in Time}:
	E_bat[t]<=E_bat_cap;

subject to batt_chardis_a_cstr{t in Time}:
	p_dis[t] - 1e12*b_CD[t] <=0;

subject to batt_chardis_b_cstr{t in Time}:
	p_cha[t] - 1e12*(1-b_CD[t]) <=0;

subject to no_cha_dis:
	p_cha[1]+p_dis[1]=0;
/*---------------------------------------------------------------------------------------------------------------------------------------
Indicator and objective function
---------------------------------------------------------------------------------------------------------------------------------------*/

subject to p_max_imp{t in Time}:
	p_imp[t] <= p_max;
	
subject to p_max_exp{t in Time}:
	p_exp[t] <= p_max;

var p_sc{Time}>=0; 	# self-consumed power

subject to p_sc_a_cstr{t in Time}:
	p_sc[t] <= p_load[t];
subject to p_sc_b_cstr{t in Time}:
	p_sc[t]<= p_exp[t] + p_load[t] - p_imp[t];



set Indicator default {'ox_ge','ox_pwr','opex','capex','totex','GU','SS','pbt','SC','pv_cur'};

# upper bounds for indicator function (useful for paretto front) 
param ub_obj{Indicator} default Infinity;

var obj_fcn {o in Indicator}<=ub_obj[o];

#weights of the objective function (normally 0 or 1, but could be other)
param b_obj{Indicator} default 0; 


# constraint for indicator calculation

subject to grid_exch_cost:
	obj_fcn['ox_ge'] = ts/3.6e6*sum{t in Time} (p_imp[t]*t_imp[t] - p_exp[t]*t_exp[t]);

subject to grid_pow_cost:
	obj_fcn['ox_pwr'] = p_max*t_max;

subject to opex_cstr:
	obj_fcn['opex'] = 365*24*60*60/(T*ts)*(obj_fcn['ox_ge'] + obj_fcn['ox_pwr']) ;

subject to capex_cstr:
	#obj_fcn['capex'] = (sum{n in N} P_pv_cap[n]*C_pv) + (E_bat_cap*C_bat);
	obj_fcn['capex'] = (b_pv*CF_pv + sum{n in N} P_pv_cap[n]*C_pv) + (b_bat*CF_bat+E_bat_cap*C_bat);

subject to totex_cstr:
	obj_fcn['totex'] = (r *(1+r)^L)/((1+r)^L-1) * obj_fcn['capex'] + obj_fcn['opex'];
	


subject to gu_str:
	obj_fcn['GU'] = p_max/ (max{t in Time} p_load[t]);
	
subject to ss_cstr:
	obj_fcn['SS'] = (sum{t in Time} p_sc[t])/(sum{t in Time} p_load[t]);
	


/*---------------------------------------------------------------------------------------------------------------------------------------
Minimize opbjective function
---------------------------------------------------------------------------------------------------------------------------------------*/
#Minimize declaration
let  b_obj['totex'] := 1;
minimize ObjFcn:sum{o in Indicator} (b_obj[o]*obj_fcn[o]) + ts*sum{t in Time} p_dis[t]*c_bat;
