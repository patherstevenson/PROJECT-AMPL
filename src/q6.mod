/*reset model*/
reset;

/*set gurobi as solver*/
option solver gurobi;

/*transistors SET declaration*/
set TRANS;

/*PARAM of TRANS set declaration*/
param hfe {TRANS};
param vbe {TRANS};
param type {TRANS} symbolic;

/*constant param declaration*/
param MAXHFE;
param MAXVBE;

/*constant param of transistor types declaration*/
param pnp_t symbolic;
param npn_t symbolic;

/*subset of TRANS set in function of type of transistor (PNP, NPN) declaration */
set PNP within {TRANS} := {t in TRANS : type[t] == pnp_t};
set NPN within {TRANS} := {t in TRANS : type[t] == npn_t};

/* variable that contains all dipsersion value 
 * for all possible couple of (PNP,NPN) transistors
 * this variable is there just to verify couple by couple our result
 * free to remove/uncomment it from the model*/
var dispersion{p in PNP, n in NPN}:=
  max(abs(vbe[p] - vbe[n])/MAXVBE,abs(hfe[p] - hfe[n])/MAXHFE);

/* binary variable which represents
 * if the given couple of transistors can be paired
 * 1 mean that the couple transistors form a valid peer otherwise 0*/
var affectation{p in PNP,n in NPN} binary;

/*variable that will contains the sum of all 1 binary value in the affectation tab
 * in other words this represent the number possible couple of transistors who respects all the constraints*/
var total_affectation;

/*this variable reprenset the dispersion limit that each peer must respect
 * this is our goal variable that we want to minimize in order to have all transistors in peer*/
var disp;

/*the two followed constraint verify that each transistor can be in only one paired transistors*/

/*maximum cardinality constraint of the sum of each rows of the affectation tab*/
subject to affectation_unique_PNP{p in PNP}:
  sum {n in NPN} affectation[p,n] <= 1;

/*maximum cardinality constraint of the sum of each columns of the affectation tab*/
subject to affectation_unique_NPN {n in NPN}:
  sum {p in PNP} affectation[p,n] <= 1;

/*constraint that verify is we have the value 1 for the couple (p,n) in affectation tab
 * then the dispersion must be < to MAX_DISP. If the value is 0 for the couple then the constraint is
 * always verified due to the multiplication*/
subject to affect_valide_disp{p in PNP, n in NPN}:
  affectation[p,n] * (max(abs(vbe[p] - vbe[n])/MAXVBE,abs(hfe[p] - hfe[n])/MAXHFE)) <= disp;

/*to obtain the goal variable we do the sum of all the value (1 or 0) for all couple (p,n) transistors
 * in the affectation tab. We use a <= because want to maximize the goal variable*/
subject to sum_affectation:
  total_affectation <= sum {p in PNP, n in NPN} affectation[p,n];

/* constraint for the cardinality of total_affectation which must be equal to 16
 * in our context of data
 * then the maximum possible peer without taking in account the dispersion limit
 * this is why we do the min between card of pnp and npn*/ 
subject to total_affectation_must_max_possible_peer:
  total_affectation == min(card(PNP),card(NPN));

/*maximum dispersion constraint where max of a dispersion is 1 and min 0 */
subject to disp_borne:
  0 <= disp <= 1;

/*the goal is to maximize the possible paired transistors 
 * that verify all the given constraints*/
minimize dispersion_for_maximum_peer:
  disp;

/*load data from ../data/ folder*/
data "../data/transistors_q6.dat"

/*solve the model*/
solve;

/*display the value of goal variable*/
display disp;

/*display the total affectation which must be 16 in this context*/
display total_affectation;

/*display the dipersion of all possible peers of transistors*/
/*display dispersion;*/

/*display the binary value for the all possible peers of transistors*/
display affectation;
