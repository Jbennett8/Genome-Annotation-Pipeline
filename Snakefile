#report: "report/workflow.rst"
configfile: "config.yaml"

## Get input parameters
speciesName=config["input"]["speciesName"]
relatedSpeciesName=config["input"]["relatedSpeciesName"]
buscoLineage=config["input"]["buscoLineage"]
genomeSize=config["input"]["genomeSize"]
speciesSraFile="%s_sra.txt" % speciesName
relatedSraFile="%s_sra.txt" % relatedSpeciesName
chromosomeAssembly=config["input"]["chromosomeAssembly"]

## Define output directory structure
buscoDir="metrics/busco"
rawReadsDir="evidence/raw"
trimmedDir="evidence/trimmed"
scytheDir="evidence/scythe"
gmapIndexDir="index/gmap"
hisatIndexDir="index/hisat"
fastQcDir="metrics/fastqc"
tsaDir="evidence/transcriptome"
hisatDir="alignment/hisat"
gmapDir="alignment/gmap"
gthDir="alignment/gth"
brakerDir="annotation/braker"

## Global variables
filteredSoftmaskedGenome="genome/%s_sm_filtered.fasta" % speciesName
filteredSoftmaskedGenomeLTRStruct="genome/LTRStruct/%s_sm_filtered.fasta" % speciesName
buscoFilename="short_summary.specific.%s.busco_o.txt" % buscoLineage
speciesTranscriptome="%s/%s/tsa_concatenated.fasta" % (tsaDir,speciesName)
relatedTranscriptome="%s/%s/tsa_concatenated.fasta" % (tsaDir,relatedSpeciesName)
speciesGmap="%s/%s/gmap.gff3" % (gmapDir,speciesName)
relatedGmap="%s/%s/gmap.gff3" % (gmapDir,relatedSpeciesName)
speciesSra=[sample for sample in open(speciesSraFile).read().split('\n') if len(sample) > 0]

if(relatedSpeciesName):
  relatedSra=[sample for sample in open(relatedSraFile).read().split('\n') if len(sample) > 0]
else:
  relatedSra=[]

## Script Parameters
sickleMinLength="50" # usually 50
sickleMinQuality="30" # usually 30


## Wildcard constraints
wildcard_constraints:
  sra="[A-Za-z0-9]+"

### Input Functions
def getChroms(): 
  if(chromosomeAssembly==False):
    return []
  genome=f"genome/{speciesName}.fasta"
  script="bin/aux/getChroms.sh"
  outDir="genome/LTRStruct/chromosomes"
  outFile=f"{outDir}/chromosomes.txt"
  if((not os.path.exists(outFile)) or (os.path.getsize(outFile)==0)): # so we dont have to grep the chromosomes file every time we run snakemake
    cmd=f"bash {script} {genome} {outDir}"
    subprocess.run(cmd.split(),check=True) # Snakemake will fail if this function returns error, this will fail with code 2 if there is no genome in 'genome/{speciesName}.fasta'
  chroms=open(outFile).readlines()
  chroms=sorted([i.strip() for i in chroms])
  return chroms

def runMaker(chroms):
  if(chromosomeAssembly==False):
    return "annotation/maker/single/round1/maker.all.gff"
  else:
    return expand("annotation/maker/{chrom}/round1/maker.all.gff",chrom=chroms)

def runBraker():
  if(relatedSpeciesName==None):
    return expand("%s/braker{run}/braker/augustus.hints.aa" % brakerDir,run=[1,4])
  else:
    return expand("%s/braker{run}/braker/augustus.hints.aa" % brakerDir,run=[1,2,3,4])

## Variables we get from processing files
# This command is used to find the chromosomes in a fasta file for use in makerParallel
# This command will fail usually for two reasons
# 1. The genome fasta has no chromosomes with headers like >Chr
# 2. genome/$speciesName.fasta does not exist (you have to place it there to start the pipeline)
chroms=getChroms()

rule all:
  input:
    ## Braker Pipeline
#    runBraker()
    ## To run Maker pipeline
#    runMaker(chroms)
  params:
    jobName="all_%s" % speciesName,
  resources:
    partition="general",
    jobName="all_%s" % speciesName,
    qos="general",
    mem="5G",
    cpus="1",
    ntasks="1"

