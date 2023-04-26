process CALC_TAJIMA_D{

    tag { "calculating_tajima_d" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/${prefix}/", mode:"copy")

    input:
        tuple val(prefix), path(vcfIn), val(pop), path(fileSampleId)

    output:
        tuple val(pop), path ("${pop}.${prefix}.${windowSize}*"), emit: tajimaD_out

    script:
        
        windowSize = params.windowSize

        """

        vcftools --gzvcf ${vcfIn} --keep ${fileSampleId} --TajimaD ${windowSize} --out ${pop}.${prefix}.${windowSize}

        """ 
}
