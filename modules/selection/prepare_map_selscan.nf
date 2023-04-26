process PREPARE_MAP_SELSCAN{

    tag { "splitting_by_chrom" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/genetic_map/", mode:"copy")

    input:
        tuple val( chrom ), path( vcf )

    output:
        tuple val( chrom ), path ( "${chrom}.map" ), emit: chrom_geneticMap

    script:

        def cm_to_bp = params.cm_to_bp //defaul is 1000000
        
        """
                        

         zcat ${vcf}|awk '\$0!~/#/{sum++;print \$1,"locus"sum,\$2/${cm_to_bp},\$2}' > ${chrom}.map


        """ 
}
