#!/usr/bin/env ruby
# encoding: utf-8

require 'sushi_fabric'
require_relative 'global_variables'
include GlobalVariables

class GreatApp <  SushiFabric::SushiApp
  def initialize
    super
    @name = 'Great'
    @params['process_mode'] = 'DATASET'
    @analysis_category = 'Stats'
    @description =<<-EOS
Differentially methylated region analysis. <br/>
    EOS
    @required_columns = ['Name'] # 'Species'
    @required_params = ['name', 'biomart_dataset', 'txdb_dataset']
    @params['cores'] = '1'
    @params['ram'] = '50'
    @params['scratch'] = '100'
    @params['biomart_dataset'] = ''
    @params['biomart_dataset', 'description'] = 'Search and copy the desired dataset name into this field from here:
      https://jokergoo.github.io/BioMartGOGeneSets/articles/supported_organisms.html'
    @params['txdb_dataset'] = ''
    @params['txdb_dataset', 'description'] = 'Search and copy the desired dataset name into this field from here:'
      
    #@params['gene_sets'] = ['BP', 'CC', 'MF']
    #@params['gene_sets', 'description'] = 'BO: Biological Process, CC: Cellular Component, MF: Molecular Function'
    #@params['reactome_kegg'] = true
    #@params['reactome_kegg', 'description'] = 'Include Reactome and KEGG pathways of A. thaliana'
    #@params['min_gene_set_size'] = 5
    #@params['min_gene_set_size', 'description'] = 'Minimal size of gene sets'
    #@params['mode'] = ['basalPlusExt', 'twoClosest', 'oneClosest']
    #@params['mode', 'description'] = 'The mode to extend genes.'
    #@params['basal_upstream'] = 5000
    #@params['basal_upstream', 'description'] = "In 'basalPlusExt' mode, number of base pairs extending to the upstream of TSS"
    #@params['basal_downstream'] = 1000
    #@params['basal_downstream', 'description'] = "In 'basalPlusExt' mode, number of base pairs extending to the downstream of TSS"
    #@params['extension'] = 1000000
    #@params['extension', 'description'] = 'Extensions from the basal domains'
    #@params['exclude'] = 'gap'
    #@params['exclude', 'description'] = 'Regions that are excluded from analysis such as gap regions'
    @params['refBuild'] = ref_selector
    @params['refFeatureFile'] = 'genes.gtf'
    @params['name'] = 'great'
    @params['mail'] = ""
    @modules = ["Dev/R"]
    @inherit_tags = ["Factor", "B-Fabric", "Characteristic"]
  end
  def next_dataset
    report_file = File.join(@result_dir, @params['name'])
    report_link = File.join(report_file, '00index.html')
    {'Name'=>@params['name'],
      #'Species'=>@dataset['Species'],
      'refBuild'=>@params['refBuild'],
      'refFeatureFile'=>@params['refFeatureFile'],
      'Report [File]'=>report_file,
      'Static Report [Link]'=>report_link,
      #'Interactive report [Link]'=>"https://fgcz-shiny.uzh.ch/PopGen_Structure?data=#{report_file}",
      #'Regions'=>File.join(report_file, "regions.rds"),
    }.merge(extract_columns(@inherit_tags))
  end
  def commands
    run_RApp("EzAppGreat", lib_path: "/srv/GT/analysis/jonas/R_LIBS")
  #command = "vcf-stats #{File.join("$GSTORE_DIR", @dataset[0]['Filtered VCF [File]'])} -p #{@params['name']}/vcf_stats"
  end
end
