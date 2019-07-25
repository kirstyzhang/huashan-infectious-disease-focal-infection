#PMseq.sh 

##Step 1: Quality filter
QC_filter -l 35 -q 0.5 -n 0.06 -a adapter.fa -i SampleID_raw.fq.gz -o SampleID_clean.fastq

##Step 2: Map to human reference and remove human sequence
bwa mem -t 8 -Y hg19_and_YH.fa SampleID_clean.fastq > SampleID_map_host.sam 
remove_host_seq -i SampleID_map_host.sam -o SampleID_clean_nonhost.fastq

##Step 3: Alignment to bacterial/virus/fungi/parasite DB
bwa mem -t 8 -Y PMseq_ref.fa SampleID_clean_nonhost.fastq > SampleID_map_pmseq_ref.sam 
samtools view -S -b SampleID_map_pmseq_ref.sam | samtools sort - SampleID_map_pmseq_ref.sort
samtools rmdup -s SampleID_map_pmseq_ref.sort.bam SampleID_map_pmseq_ref.sort.rmdup.bam

##Step 4: Taxonomic and reporting
PMseq_tax_report -i SampleID_map_pmseq_ref.sort.rmdup.bam -d PMseq_taxonomy.db -o SampleID.pmseq.tax-report.xls