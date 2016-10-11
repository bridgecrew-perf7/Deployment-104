require "admin/view_generator"

module Admin
  module Generators
    module Views
      class EditGenerator < Admin::ViewGenerator
        source_root template_source_path

        def copy_edit
          copy_resource_template("edit")
          copy_resource_template("_form")
        end
      end
    end
  end
end