rule repeatModeler:
  input:
    fasta="genome/%s.fasta" % speciesName,
  output:
    maskLib="{dir}/consensi.fa.classified"
  params:
    jobName="repeatModeler_%s" % speciesName,
    script="bin/repeatMask/repeatModeler.sh"
  resources:
    partition="general",
    qos="general",
    mem="50G",
    cpus="22",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.fasta} {wildcards.dir}"

rule repeatMasker: # this rule splits the genome fasta and submits the array job bin/repeatMasker.sh
  input:
    maskLib="{dir}/consensi.fa.classified",
    genome="genome/{name}.fasta"
  output:
    "{dir}/{name}_sm.fasta"
  params:
    jobName="repeatSubmit_{name}",
    script="bin/repeatMask/repeatSubmit.sh",
  resources:
    partition="general",
    qos="general",
    mem="50G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.genome} {wildcards.name} {input.maskLib} {wildcards.dir}"

rule filterGenome:
  input: 
    fasta="{dir}/{name}.fasta"
  output:
    "{dir}/{name}_filtered.fasta"
  params:
    jobName="filterGenome_{name}",
    script="bin/filter/filterFasta.sh"
  resources:
    partition="general",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.fasta} 500 {wildcards.dir}"

rule quast:
  input: 
    genome="genome/%s_sm_filtered.fasta" %speciesName
  output:
    "metrics/quast/report.txt"
  params:
    jobName="quast_%s" % speciesName,
    script="bin/metrics/quast.sh"
  resources:
    partition="general",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.genome} metrics/quast"

rule buscoGenome:
  input:
    filteredSoftmaskedGenome
  output:
    "{buscoDir}/genome/busco_o/short_summary.specific.{buscoLineage}.busco_o.txt"
  params:
    jobName="buscoGenome_%s" % speciesName,
    script="bin/metrics/busco.sh"
  resources:
    partition="xeon",
    qos="general",
    mem="100G",
    cpus="10",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {filteredSoftmaskedGenome} {buscoLineage} {buscoDir}/genome"

rule buscoGeneral: # for running busco outside of pipeline
  input:
    name="{species}/{file}.{type}",
  output:
    "{species}/busco/{file}_{type}/busco_o/short_summary.specific.%s.busco_o.txt" % (buscoLineage)
  params:
    jobName="busco_{species}_{file}_{type}",
    script="bin/metrics/busco.sh"
  resources:
    partition="xeon",
    qos="general",
    mem="80G",
    cpus="10",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.name} {buscoLineage} {wildcards.species}/busco/{wildcards.file}_{wildcards.type}"

rule buscoBrakerProtein:
  input:
    prot="%s/braker{run}/braker/augustus.hints.aa" % brakerDir,
  output:
    "%s/braker{run}/busco_o/short_summary.specific.%s.busco_o.txt" % (buscoDir,buscoLineage)
  params:
    jobName="busco_braker{run}_%s" % speciesName,
    script="bin/metrics/busco.sh"
  resources:
    partition="xeon",
    qos="general",
    mem="40G",
    cpus="10",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.prot} {buscoLineage} {buscoDir}/braker{wildcards.run}"

rule gmapIndex:
  input:
    fasta=filteredSoftmaskedGenome
  output:
    "{gmapIndexDir}/gmap.chromosome"
  params:
    jobName="gmapIndex",
    script="bin/alignment/gmap/index.sh"
  resources:
    partition="general",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.fasta}"

rule gmap:
  input:
    "%s/gmap.chromosome" % gmapIndexDir,
    filteredCentroids="%s/{name}/cluster/centroids-filtered" % tsaDir
  output:
    "{gmapDir}/{name}/gmap.gff3"
  params:
    jobName="gmapAlign_{name}",
    script="bin/alignment/gmap/align.sh"
  resources:
    partition="general",
    qos="general",
    mem="80G",
    cpus="8",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.filteredCentroids} {gmapDir}/{wildcards.name} {genomeSize}"

rule hisatIndexSmall:
  input:
    fasta=filteredSoftmaskedGenome
  output:
    "{hisatIndexDir}/hisat.1.ht2"
  params:
    jobName="hisatIndex",
    script="bin/alignment/hisat/index.sh"
  resources:
    partition="general",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.fasta}"

