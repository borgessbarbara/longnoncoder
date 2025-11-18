//
// MODULE: Local to the pipeline
//
include { GFFCOMPARE             } from '../../modules/local/gffcompare/main'
include { GFFREAD                } from '../../modules/local/gffread/main'
include { RNAMINING              } from '../../modules/local/rnamining/main'

/*
========================================================================================
    RUN CLASSIFICATION_POTENTIAL_CODING WORKFLOW
========================================================================================
*/

workflow CLASSIFICATION_POTENTIAL_CODING {
   take:
       gtf
       annotation 
       reference    
    
   main:
    ch_versions       = Channel.empty()
    ch_annotated_gtf  = Channel.empty()
    ch_tmap           = Channel.empty()
    ch_predictions    = Channel.empty()

    // Classification and potential coding of transcripts in the resulting GTF

    GFFCOMPARE(
        gtf,
        annotation
    )

    ch_annotated_gtf = ch_annotated_gtf.mix(GFFCOMPARE.out.annotated_gtf)
    ch_tmap          = ch_tmap.mix(GFFCOMPARE.out.tmap)
    ch_versions      = ch_versions.mix(GFFCOMPARE.out.versions)

    GFFREAD(
        gtf,
        reference
    )
    
    ch_versions = ch_versions.mix(GFFREAD.out.versions)

    RNAMINING(
        GFFREAD.out.gtf_fasta
    )
    ch_predictions = ch_predictions.mix(RNAMINING.out.preds)

   emit:
    annotated_gtf  = ch_annotated_gtf
    tmap           = ch_tmap
    predictions    = ch_predictions
    versions       = ch_versions
}