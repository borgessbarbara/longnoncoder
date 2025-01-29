//
// MODULE: Local to the pipeline
//
include { MINIMAP2_ALIGN                  } from '../../modules/local/minimap2/align/main'
include { SAMTOOLS_VIEW as MAPPED         } from '../../modules/local/samtools/view/main'
include { SAMTOOLS_VIEW as UNMAPPED       } from '../../modules/local/samtools/view/main'
include { SAMTOOLS_VIEW as TOTAL          } from '../../modules/local/samtools/view/main'
include { SAMTOOLS_VIEW as PRIMARY        } from '../../modules/local/samtools/view/main'

/*
========================================================================================
    RUN ALIGNMENT WORKFLOW
========================================================================================
*/

workflow ALIGNMENT {
   take:
       reads     
    
   main:
    ch_versions     = Channel.empty()
    ch_bam          = Channel.empty()
    ch_index        = Channel.empty()
    ch_alignment_qc = Channel.empty()
    ch_reference    = Channel.empty()

  // Building metamap for the reference
    Channel
    .fromPath(params.reference) // Replace with your file pattern
    .map { file_path ->
        def basename = file_path.baseName  // Extract the base name
        [basename, file_path.toString()]  // Create the tuple
    }
    .collect()
    .set {ch_reference}
  // Alignment with the minimap2 module in case no filtering is applied to read length

        MINIMAP2_ALIGN (
        reads,
        ch_reference,
        params.bam_format,
        params.cigar_paf_format,
        params.cigar_bam
        )

        MINIMAP2_ALIGN.out.bam
            .set{ ch_bam }

        ch_versions = ch_versions.mix(MINIMAP2_ALIGN.out.versions.first().ifEmpty(null))

        if (!params.skip_alignment_qc){

            MAPPED(
                ch_bam,
                [[],[]],
                []
            )

            UNMAPPED(
                ch_bam,
                [[],[]],
                []
            )

            TOTAL(
                ch_bam,
                [[],[]],
                []
            )

            PRIMARY(
                ch_bam,
                [[],[]],
                []
            )

            ch_versions = ch_versions.mix(MAPPED.out.versions.first().ifEmpty(null))
        }

   emit:
   index = ch_index
   bam = ch_bam
   reference = ch_reference
   versions = ch_versions
}