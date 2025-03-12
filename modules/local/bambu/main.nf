process BAMBU {
    tag "Running Bambu"
    label 'process_medium'

    // Note: the versions here need to match the versions used in the mulled container below and minimap2/index
    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://lfreitasl/bambu:3.8.0':
        'docker.io/lfreitasl/bambu:3.8.0' }"

    input:
    val bam_list
    val reference
    val annotation
    val sample_info


    output:

    path "versions.yml"                                  , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:

    """
    bambu.R \\
        -g $reference \\
        -a $annotation \\
        -b $bam_list \\
        -n $task.cpus \\
        -s $sample_info \\
        -o .


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bambu: \$(Rscript -e "packageVersion('bambu')" | sed "s/\\[1\\] ‘\\([0-9.]*\\)’/\\1/")
    END_VERSIONS
    """

    stub:

    """
    touch $output_file

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bambu: \$(Rscript -e "packageVersion('bambu')" | sed "s/\\[1\\] ‘\\([0-9.]*\\)’/\\1/")
    END_VERSIONS
    """
}
