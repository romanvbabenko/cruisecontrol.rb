require "spec_helper"

describe ::Configuration do
  subject {described_class}
  it {should respond_to :disable_admin_ui}
  its(:disable_admin_ui) {should be_false}
end
