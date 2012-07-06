# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wice_grid_mongoid}
  s.version = "6.2.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yuri Leikind", "Aleksandr Furmanov"]
  s.date = %q{2011-05-19}
  s.description = %q{A Rails grid plugin to create grids with sorting, pagination, and (automatically generated) filters }
  s.email = %q{aleksandr.furmanov@gmail.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    "CHANGELOG",
    "Gemfile",
    "Gemfile.lock",
    "MIT-LICENSE",
    "README.rdoc",
    "Rakefile",
    "SAVED_QUERIES_HOWTO.rdoc",
    "VERSION",
    "lib/filter_conditions_generators.rb",
    "lib/generators/wice_grid/templates/calendarview.css",
    "lib/generators/wice_grid/templates/calendarview.js",
    "lib/generators/wice_grid/templates/icons/arrow_down.gif",
    "lib/generators/wice_grid/templates/icons/arrow_up.gif",
    "lib/generators/wice_grid/templates/icons/calendar_view_month.png",
    "lib/generators/wice_grid/templates/icons/delete.png",
    "lib/generators/wice_grid/templates/icons/expand.png",
    "lib/generators/wice_grid/templates/icons/page_white_excel.png",
    "lib/generators/wice_grid/templates/icons/page_white_find.png",
    "lib/generators/wice_grid/templates/icons/table.png",
    "lib/generators/wice_grid/templates/icons/table_refresh.png",
    "lib/generators/wice_grid/templates/icons/tick_all.png",
    "lib/generators/wice_grid/templates/icons/untick_all.png",
    "lib/generators/wice_grid/templates/wice_grid.css",
    "lib/generators/wice_grid/templates/wice_grid.yml",
    "lib/generators/wice_grid/templates/wice_grid_config.rb",
    "lib/generators/wice_grid/templates/wice_grid_jquery.js",
    "lib/generators/wice_grid/templates/wice_grid_prototype.js",
    "lib/generators/wice_grid/wice_grid_assets_jquery_generator.rb",
    "lib/generators/wice_grid/wice_grid_assets_prototype_generator.rb",
    "lib/grid_output_buffer.rb",
    "lib/grid_renderer.rb",
    "lib/helpers/js_calendar_helpers.rb",
    "lib/helpers/wice_grid_misc_view_helpers.rb",
    "lib/helpers/wice_grid_serialized_queries_view_helpers.rb",
    "lib/helpers/wice_grid_view_helpers.rb",
    "lib/js_adaptors/jquery_adaptor.rb",
    "lib/js_adaptors/js_adaptor.rb",
    "lib/js_adaptors/prototype_adaptor.rb",
    "lib/mongoid_field.rb",
    "lib/tasks/wice_grid_tasks.rake",
    "lib/view_columns.rb",
    "lib/views/create.rjs",
    "lib/views/delete.rjs",
    "lib/wice_grid.rb",
    "lib/wice_grid_controller.rb",
    "lib/wice_grid_core_ext.rb",
    "lib/wice_grid_misc.rb",
    "lib/wice_grid_serialized_queries_controller.rb",
    "lib/wice_grid_serialized_query.rb",
    "lib/wice_grid_spreadsheet.rb",
    "test/.gitignore",
    "test/blueprint.rb",
    "test/database.yml",
    "test/public/javascripts/jquery-1.4.2.min.js",
    "test/public/javascripts/wice_grid.js",
    "test/rails_mongoid_test.rb",
    "test/rails_test_app.rb",
    "test/require_gems.rb",
    "test/schema.rb",
    "test/spec_helper.rb",
    "test/test_helper.rb",
    "test/views/projects_and_people_grid.html.erb",
    "test/views/projects_and_people_grid_invalid.html.erb",
    "test/views/simple_projects_grid.html.erb",
    "test/wice_grid_core_ext_test.rb",
    "test/wice_grid_functional_test.rb",
    "test/wice_grid_initializer.rb",
    "test/wice_grid_misc_test.rb",
    "test/wice_grid_test.rb",
    "test/wice_grid_view_helper_test.rb",
    "wice_grid_mongoid.gemspec"
  ]
  s.homepage = %q{http://github.com/afurmanov/wice_grid}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.5.0}
  s.summary = %q{Rails Grid Plugin}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.0"])
      s.add_runtime_dependency(%q<mongoid>, [">= 0"])
      s.add_runtime_dependency(%q<bson_ext>, [">= 0"])
    else
      s.add_dependency(%q<rails>, ["~> 3.0"])
      s.add_dependency(%q<mongoid>, [">= 0"])
      s.add_dependency(%q<bson_ext>, [">= 0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.0"])
    s.add_dependency(%q<mongoid>, [">= 0"])
    s.add_dependency(%q<bson_ext>, [">= 0"])
  end
end

