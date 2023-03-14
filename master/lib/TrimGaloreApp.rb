#!/usr/bin/env ruby
# encoding: utf-8
Version = '20210414-125050'

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
    @required_params = ['']
    # optional params
    quality_threshold
    @params['cores'] = '8'
    @params['ram'] = '15'
    @params['scratch'] = '100'
    @params['paired'] = false
    @params['sequencing_method'] = ['MspI-digested RRBS', 'Other']
    @params['sequencing_method', 'description'] = 'If your DNA material was digested with MseI instead of MspI, chose Other'
    @params['rrbs_library'] = ['Directional', 'Non-directional']
    @params['rrbs_library', 'description'] = 'RRBS library type'
    @params['paired', 'description'] = 'either the reads are paired-ends or single-end'
    @params['quality_type'] = ['phred33', 'phred64']
    @params['quality_type', 'description'] = 'Fastq quality score type, if you use Illumina HiSeq or MySeq, chose phred33'
    @params['quality_threshold'] = '20'
    @params['quality_threshold', 'description'] = 'Trim	low-quality ends from reads	in addition	to adapter removal.'
    @params['min_length'] = '20'
    @params['min_length', 'description'] = 'Discard a read if it is below a certain length after trimming'
    
    @params['mail'] = ""
    @modules = ["QC/TrimGalore"]
    @inherit_tags = ["Factor"]
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
   dataset =  {'Name'=>@dataset['Name'],
    'Read1 [File]' => File.join(@result_dir, "#{File.basename(@dataset['Read1'].to_s).gsub('fastq.gz','trimmed.fastq.gz')}"),
    'Read Count' => 0
    }.merge(extract_columns(@inherit_tags))
  if @params['paired'] 
      dataset['Read2 [File]'] = File.join(@result_dir, "#{File.basename(@dataset['Read2'].to_s).gsub('fastq.gz','trimmed.fastq.gz')}")
  end
  dataset
  end
  
  def commands
    command = ""
    command << "trim_galore --quality #{@params['quality_threshold']} --#{@params['quality_type']} --gzip --length #{@params['min_length']}"
    # [options]
    if @params['paired']
      command << " --paired"
    end
    
    if @params['sequencing_method'] == 'MspI-digested RRBS'
      command << " --rrbs"
    end
    if @params['rrbs_library'] == 'Non-directional'
      command << " --non_directional"
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

