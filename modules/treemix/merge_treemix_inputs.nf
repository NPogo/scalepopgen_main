process MERGE_TREEMIX_INPUTS{

    tag { "merging_treemix_inputs" }
    label "oneCpu"
    conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"
    publishDir("${params.outDir}/treemix", mode:"copy")

    input:
        path(treemix_inputs)

    output:
        path("merged_treemix_input.gz"), emit: merged_treemix_input

    when:
        task.ext.when == null || task.ext.when

    script:



        """

        cat ${treemix_inputs} | awk '{if(NR==1){print;next}else;if(\$0~/,/){print}}'|gzip -c > merged_treemix_input.gz

        """ 
}
