include { BAMBU } from '../../modules/local/bambu/main'

workflow TRANSCRIPT_RECONSTRUCTION {
    take:
        bams
        reference
        annotation

    main:
    ch_versions              = Channel.empty()
    ch_bamlist               = Channel.empty()
    ch_samp_info             = Channel.empty()
    ch_reference             = Channel.empty()
    ch_annotation            = Channel.empty()
    ch_assembled_new_gtf     = Channel.empty()
    ch_assembled_all_gtf     = Channel.empty()
    ch_unique_counts         = Channel.empty()
    ch_tx_counts             = Channel.empty()
    ch_gene_counts           = Channel.empty()
    ch_CPM                   = Channel.empty()
    ch_full_length           = Channel.empty()
    ch_pca                   = Channel.empty()
    ch_pca_grouped           = Channel.empty()
    ch_h_transcript          = Channel.empty()
    ch_h_gene                = Channel.empty()
    ch_multiqc_all           = Channel.empty()

    

    // Setting channel for the reference
    ch_reference  = Channel.fromPath(reference, checkIfExists: true)
    ch_annotation = Channel.fromPath(annotation, checkIfExists: true)

     
    //Channel
    //.fromPath(reference) // Replace with your file pattern
    //.set {ch_reference}

    // Setting channel for the annotation
    //Channel
    //.fromPath(annotation) // Replace with your file pattern
    //.set {ch_annotation}

    // Setting TSV file with sample information
    bams
        .map { meta, path -> [meta.cell_line, path.getName()] }
        .collectFile(newLine: true) { item ->
            [ "${item[0]}.txt", item[0] + '\t' + item[1] ]
        }
        .collectFile(name: 'sampinfo_samplesheet.tsv')
        .set { ch_samp_info }


    // Setting up the BAM list
    bams
        .map { meta, path -> [meta.cell_line, path.toString()] }
        .collectFile(newLine: true) { item ->
        ["${item[0]}.txt", item[1]]
        }
        .collectFile(name: 'bamlist.txt')
        .set { ch_bamlist }


    BAMBU (
        ch_bamlist,
        ch_reference,
        ch_annotation,
        ch_samp_info
    )

    BAMBU.out.gtf_new_transcripts
        .set { ch_assembled_new_gtf }

    BAMBU.out.gtf_all_transcripts
        .set { ch_assembled_all_gtf }

    BAMBU.out.gene_counts
        .set { ch_gene_counts }

    BAMBU.out.tx_counts
        .set { ch_tx_counts }
    
    BAMBU.out.CPM
        .set { ch_CPM }
    
    BAMBU.out.full_length
        .set { ch_full_length }

    BAMBU.out.unique_counts
        .set { ch_unique_counts }
    
    BAMBU.out.h_gene
        .set { ch_h_gene }

    BAMBU.out.h_transcript
        .set { ch_h_transcript }

    BAMBU.out.pca
        .set { ch_pca }

    BAMBU.out.pca_grouped
        .set { ch_pca_grouped }

    ch_versions = ch_versions.mix(BAMBU.out.versions.first().ifEmpty(null))


    emit:
    //multiqc = ch_multiqc_all
    versions            = ch_versions
    pca                 = ch_pca
    pca_grouped         = ch_pca_grouped
    h_gene              = ch_h_gene
    h_transcript        = ch_h_transcript
    CPM                 = ch_CPM
    full_length         = ch_full_length
    transcript_counts   = ch_tx_counts
    gene_counts         = ch_gene_counts
    gtf_new_transcripts = ch_assembled_new_gtf
    gtf_all_transcripts = ch_assembled_all_gtf
    unique_counts       = ch_unique_counts
    bamlist             = ch_bamlist
    samp_info           = ch_samp_info
    reference           = ch_reference
    annotation          = ch_annotation
}
