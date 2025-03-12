include { BAMBU } from '../../modules/local/bambu/main'

workflow TRANSCRIPT_RECONSTRUCTION {
    take:
        bams
        reference
        annotation

    main:
    ch_versions          = Channel.empty()
    ch_bamlist           = Channel.empty()
    ch_samp_info         = Channel.empty()
    ch_reference         = Channel.empty()
    ch_annotation        = Channel.empty()
    ch_multiqc_all       = Channel.empty()

    // Setting channel for the reference
    Channel
    .fromPath(reference) // Replace with your file pattern
    .set {ch_reference}

    // Setting channel for the annotation
    Channel
    .fromPath(annotation) // Replace with your file pattern
    .set {ch_annotation}

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


    emit:
    //multiqc = ch_multiqc_all
    //versions = ch_versions
    bamlist = ch_bamlist
    samp_info = ch_samp_info
    reference = ch_reference
    annotation = ch_annotation
}
