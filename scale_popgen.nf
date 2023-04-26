#!/usr/bin/env nextflow

nextflow.enable.dsl=2


/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/


//include { CONVERT_PED_TO_BED } from "${baseDir}/modules/plink/convert_ped_to_bed"

//include { CONVERT_BED_TO_VCF } from "${baseDir}/modules/plink/convert_bed_to_vcf"

//include { SPLIT_IDFILE_BY_POP } from "${baseDir}/modules/selection/split_idfile_by_pop"

//include { SPLIT_VCF_BY_CHROM } from "${baseDir}/modules/selection/split_vcf_by_chrom"




//
// SUBWORKFLOW: Consisting of a mix of local modules
//

include { CHECK_INPUT } from "${baseDir}/subworkflows/check_input"

include { PREPARE_KEEP_INDI_LIST  } from "${baseDir}/subworkflows/prepare_keep_indi_list"

include { FILTER_VCF } from "${baseDir}/subworkflows/filter_vcf"

//include { FILTER_BED } from "${baseDir}/subworkflows/filter_bed"

//include { PREPARE_BED_REPORT } from "${baseDir}/subworkflows/prepare_bed_report"

include { EXPLORE_GENETIC_STRUCTURE } from "${baseDir}/subworkflows/explore_genetic_structure"

include { CONVERT_VCF_TO_PLINK } from "${baseDir}/subworkflows/convert_vcf_to_plink"

include { CONVERT_VCF_TO_PLINK as CONVERT_FILTERED_VCF_TO_PLINK } from "${baseDir}/subworkflows/convert_vcf_to_plink"

include { RUN_TREEMIX } from "${baseDir}/subworkflows/run_treemix"

//include { RUN_FSTATS } from "${baseDir}/subworkflows/run_fstats"

//include { RUN_PAIRWISE_FST } from "${baseDir}/subworkflows/run_pairwise_fst"

//include { RUN_SIG_SELECTION } from "${baseDir}/subworkflows/run_sig_selection"



workflow{

        
        // check input vcfsheet i.e. if vcf file exits //
    	
        CHECK_INPUT(
            params.input
        )


        // check sample map file i.e. if map file exists //

    samplesheet = Channel.fromPath( params.sample_map )

    map_file = samplesheet.map{ samplesheet -> if(!file(samplesheet).exists()){ exit 1, "ERROR: file does not exit \
            -> ${samplesheet}" }else{samplesheet} }

    
    // combine channel for vcf and sample map file //

    chrom_vcf_idx_map = CHECK_INPUT.out.chrom_vcf_idx.combine(map_file)



    // convert vcf to plink and get the ids of unrelated animals

    if( params.rel_coeff_cutoff > 0 || params.mind > 0 || params.rem_indi != "none" ){

        CONVERT_VCF_TO_PLINK( chrom_vcf_idx_map )

        PREPARE_KEEP_INDI_LIST( CONVERT_VCF_TO_PLINK.out.bed )

        chrom_vcf_idx = chrom_vcf_idx_map.map{chrom, vcf, idx, map -> tuple(chrom, vcf, idx)}

        n1_chrom_vcf_idx_map = chrom_vcf_idx.combine(PREPARE_KEEP_INDI_LIST.out.new_map)

    }
    else{
        n1_chrom_vcf_idx_map = chrom_vcf_idx_map
    }
    
    // prepare input channel for filter vcf    

    chrom_vcf_idx_map_indilist = n1_chrom_vcf_idx_map.combine( ( params.rel_coeff_cutoff > 0 || params.mind > 0 || params.rem_indi != "none" ) ? PREPARE_KEEP_INDI_LIST.out.indi_list : ["none"])

    //chrom_vcf_idx_map_indilist.view()
    
    
    FILTER_VCF(
      chrom_vcf_idx_map_indilist
    )
    
    //FILTER_VCF.out.n2_chrom_vcf_idx_map.view()
    
    if ( params.run_smartpca || params.run_gds_pca || params.admixture ) {
        CONVERT_FILTERED_VCF_TO_PLINK(
            FILTER_VCF.out.n2_chrom_vcf_idx_map
        )
        EXPLORE_GENETIC_STRUCTURE(
            CONVERT_FILTERED_VCF_TO_PLINK.out.bed
        )
    }
    
    if( params.treemix ){
	    RUN_TREEMIX( FILTER_VCF.out.n2_chrom_vcf_idx_map )
        }
}
