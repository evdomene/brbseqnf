#!/usr/bin/env nextflow
params.genomedir=null
params.fasta=null
params.barcodes=null
params.results=results

fasta_ch = Channel.fromPath("$params.genomedir/*.fa")
barcodes_ch = Channel.fromPath("$params.barcodes")

Channel
    .fromPath("$params.genomedir/*.gtf")
    .into {gtf_ch; gtf_ch2}

Channel
    .fromFilePairs("$params.fasta/S*R{1,2}*", checkIfExists: true )
    .into {R2_ch ; R1_ch}

process index {

    tag "Indexing $params.genomedir"
    
    input:
    path fasta from fasta_ch
    val gtf from gtf_ch

    output: 
    path 'genomeindex' into genomeindx_ch
    
    script:
    """
    STAR --runMode genomeGenerate --genomeDir genomeindex --genomeFastaFiles $fasta --sjdbGTFfile $gtf --runThreadN $task.cpus
    """

}

process alignment {

    tag "Alignment of $sample_id"
    
    input:
    path index from genomeindx_ch
    tuple val(sample_id),file(reads) from R2_ch
    

    output:
    tuple val(sample_id), file("${sample_id}*.bam") into bam_ch

    script:
    """
    STAR --genomeDir $index  \
    --genomeLoad LoadAndRemove \
    --readFilesIn ${reads[1]} --readFilesCommand zcat \
    --outFileNamePrefix $sample_id \
    --outFilterMultimapNmax 1 \
    --outSAMtype BAM Unsorted \
    --runThreadN $task.cpus
    """

}

process CreateDGEMatrix {

    tag "Counting of $sample_id"
    
    input:
    path barcodes from barcodes_ch
    tuple val(sample_id), file(reads), file(bam) from R1_ch.join(bam_ch)
    val gtf from gtf_ch2

    output:
    path 'dir' into pooldir_ch

    script:
    """
    mkdir dir
    echo CreateDGEMatrix -f ${reads[0]} -b $bam -c $barcodes -gtf $gtf -p BU? -UMI 8 -o dir
    """

}


