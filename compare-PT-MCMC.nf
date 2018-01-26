#!/usr/bin/env nextflow

deliverableDir = 'deliverables/' + workflow.scriptName.replace('.nf','')

nChains = (0..3).collect{Math.pow(2.0, it)}

process buildCode {

  cache true
  
  input:
    val gitRepoName from 'blangExample'
    val gitUser from 'UBC-Stat-ML'
    val codeRevision from '770ab86ff82a9e753f0ad26a5111ad8d2898af77'
    val snapshotPath from "${System.getProperty('user.home')}/w/blangSDK"
  
  output:
    file 'code' into code
    file 'blangExample/data' into data

  script:
    template 'buildRepo.sh'
}

process runBlang {

  echo false

  input:
    file code
    file data
    each n from nChains
        
  output:
    file '.' into execFolders
    
  """
  java -cp code/lib/\\* -Xmx2g demo.Mixture \
    --model.data file data/mixture_data.csv \
    --engine PT \
    --engine.ladder.nChains ${n as int} 
  """
}

process createPlot {

  echo true

  input:
    file 'execFolder' from execFolders
    
   output:
    file "*.pdf"  
    file "*.csv"

  publishDir deliverableDir, mode: 'copy', overwrite: true
      
  """
  #!/usr/bin/env Rscript
  require("ggplot2") 
  require("dplyr")
  
  data <- read.csv("execFolder/results/latest/samples/means.csv")
  
  settings <- read.table("execFolder/results/latest/arguments.tsv", header=FALSE, sep="\t", row.names=1, strip.white=TRUE, na.strings="NA", stringsAsFactors=FALSE)
  
  n.chains <- settings["engine.ladder.nChains",1]

  ggplot(data, aes(value)) +
    geom_density() +
    facet_grid(index_0 ~ .) +
    theme_bw()
  ggsave(paste0("density-center-means-",n.chains,"-chains.pdf"), width = 5, height = 5)

  ggplot(data, aes(x = sample, y = value)) +
    geom_line() +
    facet_grid(index_0 ~ .) +
    theme_bw()
  ggsave(paste0("trace-center-means-",n.chains,"-chains.pdf"), width = 5, height = 5)
  
  write.csv(data, paste0("samples-center-means-",n.chains,"-chains.csv"))
  """
}

process summarizePipeline {

  cache false
  
  output:
      file 'pipeline-info.txt'
      
  publishDir deliverableDir, mode: 'copy', overwrite: true
  
  """
  echo 'scriptName: $workflow.scriptName' >> pipeline-info.txt
  echo 'start: $workflow.start' >> pipeline-info.txt
  echo 'runName: $workflow.runName' >> pipeline-info.txt
  echo 'nextflow.version: $workflow.nextflow.version' >> pipeline-info.txt
  """

}