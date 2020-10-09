#!/usr/bin/env ruby
# encoding: utf-8

require 'sushi_fabric'
require_relative 'global_variables'
include GlobalVariables


class SCTrajectoryInferenceApp < SushiFabric::SushiApp
  def initialize
    super
    @name = 'SCTrajectoryInference'
    @params['process_mode'] = 'SAMPLE'
    @analysis_category = 'SingleCell'
    @description =<<-EOS
Trajectory inference analysis for single cell data<br/>
    EOS
    @required_columns = ['Name', 'Report']
    @required_params = ['name']
    # optional params
    @params['cores'] = '8'
    @params['ram'] = '30'
    @params['scratch'] = '250'
    @params['name'] = 'SCTrajectoryInference'
    @params['start_id'] = '0'
    @params['start_id', 'description'] = 'Start cluster(s)'
    @params['end_id'] = 'none'
    @params['end_id', 'description'] = 'End cluster(s)'
    @params['start_n'] = '1'
    @params['start_n', 'description'] = 'The number of start states'
    @params['end_n'] = '1'
    @params['end_n', 'description'] = 'The number of end states'
    @params['TI_method'] = 'none'
    @params['TI_method', 'description'] = 'Trajectory inference method(s)'
    @params['diff_Branch'] = 'none'
    @params['diff_Branch', 'description'] = 'Method and branch name to extract dysregulated genes from. (For example: Slingshot,3)'
    @params['diff_Branch_Point'] = 'none'
    @params['diff_Branch_Point', 'description'] = 'Method and branching point name to extract dysregulated genes from. (For example: Slingshot,3)'
    @params['specialOptions'] = ''
    @params['mail'] = ''
    @modules = ["Dev/R", "Dev/Python"]
  end
  def next_dataset
    report_file = File.join(@result_dir, "#{@dataset['Name']}_SCTrajectoryInference")
    report_link = File.join(report_file, '00index.html')
    {'Name'=>@dataset['Name'],
     'Static Report [Link]'=>report_link,
     'Report [File]'=>report_file,
    }
  end
  def commands
    run_RApp("EzAppSCTrajectoryInference")
  end
end

if __FILE__ == $0

end

