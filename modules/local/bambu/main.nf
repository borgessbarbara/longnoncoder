process MINIMAP2_ALIGN {
    tag "$meta.id"
    label 'process_medium'

    // Note: the versions here need to match the versions used in the mulled container below and minimap2/index
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:3161f532a5ea6f1dec9be5667c9efc2afdac6104-0' :
        'biocontainers/mulled-v2-66534bcbb7031a148b13e2ad42583020b9cd25c4:3161f532a5ea6f1dec9be5667c9efc2afdac6104-0' }"

    input:
    val bam_list
    val reference
    val annotation


    output:
    
    path "versions.yml"                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    bambu.R \\
        -g $reference \\
        -a $annotation \\
        -b $bam_list \\
        -n $task.cpus


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bambu: \$(Rscript -e "packageVersion('bambu')" | sed "s/\[1\] ‘\([0-9.]*\)’/\1/")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    def output_file = bam_format ? "${prefix}.sorted.bam" : "${prefix}.paf"
    def bam_input = "${reads.extension}".matches('sam|bam|cram')
    def target = reference ?: (bam_input ? error("BAM input requires reference") : reads)

    """
    touch $output_file

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bambu: \$(Rscript -e "packageVersion('bambu')" | sed "s/\[1\] ‘\([0-9.]*\)’/\1/")
    END_VERSIONS
    """
}
