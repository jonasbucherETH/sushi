#!/usr/bin/env ruby
# encoding: utf-8
Version = '20230314-131340'

require 'sushi_fabric'
require_relative 'global_variables'
include GlobalVariables

class ClumpifyApp < SushiFabric::SushiApp
  def initialize
    super
    @name = 'Clumpify'
    @analysis_category = 'Prep'
    @description =<<-EOS
Clumpify is a tool designed to rapidly group overlapping reads into clumps. This can be used as a way to increase file compression, accelerate overlap-based assembly, or accelerate applications such as mapping or that are cache-sensitive
Refer to <a href='https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/clumpify-guide/'>https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/clumpify-guide/</a>
    EOS
    @required_columns = ['Name','Read1']
    @required_params = ['paired', 'sequencing_system']
    # optional params
    @params['cores'] = '8'
    @params['ram'] = '15'
    @params['scratch'] = '100'
    @params['paired'] = false
    @params['sequencing_system'] = {
          'NextSeq' => 40,
          'HiSeq 1T/2500' => 40,
          'HiSeq 3k/4k' => 2500,
          'Novaseq'  => 12000
    }
    @params['paired', 'description'] = 'either the reads are paired-ends or single-end'
    @params['mail'] = ""
    @modules = ["Tools/bbmap/38.89"]
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
    'Read1 [File]' => File.join(@result_dir, "#{File.basename(@dataset['Read1'].to_s).gsub('trimmed.fastq.gz','clumped.fastq.gz')}"),
    'Read Count' => 0
    }.merge(extract_columns(@inherit_tags))
  if @params['paired'] 
      dataset['Read2 [File]'] = File.join(@result_dir, "#{File.basename(@dataset['Read2'].to_s).gsub('trimmed.fastq.gz','clumped.fastq.gz')}")
  end
  dataset
  end
  def commands
    command = ""
    command << "clumpify.sh in=#{File.join(SushiFabric::GSTORE_DIR, @dataset['Read1'])}"
    output_R1 = File.basename(@dataset['Read1']).gsub('fastq.gz', 'trimmed.fastq.gz')
    command << " out=#{output_R1}"
    if @params['paired']
      output_R2 = File.basename(@dataset['Read2']).gsub('fastq.gz', 'trimmed.fastq.gz')
      command << " in2=#{File.join(SushiFabric::GSTORE_DIR, @dataset['Read2'])} out2=#{output_R2}"
    end
    # [options]
    
    command << " dedupe=t"
    command << " optical=t"
    
    if @params['sequencing_system'] = 'NextSeq'
      command << " spany=t"
      command << " adjacent=t"
    end
    command << " groups=16"
    #command << " reorder=t" # only if groups=1, passes=1, and ecc=f
    command << " qin=auto" # auto/33/64
    #dupe_dist = #{@params['illuminaclip']}
    command << " dupedist=#{@params['sequencing_system']}"

    command
  end
end

if __FILE__ == $0

end

