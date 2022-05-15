/*reset mode*/
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

/*variable of the min and max of hfe and vbe declaration*/
var min_hfe;
var min_vbe;
var max_hfe;
var max_vbe;

/*variable for the dispersion of TRANS*/
var dispersion;

/*constraint for the minimum of hfe of the TRANS*/
subject to h_min {t in TRANS}:
  min_hfe <= hfe[t];

/*constraint for the maximum of hfe of the TRANS*/
subject to h_max {t in TRANS}:
  max_hfe >= hfe[t];

/*constraint for the minimum of vbe of the TRANS*/
subject to v_min {t in TRANS}:
  min_vbe <= vbe[t];

/*constraint for the maximum of vbe of the TRANS*/
subject to v_max {t in TRANS}:
  max_vbe >= vbe[t];

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
data "../data/transistors_q1.dat"

/*solve the model*/
solve;

/*display the dispersion of the set TRANS that gurobi found for the given model*/
display dispersion;
