#!/usr/bin/env ruby
# encoding: utf-8
Version = '20130628-172038'

require 'sushiApp'

class TophatApp < SushiApp
  def initialize
    super
    @name = 'Tophat'
    @analysis_category = 'Map'
    @required_columns = ['Sample','Read1','Species']
    @required_params = ['build','paired']
    # optional params
    @params['is_stranded'] = ['', 'sense', 'other']
    @params['paired'] = false
    @params['build'] = {'select'=>''}
    Dir["/srv/GT/reference/*/*/*"].sort.select{|build| File.directory?(build)}.each do |dir|
      @params['build'][dir.gsub(/\/srv\/GT\/reference\//,'')] = File.basename(dir)
    end
    @output_files = ['BAM','BAI']
  end
  def preprocess
    if @params['paired']
      @required_columns << 'Read2'
    end
  end
  def next_dataset
    {'Sample'=>@dataset['Sample'], 
     'BAM'=>File.join(@result_dir, "#{@dataset['Sample']}.bam"), 
     'BAI'=>File.join(@result_dir, "#{@dataset['Sample']}.bam.bai"),
     'Build'=>@params['build']
    }
  end
  def build_dir
    @build_dir ||= Dir["/srv/GT/reference/*/*/#{@params['build']}"].to_a[0]
  end
  def bowtie2_index
    @bowtie2_index ||= if build_dir
                         File.join(build_dir, 'Sequence/BOWTIE2Index/genome')
                       end
  end
  def transcripts_index
    @transcripts_index ||= if build_dir
                             File.join(build_dir, 'Annotation/Genes/genes_BOWTIE2Index/transcripts')
                           end
  end
  def library_type
    if @params['is_stranded'].empty?
      "--library-type fr-unstranded"
    else
     if  @params['is_stranded'] == 'sense'
      "--library-type fr-secondstrand"
     else
       "--library-type fr-firststrand"
     end
    end
  end
  def num_threads
    if @params['cores'].to_i > 1
      "--num-threads #{@params['cores']}"
    else
      ""
    end 
  end
  def commands
    if bowtie2_index and transcripts_index
      command = "/usr/local/ngseq/bin/tophat -o . #{num_threads} #{library_type} --transcriptome-index #{transcripts_index} #{bowtie2_index} #{@gstore_dir}/#{@dataset['Read1']}"
      if @params['paired']
        command << ",#{@gstore_dir}/#{@dataset['Read2']}\n"
      else
        command << "\n"
      end
      command << "mv accepted_hits.bam #{@dataset['Sample']}.bam\n"
      command << "samtools index #{@dataset['Sample']}.bam\n"
    end
    command
  end
end

if __FILE__ == $0
  usecase = TophatApp.new

  usecase.project = "p1001"
  usecase.user = "masa"

  # set user parameter
  # for GUI sushi
  #usecase.params['process_mode'].value = 'SAMPLE'
  #usecase.params['build'] = 'TAIR10'
  #usecase.params['paired'] = true
  #usecase.params['cores'] = 2
  #usecase.params['node'] = 'fgcz-c-048'

  # also possible to load a parameterset csv file
  # mainly for CUI sushi
  #usecase.parameterset_tsv_file = 'tophat_parameterset.tsv'
  usecase.parameterset_tsv_file = 'test.tsv'

  # set input dataset
  # mainly for CUI sushi
  usecase.dataset_tsv_file = 'tophat_dataset.tsv'

  # also possible to load a input dataset from Sushi DB
  #usecase.dataset_sushi_id = 1

  # run (submit to workflow_manager)
  usecase.run
  #usecase.test_run

end

