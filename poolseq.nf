#!/usr/bin/env nextflow
params.genomedir=null

fasta_ch = Channel.fromPath("$params.genomedir/*.fa")
gtf_ch = Channel.fromPath("$params.genomedir/*.gtf")
genome_ch=Channel.from("genome")

process index {

    //input:
    //path fasta from fasta_ch
    //path gtf from gtf_ch
    //val name from genome_ch

    script:
    """
    STAR --version
    """

}


