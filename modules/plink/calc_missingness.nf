process CALC_MISSINGNESS{

    tag { "calc_missing_${prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/keep_indi_list/", mode:"copy")

    input:
        file(bed)

    output:
        path("*.imiss"), emit: missing_indi_report
        path("${prefix}_after_custom_mind_rem*"), emit: missigness_filt_bed
        path("indi_after_custom_mind_rem.txt"), emit: keep_indi_list

    when:
        task.ext.when == null || task.ext.when

    script:
        prefix = params.prefix
        def max_chrom = params.max_chrom
        def opt_arg = ""
        opt_arg = opt_arg + " --chr-set "+ max_chrom
	if( params.allow_extra_chrom ){
                
            opt_arg = opt_arg + " --allow-extra-chr "

            }

        if ( params.rem_indi != "none" ){
        
            opt_arg = opt_arg + " --remove " + params.rem_indi
        }
        
        if ( params.mind > 0 ){
        
            opt_arg = opt_arg + " --mind " + params.mind
        }

        opt_arg = opt_arg + " --make-bed --missing --out " +prefix+"_after_custom_mind_rem"
        
        """
	
        plink --bfile ${prefix} ${opt_arg}
            
        awk '{print \$2}' ${prefix}_after_custom_mind_rem.fam > indi_after_custom_mind_rem.txt


        """ 
}
