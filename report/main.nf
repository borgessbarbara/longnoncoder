process RENDER_REPORT {

    tag "Rendering report"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ? 'oras://community.wave.seqera.io/library/quarto_r-cowplot_r-knitr_r-rcolorbrewer_pruned:9183d70916f57fd4' : 'community.wave.seqera.io/library/quarto_r-cowplot_r-knitr_r-rcolorbrewer_pruned:a02cb51064eb0c90'}"

    input:
        path(notebook)

        // bambu outputs
        path(counts_genes)
        path(counts_transcript)
        path(fl_counts_transcript)
        path(u_counts_transcript)

        // metadata csv tables
        path(transcriptome_meta)
        path(protein_coding_meta)
        path(lncrna_meta)
        path(protein_coding_exonlength)
        path(lncrna_exonlength)
        path(novel_lncrna_meta)
        path(novel_lncrna_length)
        path(novel_protein_coding_length)

        // plots
        path(plot_heatmap_gene)
        path(plot_heatmap_tcpt)
        path(plot_pca_grouped)
        path(plot_pca)

    output:
        path("*.html")                      , emit: report
        path("Bambu_assembly_summary.csv")  , emit: bambu_assembly_summary
        // path("*.png")                       , emit: generated_plots_png
        // path("*.pdf")                       , emit: generated_plots_pdf

    when:
        task.ext.when == null || task.ext.when

    script:
        """
        cp ${notebook} report.qmd
        quarto render report.qmd \\
            -P counts_genes:${counts_genes} \\
            -P counts_transcript:${counts_transcript} \\
            -P fl_counts_transcript:${fl_counts_transcript} \\
            -P u_counts_transcript:${u_counts_transcript} \\
            -P transcriptome_meta:${transcriptome_meta} \\
            -P protein_coding_meta:${protein_coding_meta} \\
            -P lncrna_meta:${lncrna_meta} \\
            -P protein_coding_exonlength:${protein_coding_exonlength} \\
            -P lncrna_exonlength:${lncrna_exonlength} \\
            -P novel_lncrna_meta:${novel_lncrna_meta} \\
            -P novel_lncrna_length:${novel_lncrna_length} \\
            -P novel_protein_coding_length:${novel_protein_coding_length} \\
            -P plot_heatmap_gene:${plot_heatmap_gene} \\
            -P plot_heatmap_tcpt:${plot_heatmap_tcpt} \\
            -P plot_pca_grouped:${plot_pca_grouped} \\
            -P plot_pca:${plot_pca} \\
            --to html
        """
    stub:
        """
        touch report.html
        touch Bambu_assembly_summary.csv
        touch generated_plot.png
        touch generated_plot.pdf
        """

}


// Default parameters for workflow execution
params.outdir                       = './results'
params.notebook                     = 'template/report_template.qmd'

// Bambu outputs
params.counts_genes                 = 'inputs/BambuOutput_counts_gene_validated.txt'
params.counts_transcript            = 'inputs/BambuOutput_counts_transcript_validated.txt'
params.fl_counts_transcript         = 'inputs/BambuOutput_fullLengthCounts_transcript_validated.txt'
params.u_counts_transcript          = 'inputs/BambuOutput_uniqueCounts_transcript_validated.txt'

// Metadata CSV tables
params.transcriptome_meta           = 'inputs/annotated_transcriptome_metadata.csv'
params.protein_coding_meta          = 'inputs/annotated_protein-coding_metadata.csv'
params.lncrna_meta                  = 'inputs/annotated_lncRNAs_metadata.csv'
params.protein_coding_exonlength    = 'inputs/annotated_protein-coding_exonlength.csv'
params.lncrna_exonlength            = 'inputs/annotated_lncRNAs_exonlength.csv'
params.novel_lncrna_meta            = 'inputs/novel_pc_lnc_RNAs_metadata.csv'
params.novel_lncrna_length          = 'inputs/novel_lncRNA_exon_lengths.csv'
params.novel_protein_coding_length  = 'inputs/novel_protein-coding_exon_lengths.csv'

// Plots
params.plot_heatmap_gene            = 'inputs/heatmap_gene.png'
params.plot_heatmap_tcpt            = 'inputs/heatmap_transcript.png'
params.plot_pca_grouped             = 'inputs/pca_grouped.png'
params.plot_pca                     = 'inputs/pca.png'

workflow {

    RENDER_REPORT(
        file(params.notebook),
        file(params.counts_genes),
        file(params.counts_transcript),
        file(params.fl_counts_transcript),
        file(params.u_counts_transcript),
        file(params.transcriptome_meta),
        file(params.protein_coding_meta),
        file(params.lncrna_meta),
        file(params.protein_coding_exonlength),
        file(params.lncrna_exonlength),
        file(params.novel_lncrna_meta),
        file(params.novel_lncrna_length),
        file(params.novel_protein_coding_length),
        file(params.plot_heatmap_gene),
        file(params.plot_heatmap_tcpt),
        file(params.plot_pca_grouped),
        file(params.plot_pca)
    )

}
