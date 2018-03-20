require 'active_admin/helpers/collection'
require 'active_admin/view_helpers/method_or_proc_helper'

module ActiveAdmin
  module Views

    # Renders a collection of ActiveAdmin::Scope objects as a
    # simple list with a seperator
    class Scopes < ActiveAdmin::Component
      builder_method :scopes_renderer

      include ActiveAdmin::ScopeChain
      include ::ActiveAdmin::Helpers::Collection

      def default_class_name
        "scopes"
      end

      def tag_name
        'div'
      end

      def build(scopes, options = {})
        scopes.group_by(&:group).each do |group, group_scopes|
          ul class: "table_tools_segmented_control #{group_class(group)}" do
            group_scopes.each do |scope|
              build_scope(scope, options) if call_method_or_proc_on(self, scope.display_if_block)
            end
          end
        end
      end

      protected

      def build_scope(scope, options)
        li class: classes_for_scope(scope) do
          scope_parameter_name='scope'.to_sym
          scope_parameter_name="scope_#{scope.group}".to_sym if !scope.group.blank?

          # remove global scope and this one
          params=request.query_parameters.except :page, :scope, scope_parameter_name, :commit, :format

          # remove all scope params if this scope doesn't have a group
          if !scope.group
            params=params.select{|k,v| !(k.index('scope_')==0)}
          end

          a href: url_for("#{scope_parameter_name}": scope.id, params: params), class: 'table_tools_button' do
            text_node scope_name(scope)
            span class: 'count' do
              "(#{get_scope_count(scope)})"
            end if options[:scope_count] && scope.show_count
          end
        end
      end

      def classes_for_scope(scope)
        classes = ["scope", scope.id]
        classes << "selected" if current_scope?(scope)
        classes.join(" ")
      end

      def current_scope?(scope)
        if params[:scope]
          params[:scope] == scope.id
        else
          active_admin_config.default_scope(self) == scope
        end
      end

      # Return the count for the scope passed in.
      def get_scope_count(scope)
        collection_size(scope_chain(scope, collection_before_scope))
      end

      def group_class(group)
        group.present? ? "scope-group-#{group}" : "scope-default-group"
      end
    end
  end
end
