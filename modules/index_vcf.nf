process INDEX_VCF{

    tag { "filter_sites_${chrom}" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/vcf_filtering/", mode:"copy")

    input:
        tuple val(chrom), path(vcf)

    output:
        tuple val(chrom), path ("*.tbi"), emit: idx_vcf
    
    script:

        """
        
        tabix ${vcf}


        """ 
}
