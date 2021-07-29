# frozen_string_literal: true
require "test/unit"

class TestTypeRubySyntax < Test::Unit::TestCase
  BINDING = module Sandbox
    binding
  end

  def assert_parses(code)
    loc = caller_locations[0]
    BINDING.eval code, loc.path, loc.lineno + 1
    assert true
  end

  def test_return_signatures
    assert_parses <<-RUBY
      def foo => String; end

      def foo => String
      end

      def foo() => String; end

      def foo() => String
      end

      def self.foo => String; end
    RUBY
  end

  def test_arg_signatures
    assert_parses <<-RUBY
      def foo(String s) end

      def foo(String a, String b) end
    RUBY
  end

  def test_optarg_signatures
    assert_parses <<-RUBY
      def foo(Fixnum a = 123) end

      def foo(Fixnum a = 123, Fixnum b = 123) end
    RUBY
  end

  def test_kwarg_signatures
    assert_parses <<-RUBY
      def foo(Fixnum a:) end

      def foo(Fixnum a: 123, Fixnum b:) end

      def foo(Fixnum a: 123, Fixnum b:, Fixnum c: 456) end
    RUBY
  end

  def test_block_signatures
    assert_parses <<-RUBY
      def foo(Proc &bk) end
    RUBY
  end

  def test_array_type
    assert_parses <<-RUBY
      def foo => [String]; end
    RUBY
  end

  def test_hash_type
    assert_parses <<-RUBY
      def foo => { String => String }; end
    RUBY
  end

  def test_lambda_type
    assert_parses <<-RUBY
      def foo => ->(String) => String; end

      def foo => ->(Fixnum, String) => String; end

      def foo => -> => String; end

      def foo(->(Fixnum) => String &bk); end
    RUBY
  end

  def test_anonymous_block_arg_syntax
    assert_parses <<-RUBY
      def foo(&); end

      def foo(Proc &); end
    RUBY
  end

  def test_nillable_type
    assert_parses <<-RUBY
      def foo => ?String; end
    RUBY
  end
end
