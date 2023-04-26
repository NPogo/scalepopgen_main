process SPLIT_IDFILE_BY_POP{

    tag { "splitting_idfile_by_pop" }
    label "oneCpu"
    //conda "${baseDir}/environment.yml"
    container "maulik23/scalepopgen:0.1.1"

    input:
        path(idFileIn)

    output:
        path ("*.samples.txt"), emit: splitted_samples

    script:
        
        """
        awk '{print \$1 >>\$2".samples.txt"}' ${idFileIn}

        """ 
}
