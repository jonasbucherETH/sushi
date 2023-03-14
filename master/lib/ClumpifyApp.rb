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
    @required_params = ['paired', 'quality_type', 'sequencing_system']
    # optional params
    @params['cores'] = '8'
    @params['ram'] = '15'
    @params['scratch'] = '100'
    @params['paired'] = false
    @params['sequencing_system'] = ['NextSeq', 'Other']
    @params['paired', 'description'] = 'either the reads are paired-ends or single-end'
    @params['mail'] = ""
    @modules = ["Tools/bbmap"]
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
  def se_pe
    @params['paired'] ? 'PE' : 'SE'
  end
  def commands
    command = ""
    adapters_fa = "#{@dataset['Name']}_adapters.fa"
    if @dataset['Adapter1']
      command << "echo '>Adapter1' > #{adapters_fa}\n"
      command << "echo '#{@dataset["Adapter1"]}' >> #{adapters_fa}\n"
      if @dataset['Adapter2']
        command << "echo '>Adapter2' >> #{adapters_fa}\n"
        command << "echo #{@dataset['Adapter2']} >> #{adapters_fa}\n"
      end
    end
    unless @params['illuminaclip'].to_s.empty?
        command << "cat #{@params['illuminaclip']} >> #{adapters_fa}\n"
    end
    command << "java -jar $Trimmomatic_jar #{se_pe} -threads #{@params['cores']} -#{@params['quality_type']} #{File.join(SushiFabric::GSTORE_DIR, @dataset['Read1'])}"
    if @params['paired']
      command << " #{File.join(SushiFabric::GSTORE_DIR, @dataset['Read2'])}"
    end
    output_R1 = File.basename(@dataset['Read1']).gsub('fastq.gz', 'trimmed.fastq.gz')
    command << " #{output_R1}"
    if @params['paired']
      output_unpared_R1 = File.basename(@dataset['Read1']).gsub('fastq.gz', 'unpaired.fastq.gz')
      command << " #{output_unpared_R1}"
    end
    if @params['paired']
      output_R2 = File.basename(@dataset['Read2']).gsub('fastq.gz', 'trimmed.fastq.gz')
      output_unpared_R2 = File.basename(@dataset['Read2']).gsub('fastq.gz', 'unpaired.fastq.gz')
      command << " #{output_R2} #{output_unpared_R2}"
    end
    command << " ILLUMINACLIP:#{adapters_fa}:#{@params['seed_mismatchs']}:#{@params['palindrome_clip_threshold']}:#{@params['simple_clip_threshold']}"
    unless @params['leading'].strip.empty?
      command << " LEADING:#{@params['leading']}"
    end
    unless @params['trailing'].strip.empty?
      command << " TRAILING:#{@params['trailing']}"
    end
    unless @params['slidingwindow'].strip.empty?
      command << " SLIDINGWINDOW:#{@params['slidingwindow']}"
    end
    unless @params['avgqual'].strip.empty?
      command << " AVGQUAL:#{@params['avgqual']}"
    end
    unless @params['crop'].strip.empty?
      command << " CROP:#{@params['crop']}"
    end
    unless @params['headcrop'].strip.empty?
      command << " HEADCROP:#{@params['headcrop']}"
    end
    unless @params['minlen'].strip.empty?
      command << " MINLEN:#{@params['minlen']}"
    end
    command
  end
end

if __FILE__ == $0

end

