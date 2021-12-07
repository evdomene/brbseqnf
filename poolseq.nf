#!/usr/bin/env nextflow
params.genomedir=null

fasta_ch = Channel.fromPath("$params.genomedir/*.fa")
gtf_ch = Channel.fromPath("$params.genomedir/*.gtf")


process index {

    input:
    path fasta from fasta_ch
    path gtf from gtf_ch

    output: 
    path 'genomeindex' into genomeindx_ch
    
    script:
    """
    STAR --runMode genomeGenerate --genomeDir genomeindex --genomeFastaFiles $fasta --sjdbGTFfile $gtf --runThreadN $task.cpus
    """

}