rule hisatIndexLarge:
  input:
    fasta=filteredSoftmaskedGenome
  output:
    "{hisatIndexDir}/hisat.1.ht2l"
  params:
    jobName="hisatIndex",
    script="bin/alignment/hisat/index.sh"
  resources:
    partition="general",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.fasta}"

def hisatAlignInput(wildcards):
  if(genomeSize=="small"):
    return "%s/hisat.1.ht2" % hisatIndexDir
  else:
    return "%s/hisat.1.ht2l" % hisatIndexDir

rule hisatAlign:
  input:
    "%s/{name}/scythe_{sra}_1.fastq" % scytheDir,
    "%s/{name}/scythe_{sra}_2.fastq" % scytheDir,
    hisatAlignInput
  output:
    "{hisatDir}/{name}/sorted_{sra}.bam"
  params:
    jobName="hisatAlign_{name}_{sra}",
    script="bin/alignment/hisat/align.sh"
  resources:
    partition="xeon",
    qos="general",
    mem="80G",
    cpus="8",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {wildcards.sra} {scytheDir}/{wildcards.name} {hisatDir}/{wildcards.name}"

def hisatMergeBamsInput(wildcards):
  if(wildcards.name==speciesName):
    return expand("%s/{{name}}/sorted_{sra}.bam" % hisatDir,sra=speciesSra)
  elif(wildcards.name==relatedSpeciesName):
    return expand("%s/{{name}}/sorted_{sra}.bam" % hisatDir,sra=relatedSra)

rule hisatMergeBams:
  input:
    hisatMergeBamsInput
  output:
    "{hisatDir}/{name}/merged.bam"
  params:
    jobName="hisatMergeBams_{name}",
    script="bin/alignment/hisat/merge.sh"
  resources:
    partition="xeon",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {hisatDir}/{wildcards.name}"

rule fetchSra:
  input:
#    "{name}_sra.txt",
  output:
    expand("{readsDir}/{{name}}/raw_{{sra}}_{pair}.fastq",readsDir=rawReadsDir,pair=[1,2])
  params:
    jobName="fetchsra_{name}_{sra}",
    script="bin/shortRead/fetchsra.sh"
  resources:
    partition="general",
    qos="general",
    mem="10G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {wildcards.sra} %s/{wildcards.name}" % rawReadsDir

rule sickle:
  input:
    "%s/{name}/raw_{sra}_1.fastq" % rawReadsDir,
  output:
    expand("%s/{{name}}/trimmed_{{sra}}_{pair}.fastq" % trimmedDir,pair=[1,2])
  params:
    jobName="sickle_{name}_{sra}",
    script="bin/shortRead/sickle.sh"
  resources:
    partition="general",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} %s/{wildcards.name} {wildcards.sra} %s/{wildcards.name} %s %s" % (rawReadsDir,trimmedDir,sickleMinQuality,sickleMinLength)

rule scythe: # for trimming adaptor content
  input:
    expand("%s/{{name}}/trimmed_{{sra}}_{pair}.fastq" % trimmedDir,pair=[1,2])
  output:
    expand("%s/{{name}}/scythe_{{sra}}_{pair}.fastq" % scytheDir,pair=[1,2])
  params:
    jobName="scythe_{name}_{sra}",
    script="bin/shortRead/scythe.sh"
  resources:
    partition="general",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {trimmedDir}/{wildcards.name} {scytheDir}/{wildcards.name}"
  
rule fastqc:
  input:
    expand("evidence/{{readtype}}/{{name}}/{{readtype}}_{{sra}}_{pair}.fastq",pair=[1,2]),
  output:
    expand("%s/{{readtype}}/{{name}}/{{readtype}}_{{sra}}_{pair}_fastqc.html" % fastQcDir,pair=[1,2])
  params:
    jobName="fastqc_{name}_{readtype}_{sra}",
    script="bin/metrics/fastqc.sh"
  resources:
    partition="general",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} evidence/{wildcards.readtype}/{wildcards.name} {wildcards.readtype}_{wildcards.sra}_1.fastq {wildcards.readtype}_{wildcards.sra}_2.fastq %s/{wildcards.readtype}/{wildcards.name}" % fastQcDir

