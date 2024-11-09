//
// MODULE: Installed directly from nf-core/modules
//
include { NANOCOMP as NANOCOMP_RAW_VIOLIN   } from '../../modules/local/nanocomp/main'
include { NANOCOMP as NANOCOMP_RAW_BOX      } from '../../modules/local/nanocomp/main'
include { NANOCOMP as NANOCOMP_RAW_RIDGE    } from '../../modules/local/nanocomp/main'
include { NANOCOMP as NANOCOMP_FILT_VIOLIN  } from '../../modules/local/nanocomp/main'
include { NANOCOMP as NANOCOMP_FILT_BOX     } from '../../modules/local/nanocomp/main'
include { NANOCOMP as NANOCOMP_FILT_RIDGE   } from '../../modules/local/nanocomp/main'
include { NANOPLOT as NANOPLOT_RAW          } from '../../modules/nf-core/nanoplot/main'
include { NANOPLOT as NANOPLOT_FILT         } from '../../modules/nf-core/nanoplot/main'
include { CHOPPER } from '../../modules/nf-core/chopper/main'

/*
========================================================================================
    RUN QC_FILT WORKFLOW
========================================================================================
*/


workflow QC_FILT {
    take:
        reads       
     
    main:
     ch_versions          = Channel.empty()
     ch_multiqc_raw       = Channel.empty()
     ch_multiqc_filt      = Channel.empty()
     ch_multiqc_all       = Channel.empty()
     ch_combined_raw      = Channel.empty()
     ch_combined_filtered = Channel.empty()
     ch_reads             = reads

    // Running nanocomp on raw reads
     
     ch_reads
             .collect {it[1]}
             .map {filelist -> [[id:"All"],filelist]}
             .set {ch_combined_raw}
             

     NANOCOMP_RAW_VIOLIN(ch_combined_raw) 
     NANOCOMP_RAW_BOX(ch_combined_raw) 
     NANOCOMP_RAW_RIDGE(ch_combined_raw) 

     ch_versions = ch_versions.mix(NANOCOMP_RAW_VIOLIN.out.versions.first().ifEmpty(null))


    // Running nanoplot on pre-filtered dataset

    NANOPLOT_RAW(ch_reads)

    ch_versions = ch_versions.mix(NANOPLOT_RAW.out.versions.first().ifEmpty(null))

    // Generating a multiqc file for raw reads report

    // ch_multiqc_raw = ch_multiqc_raw.mix(RAW_NANOCOMP.out.zip.collect{it[1]}.ifEmpty([]))
    ch_multiqc_raw = ch_multiqc_raw.mix(NANOPLOT_RAW.out.txt.collect{it[1]}.ifEmpty([]))   
    
    ch_multiqc_all = ch_multiqc_all.mix(ch_multiqc_raw.ifEmpty([]))

    //Putting conditional to whether fun filtering on samples
    if (!params.skip_filtering){

    CHOPPER(ch_reads, [])

    ch_versions = ch_versions.mix(CHOPPER.out.versions.first().ifEmpty(null))
    
    //Running quality check in filtered reads
    CHOPPER.out.fastq
             .collect {it[1]}
             .map {filelist -> [[id:"All"],filelist]}
             .set {ch_combined_filtered}

    NANOCOMP_FILT_VIOLIN(ch_combined_filtered)
    NANOCOMP_FILT_BOX(ch_combined_filtered)
    NANOCOMP_FILT_RIDGE(ch_combined_filtered)

    // Nanoplot
    NANOPLOT_FILT(CHOPPER.out.fastq)

    //ch_multiqc_filt = ch_multiqc_filt.mix(FILT_NANOCOMP.out.zip.collect{it[1]}.ifEmpty([]))
    ch_multiqc_filt = ch_multiqc_filt.mix(NANOPLOT_FILT.out.txt.collect{it[1]}.ifEmpty([]))

    ch_multiqc_all = ch_multiqc_all.mix(ch_multiqc_filt.ifEmpty([]))

    // Putting the output of nano filt as new ch_reads
    ch_reads = CHOPPER.out.fastq
    }

    emit:
    filt_reads = ch_reads
    multiqc = ch_multiqc_all
    versions = ch_versions
}
