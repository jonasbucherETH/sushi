
# encoding: utf-8

require 'sushi_fabric'
require_relative 'global_variables'
include GlobalVariables

class DNAmeApp <  SushiFabric::SushiApp
  def initialize
    super
    @name = 'DNAme'
    @params['process_mode'] = 'DATASET'
    @analysis_category = 'Stats'
    @description =<<-EOS
DNA methylation analysis<br/>
    EOS
    @required_columns = ['Name', 'COV', 'BAM']
    @required_params = ['name']
    @params['cores'] = '1'
    @params['ram'] = '50'
    @params['scratch'] = '100'
    @params['allCytosineContexts'] = false
    @params['allCytosineContexts', 'description'] = 'place holder'
    @params['refBuild'] = ref_selector
    @params['refBuild', 'description'] = 'place holder'
    #@params['refFeatureFile'] = 'genes.gtf'
    #@params['refFeatureFile'] = '../../Sequence/WholeGenomeFasta/genome.fa'
    @params['grouping'] = ''
    @params['grouping', 'description'] = 'testCovariate: Specify the column name of your co-variate to 
    split the samples into groups for testing for differential methylation. Make sure the
    column name is in the format "NAME [Factor]" or "NAME [Numeric]"'
    @params['sampleGroup'] = '' ## Note: this will be a selector defined by Factor tagged column
    @params['sampleGroup', 'description'] = 'Test group. sampleGroup should be different from refGroup'
    @params['refGroup'] = '' ## Note: this will be a selector defined by Factor tagged column
    @params['refGroup', 'description'] = 'Control group. refGroup should be different from sampleGroup'
=begin
    @params['grouping2'] = ''
    @params['grouping2', 'description'] = 'adjustCovariate: Specify the column name of your variable to adjust for when testing for differential methylation'
    @params['sampleGroup2'] = '' ## Note: this will be a selector defined by Factor tagged column
    @params['sampleGroup2', 'description'] = 'Test group. sampleGroup should be different from refGroup'
    @params['refGroup2'] = '' ## Note: this will be a selector defined by Factor tagged column
    @params['refGroup2', 'description'] = 'Control group. refGroup should be different from sampleGroup'
=end    
    @params['biomart_selection'] = biomart_selector
    @params['name'] = 'DNAme'
    @params['mail'] = ""
    @modules = ["Dev/R", "Tools/HOMER", "Tools/BEDTools"]
    @inherit_tags = ["Factor", "B-Fabric", "Characteristic"]
  end
  def next_dataset
    report_file = File.join(@result_dir, @params['name'])
    report_link = File.join(report_file, '00index.html')
    {'Name'=>@params['name'],
     'Report [File]'=>report_file,
     'Static Report [Link]'=>report_link,
     #'Interactive report [Link]'=>"https://fgcz-shiny.uzh.ch/PopGen_Structure?data=#{report_file}",
    }.merge(extract_columns(@inherit_tags))
  end
  def commands
    run_RApp("EzAppDNAme", lib_path: "/srv/GT/analysis/jonas/R_LIBS")
    #command = "vcf-stats #{File.join("$GSTORE_DIR", @dataset[0]['Filtered VCF [File]'])} -p #{@params['name']}/vcf_stats"
  end
end
