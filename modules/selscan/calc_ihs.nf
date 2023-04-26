process CALC_iHS{

    tag { "calculating_iHS" }
    label "oneCpu"
    container "maulik23/scalepopgen:0.1.1"
    conda "${baseDir}/environment.yml"
    publishDir("${params.outDir}/selection/${chrom}/", mode:"copy")

    input:
        tuple val(chrom), path(vcf), path(mapF), path(anc), val(pop), path(id)

    output:
        tuple val(pop), path ("${pop}_${chrom}.ihs.anc.out"), emit: iHS_out

    script:
        
        windowSize = params.windowSize
        critPerc   = params.critPerc
        critVal    = params.critVal
        minSnps    = params.minSnps
        numBins    = params.numBins
    
        command = ""

        if ( params.bp_win ){
                command = command + " --bp-win"+ " --winsize "+ windowSize
            }

        else{
                command = command + " --bins "+ numBins
            
            }

        command = command + " --crit-percent "+critPerc+" --crit-val "+critVal+" --min-snps "+ minSnps

        if(anc == [] ){

        """

        vcftools --gzvcf ${vcf} --keep ${id} --recode --stdout |gzip -c > ${pop}_${chrom}.vcf.gz

        selscan --ihs --vcf ${pop}_${chrom}.vcf.gz --map ${mapF} --out ${pop}_${chrom}

        mv ${pop}_${chrom}.ihs.out ${pop}_${chrom}.ihs.anc.out


        """ 
        }
        
        else{

        """
        vcftools --gzvcf ${vcf} --keep ${id} --recode --stdout |gzip -c > ${pop}_${chrom}.vcf.gz

        selscan --ihs --vcf ${pop}_${chrom}.vcf.gz --map ${mapF} --out ${pop}_${chrom}

        awk 'NR==FNR{a[\$2]=\$3;next}{if(a[\$2]==0){iHS=log(\$4/\$5)/log(10)}if(a[\$2]!=0){iHS=log(\$5/\$4)/log(10)}print \$1,\$2,\$3,\$4,\$5,iHS}' \
        
        ${anc} ${pop}_${chrom}.ihs.out > ${pop}_${chrom}.ihs.anc.out

        """

        }
}
