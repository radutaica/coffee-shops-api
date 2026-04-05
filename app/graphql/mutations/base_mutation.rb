# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def authorized?(**args)
      unless context[:authenticated]
        raise GraphQL::ExecutionError, "Authentication required. Provide a valid API key via Authorization: Bearer <key> header."
      end

      super
    end
  end
end
