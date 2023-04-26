include { REMOVE_RELATED_INDI } from '../modules/plink/remove_related_indi'
include { REMOVE_CUSTOM_INDI as REMOVE_INDI_ALL_ANALYSIS } from '../modules/plink/remove_custom_indi'
include { REMOVE_CUSTOM_SNPS as REMOVE_SNPS_ALL_ANALYSIS } from '../modules/plink/remove_custom_snps'
include { APPLY_MISSING_MAF_FILTERS } from '../modules/plink/apply_missing_maf_filters'

workflow FILTER_BED {
    take:
        bed
    
    main:
	if( params.checkRelatedness == "TRUE" ){
        	removedRelaIndi = REMOVE_RELATED_INDI(bed)
		bedFilter1 = removedRelaIndi.rmRelaIndiBed
	}
	else{
		bedFilter1 = bed
	}
	if( params.removeIndiAllAnalysis != "NA" ){
		indiList = Channel.fromPath(params.removeIndiAllAnalysis)
        	removedCustIndi = REMOVE_INDI_ALL_ANALYSIS(bedFilter1, indiList)
		bedFilter2 = removedCustIndi.remCustIndiBed
	}
	else{
		bedFilter2 = bedFilter1
	}
	if(params.removeSnpsAllAnalysis != "NA"){
        	removedCustSnps = REMOVE_SNPS_ALL_ANALYSIS(bedFilter2)
		bedFilter3 = removedCustSnps.remCustSnpsBed
	}
	else{
		bedFilter3 = bedFilter2
	}
        appliedMissMafFilters = APPLY_MISSING_MAF_FILTERS(bedFilter3)
	bedFilter4 = appliedMissMafFilters.filtMissMafBed

   emit:
	bedFilter4 = bedFilter4

}
