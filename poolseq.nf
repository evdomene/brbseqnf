#!/usr/bin/env nextflow
params.genomedir=null

fasta_ch = Channel.fromPath("$params.genomedir/*.fa")
gtf_ch = Channel.fromPath("$params.genomedir/*.gtf")
genome_ch=Channel.from("genome")

process index {
    echo true
    
    input:
    path fasta from fasta_ch
    path gtf from gtf_ch
    val name from genome_ch


    script:
    """
    echo STAR --runMode genomeGenerate --genomeDir $name --genomeFastaFiles $fasta \
    --sjdbGTFfile $gtf --runThreadN $task.cpus
    """



}


