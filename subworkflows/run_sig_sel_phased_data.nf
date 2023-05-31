/* 
* workflow to carry out signature of selection (single population vs multi-population)
*/

include { PHASING_GENOTYPE_BEAGLE } from '../modules/selection/phasing_genotpyes_beagle'
//include { CHECK_INPUT as CHECK_MAP } from '../subworkflows/check_input'
//include { CHECK_INPUT as CHECK_ANC } from '../subworkflows/check_input'
//include { PREPARE_MAP_SELSCAN } from '../modules/selection/prepare_map_selscan'
//include { CALC_iHS } from '../modules/selscan/calc_ihs'
//incldue { CALC_NSL } from '../modules/selection/calc_nsl'


workflow RUN_SIG_SEL_PHASED_DATA{
    take:
        chrom_vcf_idx_popfile

    main:

        ///phase chromsome-wise splitted vcf file///
        //prepare input for phasing_genotpyes_beagle//

        chrom_vcf = chrom_vcf_idx_popfile.map{ chrom, vcf, pop, idFile -> tuple(chrom,vcf) }.unique()

        
        //phase genotypes in vcf files using beagle
        PHASING_GENOTYPE_BEAGLE( chrom_vcf )

        ///run iHs and nSL analysis///

        // keep unique id file //
        
        /*
        pop_idFile = chrom_vcf_pop_idFile.map{ chrom, vcf, pop, idFile -> tuple(pop, idFile) }.unique()

        //pop_idFile.view()

        // import genetic map files, the suffix should be the same as that of the vcf file e.g. chr21.vcf.gz chr21.vcf.map

        if( params.genetic_map == "none" ){
                        
            PREPARE_MAP_SELSCAN( chrom_vcf )

            chrom_map = PREPARE_MAP_SELSCAN.out.chrom_geneticMap

        }


        else{

            CHECK_MAP( params.genetic_map )

            chrom_map = CHECK_INPUT.out.chrom_file

        }
        
        chrom_vcf_map = PHASING_GENOTYPE_BEAGLE.out.phased_vcf.combine( chrom_map, by:0 )

        // import ancestral alleles files

        if( params.input_anc != "none" ){

            chrom_anc = CHECK_ANC( params.input_anc )

        // prepare input for CALC_iHS module

            chrom_vcf_map_anc            = chrom_vcf_map.combine( chrom_anc, by:0 )
            chrom_vcf_map_anc_pop_idFile = chrom_vcf_map_anc.combine(pop_idFile)

        }

        else{
            
            chrom_vcf_map_pop_idFile = chrom_vcf_map.combine(pop_idFile)

            chrom_vcf_map_anc_pop_idFile = chrom_vcf_map_pop_idFile.map{ chrom, vcf, mapF, pop, idFile -> tuple(chrom, vcf, mapF, [], pop, idFile)}

        }

        
        // Run CALC_iHS module

        CALC_iHS( chrom_vcf_map_anc_pop_idFile )

        

        //phasing_genotpyes_beagle_out.view()
        
        //pop_file_chrom_phased_T = pop_file_tuple.combine(phasing_genotpyes_beagle_out)
        //split_phased_vcf_by_pop_out = SPLIT_PHASED_VCF_BY_POP(pop_file_chrom_phased_T)
        */
}
