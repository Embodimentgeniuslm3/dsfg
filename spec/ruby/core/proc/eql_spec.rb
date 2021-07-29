require_relative '../../spec_helper'
require_relative 'shared/equal'

describe "Proc#eql?" do
  ruby_version_is "0"..."2.8" do
    it_behaves_like :proc_equal_undefined, :eql?
  end

  ruby_version_is "2.8" do
    it_behaves_like :proc_equal, :eql?
  end
end