rule trinity:
  input:
    expand("%s/{{name}}/scythe_{{sra}}_{pair}.fastq" % scytheDir,pair=[1,2])
  output:
    "%s/{name}/{sra}/prefix.Trinity.fasta" % tsaDir
  params:
    jobName="trinity_{name}_{sra}",
    script="bin/transcriptome/trinity.sh"
  resources:
    partition="general",
    qos="general",
    mem="150G",
    cpus="20",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input[0]} {input[1]} %s/{wildcards.name}/{wildcards.sra}" % tsaDir

def frameselectInput(wildcards):
  if(wildcards.name==speciesName):
    return expand("%s/{{name}}/{sra}/prefix.Trinity.fasta" % tsaDir,sra=speciesSra)
  elif(wildcards.name==relatedSpeciesName):
    return expand("%s/{{name}}/{sra}/prefix.Trinity.fasta" % tsaDir,sra=relatedSra)
  else:
    return "asked for name %s" % wildcards.name

rule frameselect:
  input:
    frameselectInput
#    expand("%s/{{name}}/{sra}/trinity.Trinity.fasta" % tsaDir,sra=speciesSra)
  output:
    "%s/{name}/frameselect/bestHit/tsa_concatenated.fasta.transdecoder.cds" % tsaDir,
    "%s/{name}/frameselect/bestHit/tsa_concatenated.fasta.transdecoder.pep" % tsaDir,
    "%s/{name}/tsa_concatenated.fasta" % tsaDir
  params:
    script="bin/transcriptome/frameSelect.sh",
    jobName="frameSelect_{name}",
  resources:
    partition="general",
    qos="general",
    mem="20G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "cat {input} > %s/{wildcards.name}/tsa_concatenated.fasta && "
    "bash {params.script} %s/{wildcards.name}/tsa_concatenated.fasta %s/{wildcards.name}/frameselect" % (tsaDir,tsaDir,tsaDir)

rule cluster:
  input:
    "%s/{name}/frameselect/bestHit/tsa_concatenated.fasta.transdecoder.cds" % tsaDir
  output:
    "%s/{name}/cluster/centroids-filtered" % tsaDir
  params:
    script="bin/transcriptome/cluster.sh",
    jobName="cluster_{name}",
  resources:
    partition="general",
    qos="general",
    mem="20G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input[0]} bin %s/{wildcards.name}/cluster" % (tsaDir)

rule filterpep:
  input:
    filteredPep="%s/{name}/frameselect/bestHit/tsa_concatenated.fasta.transdecoder.pep" % tsaDir,
    filteredCen="%s/{name}/cluster/centroids-filtered" % tsaDir
  output:
    "%s/{name}/frameselect/bestHit/filter300nameList.txt" % tsaDir,
    "%s/{name}/frameselect/bestHit/tmp.pep" % tsaDir,
    "%s/{name}/frameselect/bestHit/filtered.pep" % tsaDir
  params:
    script="bin/transcriptome/filterPeptide.sh",
    jobName="filterPeptide_{name}",
  resources:
    partition="general",
    qos="general",
    mem="40G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.filteredCen} {input.filteredPep} %s/{wildcards.name}/frameselect/bestHit" % tsaDir

rule genomeThreader:
  input:
    filteredSoftmaskedGenome,
    filteredPep="%s/{name}/frameselect/bestHit/filtered.pep" % tsaDir
  output:
    "%s/{name}/gth.gff3" % gthDir
  params:
    script="bin/alignment/genomeThreader.sh",
    jobName="genomeThreader_{name}",
  resources:
    partition="general",
    qos="general",
    mem="60G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.filteredPep} {input[0]} %s/{wildcards.name}" % gthDir

rule braker1:
  input:
    gen=filteredSoftmaskedGenome,
    bam="%s/%s/merged.bam" % (hisatDir,speciesName)
  output:
    "%s/braker1/braker/braker.gff3" % brakerDir,
    prot="%s/braker1/braker/augustus.hints.aa" % brakerDir
  params:
    jobName="braker1_%s"%speciesName,
    script="bin/annotation/braker.sh"
  resources:
    partition="general",
    qos="general",
    mem="80G",
    cpus="20",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} %s {input.gen} {input.bam} %s/braker1" % (speciesName+"1",brakerDir)

