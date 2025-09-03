#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import the module
include { TRANSCRIPT_ANNOTATION } from './main'

workflow {
    // Define input channel with test data
    input_ch = Channel.of([
        [id: 'test_sample'],
        file("${projectDir}/test_data/BambuOutput_counts_transcript.txt"),
        file("${projectDir}/test_data/BambuOutput_counts_gene.txt"),
        file("${projectDir}/test_data/BambuOutput_extended_annotations.gtf")
    ])

    // Run the transcript annotation process
    TRANSCRIPT_ANNOTATION(input_ch)

    // Access and display outputs
    TRANSCRIPT_ANNOTATION.out.transcriptome_metadata.view { meta, file ->
        "✅ Transcriptome metadata for ${meta.id}: ${file}"
    }

    TRANSCRIPT_ANNOTATION.out.lncrna_metadata.view { meta, file ->
        "✅ lncRNA metadata for ${meta.id}: ${file}"
    }

    TRANSCRIPT_ANNOTATION.out.protein_coding_metadata.view { meta, file ->
        "✅ Protein-coding metadata for ${meta.id}: ${file}"
    }

    TRANSCRIPT_ANNOTATION.out.annotated_transcriptome_gtf.view { meta, file ->
        "✅ Annotated transcriptome GTF for ${meta.id}: ${file}"
    }

    TRANSCRIPT_ANNOTATION.out.annotated_tx_counts.view { meta, file ->
        "✅ Annotated transcript counts for ${meta.id}: ${file}"
    }

    TRANSCRIPT_ANNOTATION.out.versions.view { file ->
        "✅ Software versions: ${file}"
    }
}