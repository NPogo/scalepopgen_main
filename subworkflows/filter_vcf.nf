/* 
* vcf filtering --> keep related individuals and filter sites based on user-defined criteria
* subworkflow consists of three modules: 
*(i) keep_indi --> keeps the list of unrelated and/or those
*    samples that passed the missingness and/or those samples that were specified by user
*(ii) filter_sites --> filter those sites that does not specify the threshold set by user
*(iii) index_vcf --> indexed the new vcf generated after applying the thresholds described above
*/

include { KEEP_INDI } from "../modules/vcftools/keep_indi"
include { FILTER_SITES } from "../modules/vcftools/filter_sites"
include { INDEX_VCF } from "../modules/index_vcf"



workflow FILTER_VCF {
    take:
        chrom_vcf_idx_map_indilist
    main:
        chrom_mp = chrom_vcf_idx_map_indilist.map{chrom, vcf, idx, mp, indi_list -> tuple(chrom,mp) }
        if( params.rel_coeff_cutoff > 0 || params.mind > 0 ){
            chrom_vcf_indilist = chrom_vcf_idx_map_indilist.map{chrom, vcf, idx, mp, indi_list -> tuple(chrom, vcf, indi_list)}
            KEEP_INDI(
                chrom_vcf_indilist
            )
            n1_chrom_vcf = KEEP_INDI.out.filt_chrom_vcf
        }
        else{            
            n1_chrom_vcf = chrom_vcf_idx_map_indilist.map{chrom, vcf, idx, mp, indi_list -> tuple(chrom, vcf)}
        }   
        if( params.maf > 0 || params.min_meanDP > 0 || params.max_meanDP > 0 || params.hwe > 0 || params.max_missing > 0 || params.minQ > 0 ){
            FILTER_SITES(n1_chrom_vcf)
            n2_chrom_vcf = FILTER_SITES.out.sites_filt_vcf
        }
        else{
            n2_chrom_vcf = n1_chrom_vcf
        }
        chrom_idx = INDEX_VCF(n2_chrom_vcf)
        n2_chrom_vcf_idx = n2_chrom_vcf.combine(chrom_idx, by:0)
        n2_chrom_vcf_idx_map = n2_chrom_vcf_idx.combine(chrom_mp, by:0)
    emit:
        n2_chrom_vcf_idx_map = n2_chrom_vcf_idx_map
}
