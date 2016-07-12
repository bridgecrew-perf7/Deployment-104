
module API
  module Mobile
    class Base < Grape::API
      mount API::Mobile::Users

      add_swagger_documentation(
        api_version: "mobile",
        hide_documentation_path: true,
        base_path: "/api",
        mount_path: "/api/mobile",
        hide_format: true
      )
    end
  end
end
