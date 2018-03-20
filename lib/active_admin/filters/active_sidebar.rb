require 'active_admin/filters/active'

module ActiveAdmin
  module Filters
    class ActiveSidebar < ActiveAdmin::SidebarSection

      def initialize
        super I18n.t("active_admin.search_status.headline"), sidebar_options
      end

      def block
        -> do
          active_filters = ActiveAdmin::Filters::Active.new(active_admin_config, assigns[:search])
          span do
            if !current_scope.empty?
              h4 I18n.t("active_admin.search_status.current_scope"), style: 'display: inline'
              b current_scope.map{|s| scope_name(s)}.join('|'), class: 'current_scope_name', style: "display: inline"
            end
            div style: "margin-top: 10px" do
              h4 I18n.t("active_admin.search_status.current_filters"), style: 'margin-bottom: 10px'
              ul do
                if active_filters.filters.blank?
                  li I18n.t("active_admin.search_status.no_current_filters")
                else
                  active_filters.filters.each do |filter|
                    li filter.html_options do
                      span do
                        text_node filter.label
                      end
                      b do
                        text_node to_sentence(filter.values.map { |v| pretty_format(v) })
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      protected

      def sidebar_options
        { only: :index, if: -> { active_admin_config.current_filters_enabled? && (params[:q] || !params.select{|k,v| k.index('scope')==0}.empty?) } }
      end

    end
  end
end
