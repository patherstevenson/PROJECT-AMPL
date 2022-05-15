/*reset model*/
reset;

/*set gurobi as solver*/
option solver gurobi;

/*transistors SET declaration*/
set TRANS;

/*PARAM of TRANS set declaration*/
param hfe {TRANS};
param vbe {TRANS};

/*constant param declaration*/
param MAXHFE;
param MAXVBE;
param NB_PAQUET > 0;

/*paquet SET declaration*/
set PAQUET = 1 .. NB_PAQUET;

/*variable of the min and max of hfe and vbe declaration for a p of PAQUET SET*/  
var min_hfe {PAQUET};
var min_vbe {PAQUET};
var max_hfe {PAQUET};
var max_vbe {PAQUET};

/*variable for the dispersion for a p of PAQUET SET*/
var dispersion {PAQUET};

/* binary variable which represents the inclusion
 * or exclusion of the given transistors and a given PAQUET
 * like an affectation to a PAQUET*/
var affectation {TRANS,PAQUET} binary;

/*variable that represent the sum of dispersion contains in dispersion variable*/
var total_disp;

/*the following constraints take in account the inclusion or exclusion of the t transistors for the p PAQUET 
 * due to the binary value of couple [t,p] in affectation tab */

/*constraint for the minimum of hfe in the p PAQUET*/
subject to h_min {t in TRANS, p in PAQUET}:
  min_hfe[p] <= affectation[t,p] * hfe[t] + (1 - affectation[t,p]) * MAXHFE;

/*constraint for the maximum of hfe in the p PAQUET*/
subject to h_max {t in TRANS, p in PAQUET}:
  max_hfe[p] >= affectation[t,p] * hfe[t];

/*constraint for the minimum of vbe in the p PAQUET*/
subject to v_min {t in TRANS, p in PAQUET}:
  min_vbe[p] <= affectation[t,p] * vbe[t] + (1 - affectation[t,p]) * MAXVBE;

/*constraint for the maximum of vbe in the p PAQUET*/
subject to v_max {t in TRANS, p in PAQUET}:
  max_vbe[p] >= affectation[t,p] * vbe[t];

/*constraint of uniqueness of presence of a transistor among all the PAQUETs*/
subject to affectation_unique_transistor {t in TRANS}:
  sum {p in PAQUET} affectation[t,p] == 1;

/*minimum and maximum cardinality constraint for a p PAQUET
 * by using the affectation tab with [t,p] transistors paquet couple*/
subject to nb_transistors_par_paquets{p in PAQUET}:
  floor(card(TRANS)/NB_PAQUET) <= sum {t in TRANS} affectation[t,p] <= ceil(card(TRANS)/NB_PAQUET); 

/*min and max hfe ratio of the p PAQUET*/
subject to disp_h {p in PAQUET}: 
  dispersion[p] >= ((max_hfe[p] - min_hfe[p]) / MAXHFE);

/*min and max vbe ratio of the p PAQUET*/
subject to disp_v {p in PAQUET}:
   dispersion[p] >= ((max_vbe[p] - min_vbe[p]) / MAXVBE);

/*we do the sum of the dispersion of all p in PAQUET*/
subject to sum_disp:
  total_disp >= sum {p in PAQUET} dispersion[p];

/*the goal is to minimize the sum of the dispersion of all p in PAQUET
 *in this way we minimize the disperison of all p PAQUET */
minimize disp_min:
  total_disp;

/*load data from ../data/ folder*/
data "../data/transistors_q4.dat"

/*solve the model*/
solve;

/*display sum of dispersion of all paquet*/
display total_disp;

/*display the minimize dispersion of all PAQUET*/
display dispersion;

/*display the binary value for the affectation of the t transistors in the p PAQUET*/
display affectation;
