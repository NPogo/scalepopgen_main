/* 
* workflow to carry out signature of selection (single population vs multi-population)
*/

include { CALC_TAJIMA_D } from '../modules/vcftools/calc_tajima_d'
include { CALC_PI } from '../modules/vcftools/calc_pi'
include { SPLIT_IDFILE_BY_POP } from '../modules/selection/split_idfile_by_pop'
include { CALC_WFST } from '../modules/vcftools/calc_wfst'


def PREPARE_DIFFPOP_T( fileListPop ){

        file1 = fileListPop.flatten()
        file2 = fileListPop.flatten()
        filePairs = file1.combine(file2)
        filePairsB = filePairs.branch{ file1Path, file2Path ->

            samePop : file1Path == file2Path
                return tuple(file1Path, file2Path).sort()
            diffPop : file1Path != file2Path
                return tuple(file1Path, file2Path).sort()
        
        }
        return filePairsB.diffPop

}


workflow RUN_SIG_SEL_UNPHASED_DATA{
    take:
        chrom_vcf_idx_map

    main:
        map_f = chrom_vcf_idx_map.map{ chrom, vcf, idx, mp -> mp}.unique()

        n3_chrom_vcf = chrom_vcf_idx_map.map{ chrom, vcf, idx, map -> tuple(chrom, vcf) }

        SPLIT_IDFILE_BY_POP(
            map_f
        )

        pop_idfile = SPLIT_IDFILE_BY_POP.out.splitted_samples.flatten()

        n3_chrom_vcf_popid = n3_chrom_vcf.combine(pop_idfile)



        if( params.tajima_d ){

            CALC_TAJIMA_D( n3_chrom_vcf_popid )
        
        }

        if ( params.pi ){

            CALC_PI( n3_chrom_vcf_popid )

        }

        
        if ( params.pairwise_fst ){
               
               pop1_pop2 = PREPARE_DIFFPOP_T(SPLIT_IDFILE_BY_POP.out.splitted_samples).unique()

               n3_chrom_vcf_pop1_pop2 = n3_chrom_vcf.combine(pop1_pop2)
            
               CALC_WFST( n3_chrom_vcf_pop1_pop2 )
        }
}
