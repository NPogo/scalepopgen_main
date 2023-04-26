process CONVERT_VCF_TO_BED{

    tag { "converting_vcf_to_bed_${chrom}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"

    input:
        tuple val(chrom), file(vcf_file)

    output:
        path("${chrom}.{bed,bim,fam}"), emit: bed

    when:
        task.ext.when == null || task.ext.when

    script:
        def opt_arg = ""
        opt_arg = opt_arg + " --chr-set "+ params.max_chrom

	if( params.allow_extra_chrom ){
                
            opt_arg = opt_arg + " --allow-extra-chr "

            }

        opt_arg = opt_arg + " --const-fid --make-bed "

        """
	plink --vcf ${vcf_file} ${opt_arg} --out ${chrom}

        awk 'BEGIN{OFS="\t"}{\$2=\$1"_"\$4;print}' ${chrom}.bim > ${chrom}.1.bim

        mv ${chrom}.1.bim ${chrom}.bim

        """ 
}
