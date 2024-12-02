//
// MODULE: Local to the pipeline
//
include { MINIMAP2_ALIGN        } from '../../modules/nf-core/minimap2/align/main'

/*
========================================================================================
    RUN ALIGNMENT WORKFLOW
========================================================================================
*/

workflow ALIGNMENT {
   take:
       reads     
    
   main:
    ch_versions  = Channel.empty()
    ch_bam       = Channel.empty()
    ch_index     = Channel.empty()
    ch_reference = Channel.empty()

  // Building metamap for the reference
    Channel
    .fromPath(params.reference) // Replace with your file pattern
    .map { file_path ->
        def basename = file_path.baseName  // Extract the base name
        [basename, file_path.toString()]  // Create the tuple
    }
    .set {ch_reference}
  // Alignment with the minimap2 module in case no filtering is applied to read length

        MINIMAP2_ALIGN (
        reads,
        ch_reference,
        params.bam_format,
        params.bam_index_extension,
        params.cigar_paf_format,
        params.cigar_bam
        )

        MINIMAP2_ALIGN.out.bam
            .set{ ch_bam }
        MINIMAP2_ALIGN.out.index
            .set{ ch_index }

        ch_versions = ch_versions.mix(MINIMAP2_ALIGN.out.versions.first().ifEmpty(null))

        

   emit:
   index = ch_index
   bam = ch_bam
   reference = ch_reference
   versions = ch_versions
}