rule braker2:
  input:
    gen=filteredSoftmaskedGenome,
    bam="%s/%s/merged.bam" % (hisatDir,speciesName),
    prot=expand("%s/{name}/gth.gff3" % gthDir,name=[speciesName,relatedSpeciesName])
  output:
    "%s/braker2/braker/braker.gff3" % brakerDir,
    prot="%s/braker2/braker/augustus.hints.aa" % brakerDir
  params:
    script="bin/annotation/braker.sh",
    jobName="braker2_%s"%speciesName,
  resources:
    partition="general",
    qos="general",
    mem="80G",
    cpus="20",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "cat {input.prot} > %s/braker2/speciesAndRelated.gff3 && "
    "bash {params.script} %s {input.gen} {input.bam} %s/braker2 "
    "\"--hints=speciesAndRelated.gff3\"" % (brakerDir,speciesName+"2",brakerDir)

rule braker3:
  input:
    gen=filteredSoftmaskedGenome,
    bam="%s/%s/merged.bam" % (hisatDir,relatedSpeciesName),
    prot="%s/%s/gth.gff3" % (gthDir,relatedSpeciesName)
  output:
    "%s/braker3/braker/braker.gff3" % brakerDir,
    prot="%s/braker3/braker/augustus.hints.aa" % brakerDir
  params:
    script="bin/annotation/braker.sh",
    jobName="braker3_%s"%speciesName,
  resources:
    partition="general",
    qos="general",
    mem="150G",
    cpus="20",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} %s {input.gen} {input.bam} %s/braker3 "
    "\"--hints=$PWD/{input.prot}\"" % (speciesName+"3",brakerDir)


rule braker4:
  input:
    gen=filteredSoftmaskedGenome,
    bam="%s/%s/merged.bam" % (hisatDir,speciesName),
    prot="%s/%s/gth.gff3" % (gthDir,speciesName)
  output:
    "%s/braker4/braker/braker.gff3" % brakerDir,
    prot="%s/braker4/braker/augustus.hints.aa" % brakerDir
  params:
    jobName="braker4_%s"%speciesName,
    script="bin/annotation/braker.sh"
  resources:
    partition="general",
    qos="general",
    mem="100G",
    cpus="20",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} %s {input.gen} {input.bam} %s/braker4 "
    "\"--hints=$PWD/{input.prot}\"" % (speciesName+"4",brakerDir)

rule braker5:
  input:
    gen=filteredSoftmaskedGenomeLTRStruct,
    bam="%s/%s/merged.bam" % (hisatDir,speciesName)
  output:
    "%s/braker5/braker/braker.gff3" % brakerDir,
    prot="%s/braker5/braker/augustus.hints.aa" % brakerDir
  params:
    jobName="braker1_%s"%speciesName,
    script="bin/annotation/braker.sh"
  resources:
    partition="general",
    qos="general",
    mem="80G",
    cpus="20",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} %s {input.gen} {input.bam} %s/braker5" % (speciesName+"5",brakerDir)

rule plotBusco:
  input:
    expand("%s/braker{run}/busco_o/%s" % (buscoDir,buscoFilename),run=[1,2,3,4]),
    "%s/genome/busco_o/short_summary.specific.%s.busco_o.txt" % (buscoDir,buscoLineage)
  output:
    report("report/plots/busco_figure.png",caption="report/buscoPlot.rst",category="Metrics"),
    expand("%s/summaries/short_summary.specific.%s.braker{run}.txt" % (buscoDir,buscoLineage),run=["1","2","3","4"]),
    "%s/summaries/short_summary.specific.%s.genome.txt" % (buscoDir,buscoLineage)
  params:
    script="bin/metrics/plot_busco.sh",
    jobName="plotBusco_%s"%speciesName,
  resources:
    partition="general",
    qos="general",
    mem="5G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {buscoLineage}"

rule hisatAlnRates:
  input:
    expand("log/hisat_%s"%speciesName,sra=speciesSra+relatedSra)
  output:
#    report("metrics/hisatAlignment/alignment.txt",caption="report/hisatAlignment.rst",category="Metrics")
  params:
    script="bin/metrics/parseHisatAlignment.py",
    jobName="hisatAlignmentRates_%s" % speciesName,
  resources:
    partition="general",
    qos="general",
    mem="5G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "python {params.script} log/hisat_* > {output}"

