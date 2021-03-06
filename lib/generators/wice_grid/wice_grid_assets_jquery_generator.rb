module WiceGrid
  module Generators
    class WiceGridAssetsJqueryGenerator < Rails::Generators::Base

      desc "Copy WiceGrid assets for JQuery based apps"
      source_root File.expand_path('../templates', __FILE__)

      def active_js_framework
        'jquery'
      end
      def inactive_js_framework
        'prototype'
      end


      def copy_stuff
        template 'wice_grid_config.rb', 'config/initializers/wice_grid_config.rb'

        copy_file 'wice_grid.yml',  'config/locales/wice_grid.yml'

        copy_file 'wice_grid_jquery.js',  'public/javascripts/wice_grid.js'
        copy_file 'wice_grid.css',  'public/stylesheets/wice_grid.css'

        %w(arrow_down.gif calendar_view_month.png expand.png page_white_find.png table_refresh.png
          arrow_up.gif delete.png page_white_excel.png  table.png tick_all.png untick_all.png ).each do |f|
            copy_file "icons/#{f}",  "public/images/icons/grid/#{f}"
        end
      end

    end
  end
end
