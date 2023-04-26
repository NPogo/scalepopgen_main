include { CALC_PIHAT } from '../modules/plink/calc_pihat'
include { CALC_KINGCOEFF } from '../modules/calc_kingcoeff'
include { RUN_FASTINDEP } from '../modules/run_fastindep'
include { CALC_MISSINGNESS } from '../modules/plink/calc_missingness'
include { PREPARE_NEW_MAP } from '../modules/prepare_new_map'


workflow PREPARE_KEEP_INDI_LIST{
    take:
        bed
    main:
        if( params.mind > 0 || params.rem_indi != "none" ){
                CALC_MISSINGNESS( bed )
                filt_bed = CALC_MISSINGNESS.out.missigness_filt_bed
                indi_list = CALC_MISSINGNESS.out.keep_indi_list
            }
        else{
                filt_bed = bed
            }
        if( params.rel_coeff_cutoff > 0 ){
            if( params.rel_coeff == "pihat" ){
                    calc_rel_out = CALC_PIHAT(filt_bed)
                }
            else{
                calc_rel_out = CALC_KINGCOEFF(filt_bed)
                }
        
            RUN_FASTINDEP( calc_rel_out.fastindep_in, filt_bed )
            n1_indi_list = RUN_FASTINDEP.out.unrel_indi_id
            }
        else{
            n1_indi_list = indi_list
            }
        PREPARE_NEW_MAP(filt_bed, n1_indi_list)
    
   emit:
	indi_list = n1_indi_list
        new_map = PREPARE_NEW_MAP.out.new_map
}
