#!/usr/bin/env ruby
# encoding: utf-8
Version = '20230314-131340'

require 'sushi_fabric'
require_relative 'global_variables'
include GlobalVariables

class TrimGaloreApp < SushiFabric::SushiApp
  def initialize
    super
    @name = 'TrimGalore'
    @analysis_category = 'Prep'
    @description =<<-EOS
Trim Galore! is a wrapper script to automate quality and adapter trimming as well as quality control, with some added functionality to remove biased methylation positions for RRBS sequence files.
Refer to <a href='https://www.bioinformatics.babraham.ac.uk/projects/trim_galore'>https://www.bioinformatics.babraham.ac.uk/projects/trim_galore</a>
    EOS
    @required_columns = ['Name','Read1']
    @required_params = ['paired']
    # optional params
    @params['cores'] = '8'
    @params['ram'] = '15'
    @params['scratch'] = '100'
    @params['paired'] = false
    @params['paired', 'description'] = 'either the reads are paired-ends or single-end'
    @params['method_rrbs'] = false
    @params['method_rrbs', 'description'] = 'If RRBS was used, but the DNA material was digested with MseI instead of MspI, pick false'
    @params['rrbs_directional'] = true
    @params['rrbs_directional', 'description'] = 'RRBS library type: true = directional, false = non-directional'
    @params['quality_type'] = ['phred33', 'phred64']
    @params['quality_type', 'description'] = 'Fastq quality score type, if you use Illumina HiSeq or MySeq, chose phred33'
    @params['quality_threshold'] = '20'
    @params['quality_threshold', 'description'] = 'Trim	low-quality ends from reads	in addition	to adapter removal.'
    @params['min_length'] = '20'
    @params['min_length', 'description'] = 'Discard a read if it is below a certain length after trimming'
    
    #@params['adapter'] = {
    #  'auto-detect' => '',
      #'allIllumina-forTrimmomatic-20160202.fa' => '/srv/GT/databases/contaminants/allIllumina-forTrimmomatic-20160202.fa',
    #  'All Illumina Adapter' => '/srv/GT/databases/contaminants/illuminaContaminants.fa',
    #  'FastQC checking Adapter' => '/srv/GT/databases/adapter/adapter_list.fa',
    #}
    @params['adapter'] = ['', 'illumina', 'nextera', 'small_rna']
    @params['adapter', 'description'] = 'auto-detects adapter sequence when not specified'
    @params['mail'] = ""
    #@modules = ["trim_galore/0.6.10"]
    @modules = ["Tools/samtools"]
    @inherit_tags = ["Factor", "B-Fabric", "Characteristic"]
  end
  def preprocess
    if @params['paired']
      @required_columns << 'Read2'
    end
  end
  def set_default_parameters
    @params['paired'] = dataset_has_column?('Read2')
  end
  def next_dataset
  if @params['paired'] 
    dataset =  {'Name'=>@dataset['Name'],
      'Read1 [File]' => File.join(@result_dir, "#{File.basename(@dataset['Read1'].to_s).gsub('.fastq.gz','_val_1.fq.gz')}"),
      'Read Count' => 0,
      'Read2 [File]' = File.join(@result_dir, "#{File.basename(@dataset['Read2'].to_s).gsub('.fastq.gz','_val_2.fq.gz')}")
    }.merge(extract_columns(@inherit_tags))
  else
    dataset =  {'Name'=>@dataset['Name'],
      'Read1 [File]' => File.join(@result_dir, "#{File.basename(@dataset['Read1'].to_s).gsub('.fastq.gz','_trimmed.fq.gz')}"),
      'Read Count' => 0,
    }.merge(extract_columns(@inherit_tags))
  end
  dataset
  end
  
  def commands
    command = ""
    command << ". '/usr/local/ngseq/miniconda3/etc/profile.d/conda.sh'\n"
    command << "conda activate trim_galore\n"
    command << "trim_galore --quality #{@params['quality_threshold']} --#{@params['quality_type']} --gzip --length #{@params['min_length']}"
    # [options]
    if @params['paired']
      command << " --paired"
    end
    
    if @params['method_rrbs']
      command << " --rrbs"
    end
    unless @params['rrbs_directional']
      command << " --non_directional"
    end
    unless @params['adapter'].to_s.empty?
        #command << "cat #{@params['adapter']} >> #{adapters_fa}\n"
        command << " --#{@params['adapter']}"
    end
    
    # files
    command << " #{File.join(SushiFabric::GSTORE_DIR, @dataset['Read1'])}"
    if @params['paired']
      command << " #{File.join(SushiFabric::GSTORE_DIR, @dataset['Read2'])}"
    end
    command
  end
end

if __FILE__ == $0

end

