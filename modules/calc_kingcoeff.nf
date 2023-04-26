process CALC_KINGCOEFF{

	tag { "calculating_kingcoeff" }
	label "oneCpu"
        conda "${baseDir}/environment.yml"
        container "maulik23/scalepopgen:0.1.1"
        publishDir("${params.outDir}/keep_indi_list", mode:"copy")

	input:
	    file(bed)

	output:
		path("*fastindep.in"), emit: fastindep_in
                path("*.kingcoeff.txt"), emit: kingcoeff_out

	when:
		task.ext.when == null || task.ext.when
	
    script:

        prefix = params.prefix
        def o_prefix = bed[0].baseName
	def max_chrom = params.max_chrom+1

        """
        awk '{print \$1"_"\$2}' ${o_prefix}.fam > indi.id
        
        king -b ${o_prefix}.bed --kinship --degree 0 --prefix ${prefix} --sexchr ${max_chrom}

        awk 'NR==FNR{print \$1"_"\$2,\$3"_"\$4,\$8;next}FNR!=1{print \$1"_"\$2,\$1"_"\$3,\$9}' ${prefix}.kin0 ${prefix}.kin > ${prefix}.kingcoeff.txt

        python3 ${baseDir}/bin/prepareFastindepInput.py ${prefix}.kingcoeff.txt indi.id ${prefix}.fastindep.in

        """

}
