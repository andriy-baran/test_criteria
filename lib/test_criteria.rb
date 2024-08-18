# frozen_string_literal: true

require_relative 'test_criteria/version'

##
# Serves as factory for creating specific contexts
module TestCriteria
  class Error < StandardError; end
  class ContextNotRegisterdError < Error; end

  ##
  # Stores values and code blocks.
  # Blocks serve two porposes:
  # 1. Defines nested level and passes new instance of BuildingBlock as value of the level
  # 2. Lazily executes given block (blocks are stored and executed when called)
  # @yield self
  # @example
  #   bb = TestCriteria::BuildingBlock.new
  #   bb.value_a = 1
  #   bb.block do |b|
  #     puts 'Here'
  #     b.value_a = 2
  #   end
  #   bb.value_a       # => 1
  #   bb.block         # => <#TestCriteria::BuildingBlock>
  #                    # Here
  #   bb.block.value_a # => 2
  #   bb.value_a = 3
  #   bb.value_a       # => 3
  #
  class BuildingBlock
    private

    # rubocop:disable Metrics/AbcSize
    def method_missing(method_name, *args, **_kwargs, &block)
      if block
        _block_definitions[method_name] = block
      elsif method_name.to_s.match?(/=\z/)
        singleton_class.attr_accessor method_name.to_s[0..-2]
        send(method_name, args.first)
      elsif _block_definitions.key?(method_name)
        bb = self.class.new
        _block_definitions[method_name].call(bb)
        bb
      end
    end
    # rubocop:enable Metrics/AbcSize

    def respond_to_missing?(*)
      true
    end

    def _block_definitions
      @_block_definitions ||= {}
    end
  end

  # Entry point for extending functionality of context definition block
  # @example To add factory_bot methods
  #   # test_helper.rb
  #   require 'test_criteria'
  #
  #   TestCriteria::ContextDefinition.extend FactoryBot::Syntax::Methods
  class ContextDefinition
    # Stores definition under specific name
    # @param name [Symbol, String] represents key in the registry
    # @return Hash
    def self.context(name, &block)
      { name => block }
    end
  end

  @contexts = {}

  # Creates a scope for defining new contexts
  # similar to "FactoryBot.define"
  # @return TestCriteria
  # @example
  #   TestCriteria.define do
  #     context(:checkout) do |c|
  #       c.success = 'Thanks for the purchase'
  #     end
  #   end
  def self.define(&block)
    @contexts.merge! ContextDefinition.class_eval(&block)
    self
  end

  # Gets specific context from the registry
  # @param name [Symbol, String] represents key in the registry
  # @return TestCriteria::BuildingBlock
  # @example
  #   context = TestCriteria[:checkout]
  #   context.success          # => 'Thanks for the purchase'
  #
  #   TestCriteria[:not_found] # => TestCriteria::ContextNotRegisterdError
  def self.[](name)
    bb = BuildingBlock.new
    context_definition_block = @contexts.fetch(name) do
      raise ContextNotRegisterdError
    end
    context_definition_block.call(bb)
    bb
  end
end
