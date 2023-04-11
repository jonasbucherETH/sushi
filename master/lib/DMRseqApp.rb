#!/usr/bin/env ruby
# encoding: utf-8

require 'sushi_fabric'
require_relative 'global_variables'
include GlobalVariables

class DMRseqApp <  SushiFabric::SushiApp
  def initialize
    super
    @name = 'DMRseq'
    @params['process_mode'] = 'DATASET'
    @analysis_category = 'Stats'
    @description =<<-EOS
Differentially methylated region analysis. <br/>
    EOS
    @required_columns = ['Name','COV'] # 'Species'
    @required_params = ['name', 'testCovariate']
    @params['cores'] = '1'
    @params['ram'] = '50'
    @params['scratch'] = '100'
    @params['refBuild'] = ref_selector
    @params['refFeatureFile'] = 'genes.gtf'
    @params['testCovariate'] = ''
    @params['testCovariate', 'description'] = 'Specify the column name of your co-variate to 
    split the samples into groups for testing. Make sure the
    column name is in the format "NAME [Factor]" or "NAME [Numeric]"'
    @params['adjustCovariate'] = ''
    @params['adjustCovariate', 'description'] = 'Specify the column name of your co-variate to 
    adjust for when testing for testCovariate. Make sure the
    column name is in the format "NAME [Factor]" or "NAME [Numeric]"'
    @params['matchCovariate'] = ''
    @params['matchCovariate', 'description'] = 'Specify the column name of your co-variate to 
    block for when constructing permutations for testing. Make sure the
    column name is in the format "NAME [Factor]" or "NAME [Numeric]"'
    @params['cutoff'] = 0.1
    @params['cutoff', 'description'] = 'value cutoff of the single CpG coefficient that is used to discover candidate regions'
    @params['minNumRegion'] = 5
    @params['minNumRegion', 'description'] = 'place holder'
    @params['smooth'] = true
    @params['smooth', 'description'] = 'place holder'
    @params['bpSpan'] = 1000
    @params['bpSpan', 'description'] = 'place holder'
    @params['minInSpan'] = 30
    @params['minInSpan', 'description'] = 'place holder'
    @params['maxGapSmooth'] = 5000
    @params['maxGapSmooth', 'description'] = 'place holder'
    @params['maxGap'] = 1000
    @params['maxGap', 'description'] = 'place holder'
    @params['maxPerms'] = 10
    @params['maxPerms', 'description'] = 'place holder'
    @params['stat'] = ['stat', 'L', 'area', 'beta', 'avg']
    @params['stat', 'description'] = 'place holder'
    @params['block'] = FALSE
    @params['block', 'description'] = 'place holder'
    @params['blockSize'] = 5000
    @params['blockSize', 'description'] = 'place holder'
    @params['chrsPerChunk'] = 1
    @params['chrsPerChunk', 'description'] = 'place holder'
    @params['name'] = 'dmrseq'
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
    run_RApp("EzAppDMRseq", lib_path: "/srv/GT/analysis/jonas/R_LIBS")
    #command = "vcf-stats #{File.join("$GSTORE_DIR", @dataset[0]['Filtered VCF [File]'])} -p #{@params['name']}/vcf_stats"
  end
end
