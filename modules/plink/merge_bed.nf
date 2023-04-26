process MERGE_BED{

    tag { "merging_bed_${prefix}" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir( "${params.outDir}/final_plink_files/" , mode:"copy")

    input:
        file(bed)
        val(bed_prefix)
        file(sample_map)

    output:
        path("${prefix}.{bed,bim,fam}"), emit: merged_bed

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
        
        """
        for ele in $bed_prefix; do echo \$ele"\n";done >> prefix_list.txt
    
        sed -i 's/\\[\\|\\]\\|\\,//g' prefix_list.txt
        
        awk 'NF != 0{print}' prefix_list.txt > prefix_list.1.txt         

	plink ${opt_arg} --merge-list prefix_list.1.txt --make-bed --out ${prefix}

        awk 'NR==FNR{pop[\$1]=\$2;next}{\$1=pop[\$2];print}' ${sample_map} ${prefix}.fam > ${prefix}.1.fam

        rm ${prefix}.fam

        mv ${prefix}.1.fam ${prefix}.fam

        """ 
}
