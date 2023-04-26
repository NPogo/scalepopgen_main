/* 
* first split by chromosome and then carry out phasing based on the user defined tool, either beagle5.2 or shapeit4
*/

include { VCF_TO_TREEMIXINPUT } from "${baseDir}/modules/selection/"
include { RUN_TREEMIX_NO_BOOTSTRAP } from "../modules/treemix/run_treemix_no_bootstrap"
include { RUN_TREEMIX_WITH_BOOTSTRAP } from "../modules/treemix/run_treemix_with_bootstrap"
include { RUN_CONSENSE } from "../modules/phylip/run_consense"
include { ADD_MIGRATION_EDGES } from "../modules/treemix/add_migration_edges"
include { EST_OPT_MIGRATION_EDGE } from "../modules/treemix/est_opt_migration_edge"


def generateRandomNum(numBootstrap, upperLimit){
	randomNumTuple = []
	int numBoot = numBootstrap
	int upperLim = upperLimit
	while (randomNumTuple.size()<numBootstrap){
    		int j = (Math.abs(new Random().nextInt() % upperLimit) + 1)
    		if(!(randomNumTuple.contains(j))){
        		randomNumTuple.add(j)
    		}
	}
	return randomNumTuple
}


workflow RUN_TREEMIX {
    take:
        vcf
        id
    main:
        treemixInput = VCF_TO_TREEMIXINPUT(vcf, id)
        RUN_TREEMIX_NO_BOOTSTRAP(treemixInput)
        if ( !params.skip_bootstrapping ){
            randomNumTuple = generateRandomNum(params.numBootstrap, params.upperLimit)
            treemixInputNumT = treemixInput.combine(randomNumTuple)
            bootstrappedTrees = RUN_TREEMIX_WITH_BOOTSTRAP(treemixInputNumT)
            RUN_CONSENSE(bootstrappedTrees.treeout.collect())
        }
        if (params.starting_m_value > 0){
            mValue = Channel.from(params.starting_m_value..params.ending_m_value)
            treemixInputTuple = mValue.combine(treemixInput)
            itrValue = Channel.from(1..params.maxIter)
            itrMigTreemixInputTuple = itrValue.combine(treemixInputTuple)
            migOut = ADD_MIGRATION_EDGES( itrMigTreemixInputTuple)
            EST_OPT_MIGRATION_EDGE( migOut.llik.collect(), migOut.modelcov.collect(), migOut.cov.collect())
        }
}
