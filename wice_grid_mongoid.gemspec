# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{wice_grid_mongoid}
  s.version = "0.5.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Yuri Leikind", "Aleksandr Furmanov"]
  s.date = %q{2010-11-30}
  s.description = %q{A Rails grid plugin to create grids with sorting, pagination, and (automatically generated) filters }
  s.email = ["yuri.leikind@gmail.com", "aleksandr.furmanov@gmail.com"]
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "CHANGELOG",
     "MIT-LICENSE",
     "README.rdoc",
     "Rakefile",
     "SAVED_QUERIES_HOWTO.rdoc",
     "VERSION",
     "generators/common_templates/icons/arrow_down.gif",
     "generators/common_templates/icons/arrow_up.gif",
     "generators/common_templates/icons/calendar_view_month.png",
     "generators/common_templates/icons/delete.png",
     "generators/common_templates/icons/expand.png",
     "generators/common_templates/icons/page_white_excel.png",
     "generators/common_templates/icons/page_white_find.png",
     "generators/common_templates/icons/table.png",
     "generators/common_templates/icons/table_refresh.png",
     "generators/common_templates/icons/tick_all.png",
     "generators/common_templates/icons/untick_all.png",
     "generators/common_templates/initializers/wice_grid_config.rb",
     "generators/common_templates/locales/wice_grid.yml",
     "generators/common_templates/stylesheets/wice_grid.css",
     "generators/wice_grid_assets_jquery/templates/USAGE",
     "generators/wice_grid_assets_jquery/templates/javascripts/wice_grid_jquery.js",
     "generators/wice_grid_assets_jquery/wice_grid_assets_jquery_generator.rb",
     "generators/wice_grid_assets_prototype/USAGE",
     "generators/wice_grid_assets_prototype/templates/javascripts/calendarview.js",
     "generators/wice_grid_assets_prototype/templates/javascripts/wice_grid_prototype.js",
     "generators/wice_grid_assets_prototype/templates/stylesheets/calendarview.css",
     "generators/wice_grid_assets_prototype/wice_grid_assets_prototype_generator.rb",
     "init.rb",
     "install.rb",
     "lib/grid_output_buffer.rb",
     "lib/grid_renderer.rb",
     "lib/helpers/js_calendar_helpers.rb",
     "lib/helpers/wice_grid_misc_view_helpers.rb",
     "lib/helpers/wice_grid_serialized_queries_view_helpers.rb",
     "lib/helpers/wice_grid_view_helpers.rb",
     "lib/js_adaptors/jquery_adaptor.rb",
     "lib/js_adaptors/js_adaptor.rb",
     "lib/js_adaptors/prototype_adaptor.rb",
     "lib/table_column_matrix.rb",
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
     "tasks/wice_grid_tasks.rake",
     "test/.gitignore",
     "test/database.yml",
     "test/schema.rb",
     "test/test_helper.rb",
     "test/views/projects_and_people_grid.html.erb",
     "test/views/projects_and_people_grid_invalid.html.erb",
     "test/views/simple_projects_grid.html.erb",
     "test/wice_grid_core_ext_test.rb",
     "test/wice_grid_functional_test.rb",
     "test/wice_grid_misc_test.rb",
     "test/wice_grid_test.rb",
     "test/wice_grid_view_helper_test.rb",
     "uninstall.rb",
     "wice_grid_mongoid.gemspec"
  ]
  s.homepage = %q{http://github.com/afurmanov/wice_grid}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rails Grid Plugin}
  s.test_files = [
    "test/schema.rb",
     "test/test_helper.rb",
     "test/wice_grid_core_ext_test.rb",
     "test/wice_grid_functional_test.rb",
     "test/wice_grid_misc_test.rb",
     "test/wice_grid_test.rb",
     "test/wice_grid_view_helper_test.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

