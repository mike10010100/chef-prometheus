property :scrape_interval,     String
property :scrape_timeout,      String
property :labels,              Hash
property :target,              [Array, String]
property :metrics_path,        String, default: '/metrics'
property :config_file,         String, default: lazy { node['prometheus']['flags']['config.file'] }

default_action :create

action :create do
  with_run_context :root do
    nr = new_resource
    edit_resource(:template, nr.config_file) do
      variables[:jobs] ||= {}
      variables[:jobs][nr.name] ||= {}
      variables[:jobs][nr.name]['scrape_interval'] = nr.scrape_interval
      variables[:jobs][nr.name]['scrape_timeout'] = nr.scrape_timeout
      variables[:jobs][nr.name]['target'] = nr.target
      variables[:jobs][nr.name]['metrics_path'] = nr.metrics_path
      variables[:jobs][nr.name]['labels'] = nr.labels

      action :nothing
      delayed_action :create

      not_if { node['prometheus']['allow_external_config'] }
    end
  end
end

action :delete do
  template config_file do
    action :delete
  end
end
