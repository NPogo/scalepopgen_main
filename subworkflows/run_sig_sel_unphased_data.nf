/* 
* workflow to carry out signature of selection ( unphased data )
*/

include { CALC_TAJIMA_D } from '../modules/vcftools/calc_tajima_d'
include { CALC_PI } from '../modules/vcftools/calc_pi'
include { SPLIT_IDFILE_BY_POP } from '../modules/selection/split_idfile_by_pop'
include { CALC_WFST } from '../modules/vcftools/calc_wfst'
include { PREPARE_SWEEPFINDER_INPUT } from '../modules/selection/prepare_sweepfinder_input'
include { COMPUTE_EMPIRICAL_AFS } from '../modules/selection/compute_empirical_afs'


/* to do 
*FWH --> always require outgroup
*/



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

        if ( params.clr ){
                if(params.anc_files != "none" ){
                    Channel
                        .fromPath(params.anc_files)
                        .splitCsv(sep:",")
                        .map{ chrom, anc -> if(!file(anc).exists() ){ exit 1, 'ERROR: input anc file does not exist  \
                            -> ${anc}' }else{tuple(chrom, file(anc))} }
                        .set{ chrom_anc }
                    n4_chrom_vcf_popid_anc = n3_chrom_vcf_popid.combine(chrom_anc, by:0)
                }
                else{
                    n4_chrom_vcf_popid_anc = n3_chrom_vcf_popid.combine(["none"])
                }
                
                n5_chrom_vcf_popid_anc = n4_chrom_vcf_popid_anc.map{ chrom, vcf, popid, anc ->tuple( chrom, vcf, popid, anc == "none" ? []: anc)}    

                PREPARE_SWEEPFINDER_INPUT(
                    n5_chrom_vcf_popid_anc
                )

                pop_freq_M = PREPARE_SWEEPFINDER_INPUT.out.pop_freq.groupTuple()

                pop_recomb_M = PREPARE_SWEEPFINDER_INPUT.out.pop_recomb.groupTuple()


                COMPUTE_EMPIRICAL_AFS(
                    pop_freq_M
                )

                freq = pop_freq_M.map{pop, freq -> tuple(freq)}
                
                base_freq = freq.flatten().map{freqF -> tuple(freqF.baseName, freqF ) }
                

                recomb = pop_recomb_M.map{pop, recomb -> tuple(recomb) }

                base_recomb = recomb.flatten().map{ recombF -> tuple(recombF.baseName, recombF ) }

                base_freq_recomb = base_freq.combine( base_recomb, by:0)

                pop_freq_recomb = base_freq_recomb.map{ base, freq, recomb -> tuple(base.split("__")[1], freq, recomb)}

                pop_freq_recomb_afs = pop_freq_recomb.combine(COMPUTE_EMPIRICAL_AFS.out.pop_afs, by:0)

                pop_freq_recomb_afs.view()

    
        }   
}
