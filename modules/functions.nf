#!/bin/bash nextflow

def set_templates_path () {
    if( !nextflow.version.matches('20.04.1-edge+') ) {
        println "It is advisable to run this workflow with Nextflow version 20.04.1-edge or greater -- You are running version $nextflow.version"
        path_templates = workflow.commandLine.contains('--pipeline') ? "$baseDir/modules/regressive_alignment/modules/templates" : "$baseDir/modules/templates"
    }
    else {
        path_templates = "${moduleDir}/templates"
    }
    return path_templates
}
