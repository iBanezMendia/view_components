# frozen_string_literal: true

require "lib/test_helper"
require_relative "models/deep_thought"

class Primer::Forms::CheckboxGroupInputTest < Minitest::Test
  include Primer::ComponentTestHelpers

   class PlainCheckBoxGroupForm < ApplicationForm
    form do |check_form|
      check_form.check_box_group(
        label: "Ultimate answer",
        validation_message: check_form.builder.object.invalid? ? "At least one selection is required" : nil,
      ) do |check_group|
        check_group.check_box(name: :foo, label: "Foo")
      end
    end
  end

  def test_plain_when_invalid_supports_validation_messages
    model = DeepThought.new(41)
    model.valid? # perform validations

    render_in_view_context do
      primer_form_with(url: "/foo", model: model) do |f|
        render(PlainCheckBoxGroupForm.new(f))
      end
    end

    assert_selector ".FormControl-inlineValidation.mt-2", visible: :visible
    assert_selector ".FormControl-inlineValidation span", text: "At least one selection is required", visible: :visible
  end

  def test_plain_when_valid_hides_validation_messages
    model = DeepThought.new(42)
    model.valid? # perform validations

    render_in_view_context do
      primer_form_with(url: "/foo", model: model) do |f|
        render(PlainCheckBoxGroupForm.new(f))
      end
    end

    assert_selector ".FormControl-inlineValidation", visible: :invisible
    assert_selector ".FormControl-inlineValidation span", text: nil, visible: :invisible
  end

  class HiddenCheckboxGroupForm < ApplicationForm
    form do |check_form|
      check_form.check_box_group(label: "Foobar", hidden: true) do |check_group|
        check_group.check_box(name: :foo, label: "Foo")
      end
    end
  end

  def test_hidden_checkbox_group
    render_in_view_context do
      primer_form_with(url: "/foo") do |f|
        render(HiddenCheckboxGroupForm.new(f))
      end
    end

    assert_selector "fieldset", visible: :hidden
    assert_selector ".FormControl-checkbox-wrap", visible: :hidden
  end

  class DisabledCheckboxGroupForm < ApplicationForm
    form do |check_form|
      check_form.check_box_group(label: "Foobar", disabled: true) do |check_group|
        check_group.check_box(name: :foo, label: "Foo")
      end
    end
  end

  def test_disabled_checkbox_group_disables_constituent_checkboxes
    render_in_view_context do
      primer_form_with(url: "/foo") do |f|
        render(DisabledCheckboxGroupForm.new(f))
      end
    end

    assert_selector ".FormControl-checkbox-wrap input[disabled]"
  end

  class DisabledCheckboxInGroupForm < ApplicationForm
    form do |check_form|
      check_form.check_box_group(label: "Foobar") do |check_group|
        check_group.check_box(name: :foo, label: "Foo", disabled: true)
      end
    end
  end

  def test_checkbox_can_be_individually_disabled_in_group
    render_in_view_context do
      primer_form_with(url: "/foo") do |f|
        render(DisabledCheckboxInGroupForm.new(f))
      end
    end

    assert_selector ".FormControl-checkbox-wrap input[disabled]"
  end
end
