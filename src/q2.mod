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
param E;

/*variable of the min and max of hfe and vbe declaration*/  
var min_hfe;
var min_vbe;
var max_hfe;
var max_vbe;

/*variable for the dispersion of TRANS*/
var dispersion;

/* binary variable which represents the inclusion 
 * or exclusion of the given transistors to reduce the dispersion of the TRANS set*/
var selection {t in TRANS} binary;

/*the following constraints take in account the inclusion or exclusion of the t transistors in the dispersion 
 * due to the binary value of t in selection tab *
 /
/*constraint for the minimum of hfe of the TRANS*/
subject to h_min {t in TRANS}:
  min_hfe <= selection[t] * hfe[t] + (1 - selection[t]) * MAXHFE;

/*constraint for the maximum of hfe of the TRANS*/
subject to h_max {t in TRANS}:
  max_hfe >= selection[t] * hfe[t];

/*constraint for the minimum of vbe of the TRANS*/
subject to v_min {t in TRANS}:
  min_vbe <= selection[t] * vbe[t] + (1 - selection[t]) * MAXVBE;

/*constraint for the maximum of vbe of the TRANS*/
subject to v_max {t in TRANS}:
  max_vbe >= selection[t] * vbe[t];

/*minimum cardinality constraint of transistors which are include in the dispersion calcul*/
subject to min_trans:
  sum {t in TRANS} selection[t] >= card(TRANS) - E;

/*min and max hfe ratio of TRANS*/
subject to disp_h: 
  dispersion >= ((max_hfe - min_hfe) / MAXHFE);

/*min and max vbe ratio of TRANS*/
subject to disp_v:
   dispersion >= ((max_vbe - min_vbe) / MAXVBE);

/*goal is to minimize the dispersion of TRANS*/
minimize disp_min:
  dispersion;

/*load data from ../data/ folder*/
data "../data/transistors_q2.dat"

/*solve the model*/ 
solve;

/*display the dispersion of the set TRANS that gurobi found for the given model*/ 
display dispersion;

/*display the selection tab which contains 1 if the t transistors is include in the dispersion calcul of the TRANS set
 * or 0 if the t transistor is exclude */
display selection;