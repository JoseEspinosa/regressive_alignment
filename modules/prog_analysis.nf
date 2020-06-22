#!/bin/bash nextflow
params.outdir = 'results'

include PROG_ALIGNER       from './generateAlignment.nf'   
include EVAL_ALIGNMENT      from './evaluateAlignment.nf'  
include EASEL_INFO          from './evaluateAlignment.nf'  
include GAPS_PROGRESSIVE    from './evaluateAlignment.nf'  
include METRICS             from './evaluateAlignment.nf' 

include PRECOMPUTE_BLAST    from './preprocess.nf'   
include TCOFFEE_ALIGNER     from './generateAlignment.nf'   

include INTRAMOL_MATRIX_GENERATION   from './preprocess.nf'
include SELECTED_PAIRS_OF_COLUMNS_MATRIX   from './preprocess.nf'
include LIBRARY_GENERATION   from './preprocess.nf'
include ALN_2_PHYLIP   from './preprocess.nf'

workflow PROG_ANALYSIS {
  take:
    seqs_and_trees
    refs_ch
    align_method
    tree_method
     
  main: 
    PROG_ALIGNER (seqs_and_trees, align_method)
   
    if (params.evaluate){
      refs_ch
        .cross (PROG_ALIGNER.out.alignmentFile)
        .map { it -> [ it[1][0], it[1][1], it[0][1] ] }
        .set { alignment_and_ref }
        
      EVAL_ALIGNMENT ("progressive", alignment_and_ref, PROG_ALIGNER.out.alignMethod, PROG_ALIGNER.out.treeMethod,"NA")
      EVAL_ALIGNMENT.out.tcScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.progressive.tcScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
      EVAL_ALIGNMENT.out.spScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.progressive.spScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
      EVAL_ALIGNMENT.out.colScore
                    .map{ it ->  "${it[0]};${it[1]};${it[2]};${it[3]};${it[4]};${it[5].text}" }
                    .collectFile(name: "${workflow.runName}.progressive.colScore.csv", newLine: true, storeDir:"${params.outdir}/CSV/${workflow.runName}/")
    }
    if (params.gapCount){
      GAPS_PROGRESSIVE("progressive", PROG_ALIGNER.out.alignmentFile, PROG_ALIGNER.out.alignMethod, PROG_ALIGNER.out.treeMethod,"NA")
    }
    if (params.metrics){
      METRICS("progressive", PROG_ALIGNER.out.alignmentFile, PROG_ALIGNER.out.alignMethod, PROG_ALIGNER.out.treeMethod,"NA", PROG_ALIGNER.out.metricFile)
    }
    if (params.easel){
      EASEL_INFO ("progressive", PROG_ALIGNER.out.alignmentFile, PROG_ALIGNER.out.alignMethod, PROG_ALIGNER.out.treeMethod,"NA")
    }
}

workflow TCOFFEE_TEST {
  take:
    seqs
    tc_mode
    aln_templates
    pair_method
    pair_file

  main: 
    //INTRAMOL_MATRIX_GENERATION(aln_templates)
    SELECTED_PAIRS_OF_COLUMNS_MATRIX(seqs,pair_file, aln_templates, "1")
    //LIBRARY_GENERATION(aln_templates)
    //ALN_2_PHYLIP(seqs)
}

workflow TCOFFEE_ANALYSIS {
  take:
    seqs
    tc_mode
    aln_templates
    pair_method

  main: 
  if(params.generateBlast){
    //PRECOMPUTE_BLAST (seqs)
    //TCOFFEE_ALIGNER (seqs, tc_mode, pdbFiles, PRECOMPUTE_BLAST.out.id)
  }else{
    aln_templates.view()
    
    TCOFFEE_ALIGNER (seqs, tc_mode, aln_templates, "NA")
  }
}

workflow CLANS_ANALYSIS {
  take:
    seqs
    tc_mode
    aln_templates
    pair_method

  main: 
  LIBRARY_GENERATION(aln_templates)

  TCOFFEE_ALIGNER(tcoffee_mode == '3d_align')   //COMPUTE_3D_ALING()

  TCOFFEE_ALIGNER(tcoffee_mode == '3dM_align')  //COMPUTE_3DM_ALING()

  REG_ALIGNER                                   //3d

  REG_ALIGNER                                   //3dm

  COMPUTE_IRMSD
}