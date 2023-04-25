#!/usr/bin/env ruby
# encoding: utf-8

require 'sushi_fabric'
require_relative 'global_variables'
include GlobalVariables

class MethylKitApp <  SushiFabric::SushiApp
  def initialize
    super
    @name = 'MethylKit'
    @params['process_mode'] = 'DATASET'
    @analysis_category = 'Stats'
    @description =<<-EOS
Differentially methylated Loci analysis. <br/>
    EOS
    @required_columns = ['Name', 'COV'] 
    @required_params = ['name', 'species']
    @params['cores'] = '1'
    @params['ram'] = '50'
    @params['scratch'] = '100'
    @params['biomart_selection'] = biomart_selector
    @params['species'] = ''
    @params['species', 'description'] = 'species name'
    @params['refBuild'] = ref_selector
    @params['refFeatureFile'] = 'genes.gtf'
    @params['name'] = 'MethylKit'
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
    #'Selected_biomart'=>@params['biomart_selection'],
    'Report [File]'=>report_file,
    'Static Report [Link]'=>report_link,
    #'Interactive report [Link]'=>"https://fgcz-shiny.uzh.ch/PopGen_Structure?data=#{report_file}",
    #'Regions'=>File.join(report_file, "regions.rds"),
  }.merge(extract_columns(@inherit_tags))
  end
def commands
run_RApp("EzAppMethylKit", lib_path: "/srv/GT/analysis/jonas/R_LIBS")
#command = "vcf-stats #{File.join("$GSTORE_DIR", @dataset[0]['Filtered VCF [File]'])} -p #{@params['name']}/vcf_stats"
end
end