rule splitChroms: # used for Parallel (not mpi) maker
  input:
    gen=filteredSoftmaskedGenomeLTRStruct
  output:
    expand("genome/LTRStruct/chromosomes/{chrom}.fasta",chrom=chroms)
  params:
    script="bin/aux/splitChroms.sh",
    jobName="splitChroms_%s" % speciesName,
  resources:
    partition="general",
    qos="general",
    mem="30G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {input.gen} genome/LTRStruct/chromosomes"

rule setUpMakerMPI:
  output:
    "annotation/maker/round1/maker_opts.ctl",
    "annotation/maker/round2/maker_opts.ctl",
    "annotation/maker/round3/maker_opts.ctl"
  params:
    script="bin/annotation/maker/setUpMaker.sh",
    jobName="setUpMakerMPI_%s" % speciesName,
  resources:
    partition="general",
    qos="general",
    mem="5G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {genomeSize} {filteredSoftmaskedGenomeLTRStruct} {speciesGmap} {relatedGmap} {speciesTranscriptome} {relatedTranscriptome}"

rule maker1MPI:
  input:
    "annotation/maker/round1/maker_opts.ctl",
    filteredSoftmaskedGenome,
    speciesGmap,
    relatedGmap
  output:
    "round1.all.gff"
  params:
    script="bin/annotation/maker/maker_mpi.sh",
    jobName="maker1_%s" % speciesName,
  resources:
    partition="general",
    qos="general",
    mem="10G",
    cpus="32",
    ntasks="10"
  shell:
    "echo jobName={params.jobName} && "
    "bash bin/maker/maker_mpi.sh round1 annotation/maker/round1"

def setUpMakerInput():
  out=[filteredSoftmaskedGenomeLTRStruct,speciesGmap,speciesTranscriptome]
  if(relatedSpeciesName==None):
    return out
  else:
    return out + [relatedGmap,relatedTranscriptome]

rule setUpMakerParallel:
  input:
    setUpMakerInput()
  output:
    expand("annotation/maker/chromosomes/{chrom}/round{num}/maker_opts.ctl",chrom=chroms,num=[1,2,3])
  params:
    script="bin/annotation/maker/setUpMakerParallel.sh",
    jobName="setUpMakerParallel_%s" % speciesName,
  resources:
    partition="general",
    qos="general",
    mem="5G",
    cpus="1",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {genomeSize} {input}"

rule setUpmakerSingle:
  input:
    setUpMakerInput()
  output:
    expand("annotation/maker/single/round{num}/maker_opts.ctl",num=[1,2,3])
  params:
    script="bin/annotation/maker/setUpMaker.sh",
    jobName="setUpMakerSingle_%s" % speciesName,
  resources:
    partition="general",
    qos="general",
    mem="10G",
    cpus="16",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} {genomeSize} {input}"

rule maker1Parallel:
  input:
    "annotation/maker/chromosomes/{chrom}/round1/maker_opts.ctl",
    "genome/maker/chromosomes/{chrom}.fasta",
    speciesGmap,
    relatedGmap
  output:
    "annotation/maker/chromosomes/{chrom}/round1/maker.all.gff"
  params:
    script="bin/annotation/maker/maker.sh",
    jobName="maker1_%s_{chrom}" % speciesName,
  resources:
    partition="general",
    qos="general",
    mem="10G",
    cpus="16",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} annotation/maker/chromosomes/{wildcards.chrom}/round1 {resources.cpus}"

def maker1SingleInput():
  ctlFile="annotation/maker/single/round1/maker_opts.ctl"
  out=[ctlFile,speciesGmap,filteredSoftmaskedGenomeLTRStruct]
  if(relatedSpeciesName==None):
    return out
  else:
    return out + [relatedGmap]

rule maker1Single:
  input:
    speciesGmap,
    filteredSoftmaskedGenomeLTRStruct,
    maker1SingleInput()
  output:
    "annotation/maker/single/round1/maker.all.gff"
  params:
    script="bin/annotation/maker/maker.sh",
    jobName="maker1Single_%s" % speciesName,
  resources:
    partition="general",
    qos="general",
    mem="10G",
    cpus="16",
    ntasks="1"
  shell:
    "echo jobName={params.jobName} && "
    "bash {params.script} annotation/maker/single/round1 {resources.cpus}"
