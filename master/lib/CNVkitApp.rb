#!/usr/bin/env ruby
# encoding: utf-8

require 'sushi_fabric'
require_relative 'global_variables'
include GlobalVariables

class CNVkitApp <  SushiFabric::SushiApp
  def initialize
    super
    @name = 'CNVkit'
    @params['process_mode'] = 'DATASET'
    @analysis_category = 'Stats'
    @description =<<-EOS
    HOMER Motif Analysis
EOS
    @required_columns = ['Name', 'BAM']
    @required_params = ['name', 'paired']
    @params['cores'] = '4'
    @params['ram'] = '15'
    @params['scratch'] = '100'
    @params['paired'] = true
    @params['grouping'] = ''
    @params['sampleGroup'] = ''
    @params['sampleGroup', 'description'] = 'sampleGroup should be different from refGroup'
    @params['refGroup'] = ''
    @params['refGroup', 'description'] = 'refGroup should be different from sampleGroup'
    @params['refBuild'] = ref_selector
    @params['name'] = 'CNVkit'
    @params['mail'] = ""
    @modules = ["Dev/R", "Tools/HOMER", "Tools/BEDTools"]
    #@inherit_tags = ["Factor", "B-Fabric", "Characteristic"]
  end
  def next_dataset
    report_file = File.join(@result_dir, @params['name'])
    report_link = File.join(report_file, '00index.html')
    {'Name'=>@params['name'],
      'Report [File]'=>report_file,
      'Static Report [Link]'=>report_link
    }
  end
  def commands
    run_RApp("EzAppCNVkit", lib_path: "/srv/GT/analysis/jonas/R_LIBS")
  end
end


