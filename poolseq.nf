#!/usr/bin/env nextflow
params.genomedir=null
params.fasta=null
params.barcodes=null
params.results="results"

fasta_ch = Channel.fromPath("$params.genomedir/*.fa")
barcodes_ch = Channel.fromPath("$params.barcodes")

Channel
    .fromFilePairs("$params.fasta/*R{1,2}*")
    .into {R2_ch ; R1_ch}

Channel
    .fromPath("$params.genomedir/*.gtf")
    .into {gtf_ch; gtf_ch2}


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
      
    input:
    tuple val(sample_id), file(reads) from R2_ch
    val index from genomeindx_ch.first()    
    
    output:
    tuple val(sample_id), file("${sample_id}*.bam") into bam_ch

    script:  
    """
    STAR --genomeDir $index  \
    --genomeLoad LoadAndRemove \
    --readFilesIn ${reads[1]} --readFilesCommand zcat \
    --outFileNamePrefix ${sample_id} \
    --outFilterMultimapNmax 1 \
    --outSAMtype BAM Unsorted \
    --runThreadN $task.cpus
    """

}

process CreateDGEMatrix {
    
  input:
  val barcodes from barcodes_ch.first()
  tuple val(sample_id), file(reads), file(bam) from R1_ch.join(bam_ch)
  val gtf from gtf_ch2.first()

  output:
  tuple val(sample_id), file("${sample_id}/*") into matrices_ch

  script:
  """
  java -jar /Brbseq/BrbseqTools.jar CreateDGEMatrix -f ${reads[0]} -b $bam -c $barcodes -gtf $gtf -p BU? -UMI 8 -o ${sample_id}
  """

}



process RenameHeaders {
    publishDir "${params.results}", mode:'copy', saveAs:{filename -> "${sample_id}_$filename"}
  
    input:
    tuple val(sample_id), file(dgematrices) from matrices_ch

    output:
    file(dgematrices) into results_ch

    script:
    """
    sed -i "1 s/iO_[0-9]/${sample_id}_&/g" $dgematrices
    """

}
